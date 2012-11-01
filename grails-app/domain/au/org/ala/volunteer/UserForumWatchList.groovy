package au.org.ala.volunteer

class UserForumWatchList {

    User user

    static hasMany = [topics:ForumTopic]

    static belongsTo = [user:User]

    static constraints = {
        user nullable: false

    }
}
