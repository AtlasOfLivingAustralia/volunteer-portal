package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils

class ActivityFilters {

    def achievementService
    def userService
    def securityPrimitives
    def fullTextIndexService

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
                log.debug("achievements filter")
                def taskSet = GormEventDebouncer.taskSet
                def deletedTasks = GormEventDebouncer.deletedTaskSet
                //def fieldSet = GormEventDebouncer.fieldSet
                if (deletedTasks) {
                    fullTextIndexService.deleteTasks(deletedTasks)
                }
                if (taskSet) {
                    fullTextIndexService.indexTasks(taskSet)
                    taskSet.each { achievementService.evaluateAchievements(userService.currentUser, it) }
                }
            }
        }
    }
}
