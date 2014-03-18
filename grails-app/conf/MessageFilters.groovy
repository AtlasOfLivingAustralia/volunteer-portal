import org.apache.commons.lang.StringUtils
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
            }
            afterView = {
                
            }
        }
    }
    
}
