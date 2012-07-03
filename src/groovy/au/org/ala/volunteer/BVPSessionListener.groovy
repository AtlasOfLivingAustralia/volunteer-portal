package au.org.ala.volunteer

import javax.servlet.http.HttpSessionListener
import javax.servlet.http.HttpSessionEvent
import java.text.SimpleDateFormat
import org.codehaus.groovy.grails.commons.ApplicationHolder

class BVPSessionListener implements HttpSessionListener {

    void sessionCreated(HttpSessionEvent e) {
        logService?.log "Session created: ${e.session.id}"
    }

    void sessionDestroyed(HttpSessionEvent e) {
        logService?.log "Session destroyed: ${e.session.id}, last accessed: ${new Date(e.session.lastAccessedTime)}"
    }

    private LogService getLogService() {
        return new LogService()
    }

}
