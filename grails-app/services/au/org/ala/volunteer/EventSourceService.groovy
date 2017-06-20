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

    static final int QUEUE_CAPACITY = 3 // don't exhaust the 6 possible connections from a browser...

    def userService

    static transactional = false
    static readOnly = true

    private final ConcurrentMap<String, ConcurrentLinkedQueue<AsyncContext>> ongoingRequests = new ConcurrentHashMap<>()
    private final ScheduledExecutorService keepalive = Executors.newScheduledThreadPool(1)

    private final keepAliveMsg = new EventSourceMessage(comment: 'ka')

    @PostConstruct
    void init() {
        log.trace("Post Construct")
        keepalive.scheduleAtFixedRate({
            log.trace("Sending keep alive message")
            sendToEveryone(keepAliveMsg)
        } as Runnable, 15, 15, TimeUnit.SECONDS)
    }

    @PreDestroy
    void close() {
        log.trace("Pre Destroy")
        keepalive.shutdownNow()
        ongoingRequests.each { k, v ->
            final i = v.iterator()
            while (i.hasNext()) {
                final ac = i.next()
                i.remove()
                try {
                    ac.complete()
                } catch (e) {
                    log.debug("Caught exception closing async context while shutting down", e)
                }
            }
        }
        log.trace("Pre Destroy End")
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
            @Override public void onError(AsyncEvent event) throws IOException { log.warn('Async onError'); removeRequest(userId, ac) }
            @Override public void onStartAsync(AsyncEvent event) throws IOException { log.debug("On Start Async") }
        })
        ongoingRequests.putIfAbsent(userId, new ConcurrentLinkedQueue<AsyncContext>())
        def q = ongoingRequests.get(userId)
        q.add(ac)

        // kill oldest connections above threshold
        while (q.size() > QUEUE_CAPACITY) {
            def oldAc = q.poll()
            if (oldAc) removeRequest(userId, oldAc)
        }

        log.debug("Start event source for $userId")

        // Could be any domain class AFAIK
        FrontPage.async.task {
            try {
                log.trace("Getting startup messages for $userId")
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
                        log.trace("Sending start up message ${it.toString()}")
                        sendMessage(ac, it, { removeRequest(userId, ac); } )
                        log.trace("Send start up message done")
                    }
                }
                log.trace("Completed sending startup messages for $userId")
            } catch (e) {
                log.error("Exception sending startup messages for $userId", e)
            }
        }
    }


    def getOpenRequestsForUser(String userId) {
        ongoingRequests[userId]?.size() ?: 0
    }

    private def removeRequest(String userId, AsyncContext ac) {
        log.debug("Removing async context for $userId")
        ongoingRequests[userId]?.remove(ac)
        try {
            ac.complete()
        } catch (e) {
            log.debug("Caught exception closing async context while removing request", e)
        }
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
            sendMessage(ac, msg, {
                i.remove()
                try {
                    ac.complete()
                } catch (e) {
                    log.debug("Caught exception closing async context while removing connection", e)
                }
            } )
        }
    }

    private sendMessage(AsyncContext ac, EventSourceMessage msg, Closure<Void> onError) {
        try {
            final w = ac.response.writer
            msg.writeTo(w)
            if (w.checkError()) {
                log.debug("Async Response Writer indicated an error")
                onError.call()
            } else {
                w.flush()
                ac.response.flushBuffer()
            }
        } catch (IOException e) {
            log.warn("Exception in events controller async task handling", e)
            onError.call()
        }
    }

}
