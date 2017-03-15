package au.org.ala.volunteer

import org.grails.web.servlet.mvc.GrailsWebRequest
import org.springframework.context.MessageSource
import org.springframework.web.servlet.i18n.SessionLocaleResolver

class I18nService {

    static boolean transactional = false

    //SessionLocaleResolver localeResolver
    MessageSource messageSource

    /**
     * Get a message from the grails message source using the locale looked up from the
     * current request if there is one, otherwise the default locale is used.
     *
     * @param code The message source code to look up
     * @param defaultMessage default message to use if none is defined in the message source
     * @param args objects for use in the message
     * @return the resolved string for the message code
     */
    String message(String code, String defaultMessage = null, List args = null) {
        message(code, defaultMessage, args, locale)
    }

    Locale getLocale() {
        def locale = GrailsWebRequest.lookup()?.getLocale()
        if (locale == null) {
            locale = Locale.getDefault()
        }
        return locale
    }

    String message(String code, String defaultMessage, List args, Locale locale) {

        def msg = messageSource.getMessage(code, args?.toArray(), defaultMessage, locale)

        if (msg == null || msg == defaultMessage) {
            log.debug("No i18n messages specified for code: ${code}")
            msg = defaultMessage
        }

        return msg
    }

    /**
     * Method to look like g.message
     * @param args
     * @return
     */
    String message(Map args) {
        return message(args.code, args.default, args.attrs)
    }
}
