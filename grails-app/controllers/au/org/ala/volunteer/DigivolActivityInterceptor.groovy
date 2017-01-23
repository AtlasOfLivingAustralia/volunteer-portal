package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils
import groovy.transform.CompileStatic

@CompileStatic
class DigivolActivityInterceptor {

    UserService userService
    SettingsService settingsService

    DigivolActivityInterceptor() {
        matchAll()
            .excludes(controllerClass: AjaxController)
            .excludes(actionName: 'unreadValidatedTasks')
    }

    boolean before() {
        log.debug('DigivolActivityInterceptor before')
        final enabled = grailsApplication.config.get('bvp.user.activity.monitor.enabled')
        if (!enabled) {
            return true
        }

        def userId = AuthenticationCookieUtils.getUserName(request)
        if (userId) {
            userService.recordUserActivity(userId, request, params)
        }
        true
    }

    boolean after() {
        log.debug('DigivolActivityInterceptor after')
        true
    }

    void afterView() {
        // no-op
        log.debug("After view")
    }
}
