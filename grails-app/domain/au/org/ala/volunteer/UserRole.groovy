package au.org.ala.volunteer

class UserRole {

    User user
    Role role
    Project project
    Institution institution
    User createdBy
    Date dateCreated

    static constraints = {
        user nullable: false
        role nullable: false
        project nullable: true
        institution nullable: true
        createdBy nullable: true
        dateCreated nullable: true
    }

}
