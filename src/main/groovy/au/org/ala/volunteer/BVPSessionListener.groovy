package au.org.ala.volunteer

import groovy.time.TimeCategory
//import org.apache.log4j.Logger
import groovy.util.logging.Slf4j
//import org.jasig.cas.client.validation.AssertionImpl
import org.pac4j.core.profile.UserProfile
import org.pac4j.core.util.Pac4jConstants

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
            def userSession = getUserSession(session)
            return userSession ? ", CAS( Name: ${userSession?.name}, Valid-From: ${userSession?.validFromDate} , Valid-Until: ${userSession?.validUntilDate} )" : ''
        } catch (ignored) {
            return ''
        }
    }

    // TODO Update to replace with
    // Map<String, UserProfile> profiles = session.getAttribute(Pac4jConstants.USER_PROFILES)
    // then from there need to figure out which UserProfile from that map is the correct one (I'm assuming there's only
    // going to be one tbh) and then from there dig into the attribute values to find valid from/to dates
    private static Map getUserSession(HttpSession session) {
        Map userSession
        try {
            Map<String, UserProfile> profiles = session.getAttribute(Pac4jConstants.USER_PROFILES)
            log.debug("profile: ${profiles}")

            userSession.name = 'Cognito Session'

        } catch (IllegalStateException ignored) {
            // invalidated session, ignore this
            return null
        }

        return userSession
    }

    /*
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
    */

}
