package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import groovy.util.logging.Slf4j
import io.reactivex.Observable
import io.reactivex.subjects.Subject
import io.reactivex.subjects.UnicastSubject
import reactor.spring.context.annotation.Consumer
import reactor.spring.context.annotation.Selector

import javax.annotation.PostConstruct
import javax.annotation.PreDestroy
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.ConcurrentMap
import java.util.concurrent.TimeUnit

@Slf4j
@Consumer
@Transactional(readOnly=true)
class EventSourceService {

    static final String NEW_MESSAGE = 'event.source.new.message'

    static final int QUEUE_CAPACITY = 3 // browsers will allow ~6 connections, so this is plenty.

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

    List<Message> currentStartMessages(String userId) {
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

    Observable<Message.EventSourceMessage> addConnection(String userId) {
        final startMessageList = currentStartMessages(userId)
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
                    log.debug("Observable complete for $userId")
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
