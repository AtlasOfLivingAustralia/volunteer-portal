package au.org.ala.volunteer

import javax.servlet.AsyncContext
import java.util.concurrent.TimeUnit

class EventSourceController {

    static scope = 'singleton'

    def eventSourceService, userService

    def index() {
        final userId = userService.currentUserId ?: ''
        response.setContentType("text/event-stream")
        response.setCharacterEncoding("UTF-8")
        response.setHeader('Connection', 'close')

        final AsyncContext ac = request.startAsync()
        ac.setTimeout(TimeUnit.MILLISECONDS.convert(4, TimeUnit.HOURS))

        response.flushBuffer()

        eventSourceService.addAsyncContext(ac, userId)
    }

}
