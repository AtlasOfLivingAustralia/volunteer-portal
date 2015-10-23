package au.org.ala.volunteer

class LogService {

    static transactional = false

    def log(String message) {
        String fullMsg = "[${new Date().format("yyyy-MM-dd HH:mm:ss")}] ${message}"
        println fullMsg
    }

}
