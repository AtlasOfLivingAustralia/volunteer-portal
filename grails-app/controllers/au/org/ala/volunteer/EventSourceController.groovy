package au.org.ala.volunteer

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
        final user = authService.userId
        if (!user) {
            log.error("Attempt to get EventSource connection without a user id")
            response.sendError(400)
            return
        }
        def observable =
                eventSourceService
                        .addConnection(user)
                        .map { esm ->
                            def data
                            switch (esm.data) {
                                case Writable:
                                case GString:
                                case GStringImpl:
                                case CharSequence:
                                    data = esm.data
                                    break
                                case Converter:
                                    data = { Writer out -> esm.data.render(out) }
                                    break
                                case null:
                                    data = null
                                    break
                                default:
                                    data = { Writer out -> (esm.data as JSON).render(out) }
                            }
                            data == null ? rx.event((Writable) null, comment: esm.comment, id: esm.id, event: esm.event) : rx.event(data, comment: esm.comment, id: esm.id, event: esm.event)
                        }
                        .doOnError { t -> log.error("Exception from messages for ${user.userId}", t) }

        rx.stream(observable, 30, TimeUnit.SECONDS)
    }
}
