import org.apache.commons.lang.StringUtils
import java.text.SimpleDateFormat
import au.org.ala.cas.util.AuthenticationCookieUtils
import au.org.ala.volunteer.FrontPage

class MessageFilters {

    def filters = {
        all(controller:'*', action:'*') {

            before = {

                def frontPage = FrontPage.instance()

                if (frontPage && StringUtils.isNotEmpty(frontPage.systemMessage)) {
                    flash.systemMessage = frontPage.systemMessage
                }

                return true

            }
            after = {
                def username = AuthenticationCookieUtils.getUserName(request) ?: "unknown"
                def sdf = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
                def dateStr = sdf.format(new Date())

                println "[${dateStr}] BVP Session: ${session.id} user: ${username}/${request.remoteAddr} request:${request.requestURI}"
            }
            afterView = {
                
            }
        }
    }
    
}
