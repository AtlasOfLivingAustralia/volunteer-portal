package au.org.ala.volunteer

class LabelCategory {

    Long id
    String name
    Date dateCreated
    Long createdBy

    static hasMany = [labels: Label]

    static constraints = {
        name nullable: false
        dateCreated nullable: false
        createdBy nullable: false
    }

    static mapping = {
        //dateCreated defaultValue: new Date()
        //createdBy defaultValue: 0L
    }

    String toString() {
        return "LabelCategory: [id: ${id}, name: ${name}, dateCreated: ${dateCreated}, createdBy: ${createdBy}]".toString()
    }
}
