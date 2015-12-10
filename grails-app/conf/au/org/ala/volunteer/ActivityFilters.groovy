package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils

class ActivityFilters {

    def achievementService
    def userService
    def securityPrimitives
    def fullTextIndexService
    def settingsService
    def domainUpdateService

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

        buildInfo(controller: 'buildInfo', action: '*') {
            before = {
                log.debug("Build Info controller")
                securityPrimitives.isAnyGranted([au.org.ala.web.CASRoles.ROLE_ADMIN])
            }
        }
        
        achievements(controller:'*', action:'*') {
            after = { Map model ->
                log.debug("task debouncing")

                def taskSet = GormEventDebouncer.taskSet

                try {
                    domainUpdateService.onTasksUpdated(taskSet)
                } catch (Exception e) {
                    log.error("Exception while performing post request actions", e)
                }
            }
        }
    }
}
