package au.org.ala.volunteer

import groovy.time.TimeCategory
//import org.apache.log4j.Logger
import groovy.util.logging.Slf4j
import org.jasig.cas.client.validation.AssertionImpl

import javax.servlet.http.HttpSession
import javax.servlet.http.HttpSessionListener
import javax.servlet.http.HttpSessionEvent
import groovy.time.TimeDuration

@Slf4j
class BVPSessionListener implements HttpSessionListener {

    //private static final Logger logger = Logger.getLogger(BVPSessionListener.class)

    private static final String CAS_ATTRIBUTE = '_const_cas_assertion_'

    void sessionCreated(HttpSessionEvent e) {
        log.debug "Session created: ${e.session.id}${assertionDetails(e.session)}"
    }

    void sessionDestroyed(HttpSessionEvent e) {
        use (TimeCategory) {
            TimeDuration lastAccessedDuration = new Date() - new Date(e.session.lastAccessedTime)
            log.debug "Session destroyed: ${e.session.id}${assertionDetails(e.session)}, last accessed: ${new Date(e.session.lastAccessedTime)} - ${lastAccessedDuration} ago"
        }

    }

    private static String assertionDetails(HttpSession session) {
        try {
            def assertion = casAssertion(session)
            return assertion ? ", CAS( Name: ${assertion.principal.name}, Valid-From: ${assertion.validFromDate} , Valid-Until: ${assertion.validUntilDate} )" : ''
        } catch (ignored) {
            return ''
        }
    }

    private static AssertionImpl casAssertion(HttpSession session) {
        def obj
        try {
            obj = session.getAttribute(CAS_ATTRIBUTE)
        } catch (IllegalStateException ignored) {
            // invalidated session, ignore this
            return null
        }

        return (obj && obj instanceof AssertionImpl) ? obj : null
    }


}
