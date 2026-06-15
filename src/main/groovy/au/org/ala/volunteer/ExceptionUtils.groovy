package au.org.ala.volunteer

import groovy.util.logging.Slf4j

@Slf4j
class ExceptionUtils {

    /**
     * Converts a stack trace to a string.
     * @param e The throwable to convert.
     * @return The stack trace as a string.
     */
    static String getStackTraceAsString(Throwable e) {
        def sw = new StringWriter()
        def pw = new PrintWriter(sw)
        e.printStackTrace(pw)
        return sw.toString()
    }

}
