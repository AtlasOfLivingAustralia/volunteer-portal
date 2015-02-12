package au.org.ala.volunteer

import org.apache.log4j.Logger

import javax.servlet.http.HttpSessionListener
import javax.servlet.http.HttpSessionEvent
import groovy.time.TimeDuration

class BVPSessionListener implements HttpSessionListener {

    private static final Logger logger = Logger.getLogger(BVPSessionListener.class)

    void sessionCreated(HttpSessionEvent e) {
        logger.debug "Session created: ${e.session.id}"
    }

    void sessionDestroyed(HttpSessionEvent e) {
        use (groovy.time.TimeCategory) {
            TimeDuration lastAccessedDuration = new Date() - new Date(e.session.lastAccessedTime)
            logger.debug "Session destroyed: ${e.session.id}, last accessed: ${new Date(e.session.lastAccessedTime)} - ${lastAccessedDuration} ago"
        }

    }

}
