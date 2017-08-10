package au.org.ala.volunteer

import grails.converters.JSON
import org.codehaus.groovy.runtime.GStringImpl
import org.grails.web.converters.Converter
import grails.rx.web.*
import java.util.concurrent.TimeUnit

class EventSourceController implements RxController {

    def authService
    def eventSourceService

    def index() {
        final user = authService.userId
        if (!user) {
            log.info("Attempt to get EventSource connection without a user id")
            response.sendError(400)
            return
        }
        def observable =
                eventSourceService
                        .addConnection(user)
                        .map { esm ->
                            def data
                            if(esm.data) {
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
                                    default:
                                        data = { Writer out -> (esm.data as JSON).render(out) }
                                }
                            }
                                data == null ? rx.event((Writable) null, comment: esm.comment, id: esm.id, event: esm.event) : rx.event(data, comment: esm.comment, id: esm.id, event: esm.event)
                            }
                        .doOnError { t -> log.error("Exception from messages for ${user.userId}", t) }

        rx.stream(observable, 30, TimeUnit.SECONDS)
    }
}
