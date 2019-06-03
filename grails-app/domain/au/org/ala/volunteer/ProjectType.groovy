package au.org.ala.volunteer

class ProjectType implements Serializable {

    String name
    String label
    String description

    static hasMany = [projects: Project]

    static constraints = {
        name nullable: false
        label nullable: false
        description nullable: true
    }

    public String toString() {
        return name
    }

    public String getKey() {
        return name ?: ''
    }

}
