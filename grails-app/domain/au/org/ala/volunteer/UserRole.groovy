package au.org.ala.volunteer

class UserRole {

    User user
    Role role
    Project project
    Institution institution

    static constraints = {
        user nullable: false
        role nullable: false
        project nullable: true
        institution nullable: true
    }

}
