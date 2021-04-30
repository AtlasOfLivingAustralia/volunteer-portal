package au.org.ala.volunteer

import au.org.ala.volunteer.util.CloseShieldWriter
import grails.converters.JSON
import io.reactivex.plugins.RxJavaPlugins
import org.codehaus.groovy.runtime.GStringImpl
import org.grails.web.converters.Converter
import grails.rx.web.*

import javax.annotation.PostConstruct
import java.util.concurrent.TimeUnit

class EventSourceController implements RxController {

    def authService
    def eventSourceService

    @PostConstruct
    def init() {
        RxJavaPlugins.setErrorHandler() { throwable ->
            if (throwable?.cause instanceof org.apache.catalina.connector.ClientAbortException) {
                log.debug("Client Abort Exception")
            } else {
                log.error("Unhandled exception in RxJava (ESController)", throwable)
            }
        }
    }

    def index() {
        final userId = authService.userId
        if (!userId) {
            log.error("Attempt to get EventSource connection without a user id")
            response.sendError(400)
            return
        }

        def observable = eventSourceService
                            .addConnection(userId)
                            .map { esm ->
                                def data
                                switch (esm.data) {
                                    case Writable:
                                    case GString:
                                    case GStringImpl:
                                    case CharSequence:
                                        // data = esm.data
                                        rx.event(esm.data as CharSequence, comment: esm.comment, id: esm.id, event: esm.event)
                                        break
                                    case Converter:
                                        data = { Writer out ->
                                            esm.data.render(new CloseShieldWriter(out))
                                        }
                                        rx.event(data, comment: esm.comment, id: esm.id, event: esm.event)
                                        break
                                    case null:
                                        rx.event((Writable) null, comment: esm.comment, id: esm.id, event: esm.event)
                                        break
                                    default:
                                        // log.debug("Writing json data for event: ${esm.data}")
                                        // data = { Writer out -> (esm.data as JSON).render(out) }
                                        data = { Object eventData, Writer out ->
                                            try {
                                                (eventData as JSON).render(new CloseShieldWriter(out))
                                            } catch (e) {
                                                log.error("Exception converting data to JSON", e)
                                            }
                                        }.curry(esm.data)
                                        log.info("EventSourceController sending id: ${esm.id} event: ${esm.event} data: ${esm.data} comment: ${esm.comment}")
                                        rx.event((Closure)data, comment: esm.comment, id: esm.id, event: esm.event)
                                }
                            }
                            .doOnError { t -> log.error("Exception from messages for ${userId}", t) }

        log.debug("Streaming observable back to message queue.")
        rx.stream(observable, 30, TimeUnit.SECONDS)
    }
}
