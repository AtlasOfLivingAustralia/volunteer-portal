package au.org.ala.volunteer

import au.org.ala.cas.util.AuthenticationCookieUtils
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j

@CompileStatic
@Slf4j
class DigivolActivityInterceptor {

    UserService userService
    SettingsService settingsService

    DigivolActivityInterceptor() {
        matchAll()
            .excludes(controller: 'ajax')
            .excludes(controller: 'eventSource')
            .excludes(action: 'unreadValidatedTasks')
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
    }
}
