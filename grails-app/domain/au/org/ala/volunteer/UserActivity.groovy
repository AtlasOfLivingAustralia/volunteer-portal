package au.org.ala.volunteer

class UserActivity {

    String userId
    String lastRequest
    Date timeLastActivity
    Date timeFirstActivity

    static constraints = {
        userId nullable: false
        lastRequest nullable: false, maxSize: 4096
        timeLastActivity nullable: false
        timeFirstActivity nullable: false
    }

    static mapping = {
        lastRequest length: 4096
    }

}
