package au.org.ala.volunteer

class LabelCategory {

    Long id
    String name
    Boolean isDefault
    String labelColour
    Date updatedDate
    Long createdBy

    static hasMany = [labels: Label]

    static constraints = {
        name nullable: false
        labelColour nullable: true
        isDefault nullable: false
        updatedDate nullable: false
        createdBy nullable: false
    }

    static mapping = {
        isDefault defaultValue: false
        updatedDate defaultValue: new Date()
        createdBy defaultValue: 0L
    }

    String toString() {
        return """
            LabelCategory: [id: ${id}, name: ${name}, isDefault: ${isDefault}, updatedDate: ${updatedDate}, 
            createdBy: ${createdBy}]
        """.stripIndent()
    }
}
