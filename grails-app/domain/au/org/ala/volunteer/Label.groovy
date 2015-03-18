package au.org.ala.volunteer

class Label {

    String category
    String value

    static belongsTo = Project
    static hasMany = [projects: Project]

    static constraints = {
        category unique: 'value'
    }
}
