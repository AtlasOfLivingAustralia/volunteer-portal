package au.org.ala.volunteer

/**
 * @deprecated
 */
class LogService {

    static transactional = false

    /**
     * @deprecated
     * @param message
     * @return
     */
    def log(String message) {
        String fullMsg = "[${new Date().format("yyyy-MM-dd HH:mm:ss")}] ${message}"
        println fullMsg
    }

}
