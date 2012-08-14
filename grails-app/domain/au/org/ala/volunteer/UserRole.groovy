package au.org.ala.volunteer

class UserRole {

    User user
    Role role
    Project project

    static constraints = {
        user nullable: false
        role nullable: false
        project nullable: true
    }

}
