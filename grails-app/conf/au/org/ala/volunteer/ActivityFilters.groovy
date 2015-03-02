package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils

class ActivityFilters {

    def achievementService
    def userService
    def securityPrimitives
    def fullTextIndexService
    def settingsService

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
                try {
                    if (deletedTasks) {
                        fullTextIndexService.deleteTasks(deletedTasks)
                    }
                    if (taskSet) {
                        fullTextIndexService.indexTasks(taskSet)
                        if (settingsService.getSetting(SettingDefinition.EnableAchievementCalculations)) {
                            // TODO Replace with withCriteria
                            def involvedUserIds =
                                    Task.findAllByIdInList(taskSet.toList())
                                            .collect { [it.fullyTranscribedBy, it.fullyValidatedBy] }
                                            .flatten().findAll { it != null }
                                            .toSet()
                            def cheevs = taskSet.collect {
                                achievementService.evalAndRecordAchievements(involvedUserIds + userService.currentUserId, it)
                            }.flatten()
//                            if (cheevs) {
//                                flash.message = "You have just achieved ${cheevs.collect { it.achievement.name }.join(", ")}!"
//                            }
                        }
                    }
                } catch (Exception e) {
                    log.error("Exception while performing post request actions", e)
                }
            }
        }
    }
}
