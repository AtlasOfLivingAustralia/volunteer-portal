package au.org.ala.volunteer

class ProjectForumWatchList {

    Project project

    static hasMany = [users:User]

    static transients = ['containsUser']

    static constraints = {
        project nullable:false
    }

    boolean containsUser(User user) {
        if (users) {
            return users.contains(user)
        }
        return false
    }
}
