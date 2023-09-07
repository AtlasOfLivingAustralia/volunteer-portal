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

    static mapping = {
        role fetch: 'join'
    }

    /**
     * Returns the institution associated with this user role. If the role is at the institution level, it returns that
     * institution. If it is at the project level, it returns the institution for the project.
     * In the case there are no project or instutition values (legacy site wide role), null is returned.
     * @return the institution object related to this role. Null if no value for legacy side wide roles.
     */
    Institution getLinkedInstitution() {
        if (institution) return institution
        else if (project) {
            return project?.institution
        } else {
            return null
        }
    }

    @Override
    String toString() {
        String roleLevel;
        if (project) {
            roleLevel = "project: ${project.name}"
        } else if (institution) {
            roleLevel = "institution: ${institution.name}"
        } else {
            roleLevel = "Site Wide"
        }
        return "User Role [name: ${role.name}, user: ${user.displayName}, roleLevel: ${roleLevel}]"
    }
}
