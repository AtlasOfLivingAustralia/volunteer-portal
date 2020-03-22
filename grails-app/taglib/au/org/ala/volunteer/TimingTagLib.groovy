package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import groovy.util.logging.Slf4j

@Slf4j('logger')
class TimingTagLib {
    static defaultEncodeAs = [taglib:'none']
    //static encodeAsForTags = [tagName: [taglib:'html'], otherTagName: [taglib:'none']]
//    static returnObjectForTags = ['start', 'log']

    static namespace = "time"

    Stopwatch sw

    def start = { attrs ->
        sw = Stopwatch.createStarted()
    }

    def log = { attrs ->
        def message = attrs.remove('message')
        logger.debug("{}: {}", message, sw)
        sw.reset().start()
    }

    def block = { attrs, body ->
        def sw1 = Stopwatch.createStarted()
        def message = attrs.remove('message')
        out << body()
        logger.debug('{}: {}', message, sw1)
        return
    }
}
