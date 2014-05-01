package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils

class ActivityFilters {

    def userService

    def filters = {
        allButAjax(controller:'*', controllerExclude:'ajax', action:'*') {
            before = {

                if (!grailsApplication.config.bvp.user.activity.monitor.enabled) {
                    return
                }

                def userId = AuthenticationCookieUtils.getUserName(request)
                if (userId) {
                    userService.recordUserActivity(userId, request, params)
                }
            }
            after = { Map model ->

            }
            afterView = { Exception e ->

            }
        }
    }
}
