package au.org.ala.volunteer

class UserActivity {

    String userId
    String lastRequest
    String ip
    Date timeLastActivity
    Date timeFirstActivity

    static constraints = {
        userId nullable: false
        lastRequest nullable: false, maxSize: 4096
        timeLastActivity nullable: false
        timeFirstActivity nullable: false
        ip nullable: true
    }

    static mapping = {
        lastRequest length: 4096
    }

}
