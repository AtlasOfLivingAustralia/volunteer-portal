package au.org.ala.volunteer

import javax.annotation.PostConstruct
import javax.annotation.PreDestroy
import javax.servlet.AsyncContext
import javax.servlet.AsyncEvent
import javax.servlet.AsyncListener
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.ConcurrentMap
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

import static grails.async.Promises.*

class EventSourceService {

    def userService

    static transactional = false
    static readOnly = true

    private final ConcurrentMap<String, ConcurrentLinkedQueue<AsyncContext>> ongoingRequests = new ConcurrentHashMap<>()
    private final ScheduledExecutorService keepalive = Executors.newScheduledThreadPool(1)

    private final keepAliveMsg = new EventSourceMessage(comment: 'ka')

    @PostConstruct
    void init() {
        log.debug("Post Construct")
        keepalive.scheduleAtFixedRate({
            log.debug("Sending keep alive message")
            sendToEveryone(keepAliveMsg)
        } as Runnable, 1, 1, TimeUnit.MINUTES)
    }

    @PreDestroy
    void close() {
        log.debug("Pre Destroy")
        keepalive.shutdownNow()
        ongoingRequests.each { k, v ->
            final i = v.iterator()
            while (i.hasNext()) {
                final ac = i.next()
                i.remove()
                ac.complete()
            }
        }
        log.debug("Pre Destroy End")
    }

    private final ConcurrentLinkedQueue<Closure<List<EventSourceMessage>>> startMessages = new ConcurrentLinkedQueue<>();

    def addEventSourceStartMessage(Closure<List<EventSourceMessage>> c) {
        startMessages.add(c)
        c
    }

    def removeEventSourceStartMessage(Closure<List<EventSourceMessage>> c) {
        startMessages.remove(c)
    }

    public void addAsyncContext(AsyncContext ac, String userId) {
        ac.addListener(new AsyncListener() {
            @Override public void onComplete(AsyncEvent event) throws IOException { log.debug('Async onComplete'); removeRequest(userId, ac) }
            @Override public void onTimeout(AsyncEvent event) throws IOException { log.debug('Async onTimeout'); removeRequest(userId, ac) }
            @Override public void onError(AsyncEvent event) throws IOException { log.warn('Async onError'); ac.complete(); removeRequest(userId, ac) }
            @Override public void onStartAsync(AsyncEvent event) throws IOException { log.debug("On Start Async") }
        })
        ongoingRequests.putIfAbsent(userId, new ConcurrentLinkedQueue<AsyncContext>())
        def q = ongoingRequests.get(userId)
        q.add(ac)

        log.debug("Start event source for $userId")

        // Could be any domain class AFAIK
        FrontPage.async.task {
            try {
                log.debug("Getting startup messages for $userId")
                def i = startMessages.iterator()
                while (i.hasNext()) {
                    def c = i.next()
                    log.debug("Calling startup closure for $userId")
                    final messages
                    try {
                        messages = c.call(userId)
                    } catch (e) {
                        log.error("Caught exception getting startup messages for $userId", e)
                        messages = []
                    }
                    log.debug("Got $messages for $userId")

                    messages.each {
                        log.debug("Sending start up message ${it.toString()}")
                        sendMessage(ac, it, { removeRequest(userId, ac); } )
                        log.debug("Send start up message done")
                    }
                }
                log.debug("Completed sending startup messages for $userId")
            } catch (e) {
                log.error("Exception sending startup messages for $userId", e)
            }
        }
    }

    private def removeRequest(String userId, AsyncContext ac) {
        log.debug("Removing async context for $userId")
        ongoingRequests[userId]?.remove(ac)
    }

    def sendToUser(String userId, EventSourceMessage msg) {
        def requests = ongoingRequests[userId]
        if (requests) {
            sendMessages(requests, msg)
        }
    }

    def sendToEveryone(EventSourceMessage msg) {
        ongoingRequests.each { k, v ->
            sendMessages(v, msg)
        }
    }

    private sendMessages(ConcurrentLinkedQueue<AsyncContext> v, EventSourceMessage msg) {
        final i = v.iterator()
        while (i.hasNext()) {
            def ac = i.next()
            sendMessage(ac, msg, { i.remove(); } )
        }
    }

    private sendMessage(AsyncContext ac, EventSourceMessage msg, Closure<Void> onError) {
        try {
            final w = ac.response.writer
            msg.writeTo(w)
            if (w.checkError()) {
                log.warn("Async Response Writer indicated an error")
                onError.call()
            } else {
                ac.response.flushBuffer()
            }
        } catch (IOException e) {
            log.warn("Exception in events controller async task handling", e)
            onError.call()
        }
    }

}
