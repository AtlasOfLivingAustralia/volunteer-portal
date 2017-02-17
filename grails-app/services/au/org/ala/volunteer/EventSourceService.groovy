package au.org.ala.volunteer

import au.org.ala.web.UserDetails
import grails.converters.JSON
import grails.rx.web.Rx
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject
import io.reactivex.subjects.Subject
import io.reactivex.subjects.UnicastSubject
import org.codehaus.groovy.runtime.GStringImpl
import org.grails.web.converters.Converter
import reactor.spring.context.annotation.Consumer
import reactor.spring.context.annotation.Selector

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

@Consumer
class EventSourceService {

    static final String NEW_MESSAGE = 'event.source.new.message'

    static final int QUEUE_CAPACITY = 3 // browsers will allow ~6 connections, so this is plenty.

    def userService

    static transactional = false
    static readOnly = true

    private final ConcurrentMap<String, ConcurrentLinkedQueue<Subject>> ongoingRequests = new ConcurrentHashMap<>()

    private final keepAliveMsg = new Message.EventSourceMessage(comment: 'ka')
    private final keepAlive = Observable.interval(15, 15, TimeUnit.SECONDS).map({ i -> keepAliveMsg }).publish().autoConnect()

    @PostConstruct
    void init() {
        log.trace("Post Construct")
    }

    @PreDestroy
    void close() {
        log.trace("Pre Destroy")
        for (def kv : ongoingRequests) {
            for (def subject : kv.value) {
                subject.onNext(Message.ShutdownMessage.INSTANCE)
                subject.onComplete()
            }
        }
        log.trace("Pre Destroy End")
    }

    private final ConcurrentLinkedQueue<Closure<List<Message.EventSourceMessage>>> startMessages = new ConcurrentLinkedQueue<>();

    def addEventSourceStartMessage(Closure<List<Message.EventSourceMessage>> c) {
        startMessages.add(c)
        c
    }

    def removeEventSourceStartMessage(Closure<List<Message.EventSourceMessage>> c) {
        startMessages.remove(c)
    }

    List<Message> currentStartMessages(UserDetails userDetails) {
        def userId = userDetails?.userId
        try {
            def result = []
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

                result.addAll(messages)
            }
            log.trace("Completed sending startup messages for $userId")
            return result
        } catch (e) {
            log.error("Exception sending startup messages for $userId", e)
            throw e
        }
    }

    void addSubject(String userId, Subject subject) {
        ongoingRequests.computeIfAbsent(userId, { new ConcurrentLinkedQueue<Subject>() })
        def q = ongoingRequests.get(userId)
        q.add(subject)

        // kill oldest connections above threshold
        while (q.size() > QUEUE_CAPACITY) {
            def oldSubject = q.poll()
            try {
                oldSubject?.onComplete()
            } catch (e) {
                log.error("Exception Completing a Subject", e)
            }
        }
    }

    def removeSubject(String userId, Subject subject) {
        def q = ongoingRequests.get(userId)
        q?.remove(subject)
    }


    def getOpenRequestsForUser(String userId) {
        ongoingRequests[userId]?.size() ?: 0
    }

    Observable<Message.EventSourceMessage> addConnection(UserDetails user) {
        final String userId = user.userId
        final startMessageList = currentStartMessages(user)
        UnicastSubject<Message> subject = UnicastSubject.create()
        subject
                .doOnComplete { removeSubject(userId, subject) }
                .doOnError { t ->
                    log.error("Exception in UnicastSubject for $userId", t)
                    removeSubject(userId, subject)
                }

        addSubject(userId, subject)

        Observable
                .fromIterable(startMessageList)
                .concatWith(subject)
                .mergeWith(keepAlive)
                .doOnComplete {
                    log.info("Observable complete for $userId")
                    removeSubject(userId, subject)
                }
                .doOnError { t ->
                    log.error("Exception in Observable for $userId", t)
                    removeSubject(userId, subject)
                }
                .takeWhile { !(it instanceof Message.ShutdownMessage) }
                .map { (Message.EventSourceMessage) it }
                .filter { !it.to || it.to == userId }
    }

    @Selector(EventSourceService.NEW_MESSAGE)
    void newMessage(Message.EventSourceMessage message) {
        for (def kv : ongoingRequests) {
            for (def subject : kv.value) {
                subject.onNext(message)
            }
        }
    }
}
