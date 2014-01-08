package au.org.ala.volunteer

class ProjectType {

    String name
    String label
    String description

    static hasMany = [projects: Project]

    static constraints = {
        name nullable: false
        label nullable: false
        description nullable: true
    }

}
