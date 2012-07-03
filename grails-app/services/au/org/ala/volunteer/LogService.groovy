package au.org.ala.volunteer

import org.codehaus.groovy.grails.commons.ApplicationHolder

class LogService {

    static transactional = true

    def log(String message) {
        String fullMsg = "[${new Date().format("yyyy-MM-dd HH:mm:ss")}] ${message}"
        println fullMsg
    }

}
