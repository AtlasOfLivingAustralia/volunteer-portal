package au.org.ala.volunteer

import javax.servlet.http.HttpSessionListener
import javax.servlet.http.HttpSessionEvent
import groovy.time.TimeDuration

class BVPSessionListener implements HttpSessionListener {

    void sessionCreated(HttpSessionEvent e) {
        logService?.log "Session created: ${e.session.id}"
    }

    void sessionDestroyed(HttpSessionEvent e) {
        use (groovy.time.TimeCategory) {
            TimeDuration lastAccessedDuration = new Date() - new Date(e.session.lastAccessedTime)
            logService?.log "Session destroyed: ${e.session.id}, last accessed: ${new Date(e.session.lastAccessedTime)} - ${lastAccessedDuration} ago"
        }

    }

    private LogService getLogService() {
        return new LogService()
    }

}
