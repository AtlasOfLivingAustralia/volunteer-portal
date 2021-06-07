package au.org.ala.volunteer

import grails.events.EventPublisher
import grails.events.annotation.Subscriber
import reactor.spring.context.annotation.Consumer
import reactor.spring.context.annotation.Selector

import javax.annotation.PostConstruct
import javax.annotation.PreDestroy

@Consumer
class FrontPageService implements EventPublisher {

    public static final String ALERT_MESSAGE = 'alertMessage'

    def eventSourceService

    def eventSourceStartMessage

    @PostConstruct
    void init() {
        eventSourceStartMessage = eventSourceService.addEventSourceStartMessage { userId ->
            log.debug("Getting Front Page System Message")
            def systemMessage = FrontPage.first().systemMessage
            log.debug("Got Front Page System Message")
            [createMessage(systemMessage)]
        }
    }

    @PreDestroy
    void destroy() {
        eventSourceService.removeEventSourceStartMessage(eventSourceStartMessage)
    }

    private static Message.EventSourceMessage createMessage(String message) {
        new Message.EventSourceMessage(event: ALERT_MESSAGE, data: message)
    }

//    @Subscriber(FrontPageService.ALERT_MESSAGE)
    @Selector(FrontPageService.ALERT_MESSAGE)
    void alertMessage(String alert) {
        try {
            log.debug("On Alert Message")
            notify(EventSourceService.NEW_MESSAGE, createMessage(alert))
        } catch (e) {
            log.error("Exception caught while handling system message change", e)
        }
    }
}
