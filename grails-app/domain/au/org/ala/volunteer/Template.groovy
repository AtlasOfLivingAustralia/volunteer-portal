package au.org.ala.volunteer

import net.kaleidos.hibernate.usertype.JsonbMapType

class Template implements Serializable {

    String name
    String viewName  //this should be the GSP in use for this template
    String fieldOrder = "[]" // not used - consider removing
    String author
    Map<String, String> viewParams
    Map viewParams2 // Like view params but can store hierarchical data
    Boolean supportMultipleTranscriptions

    static hasMany = [project: Project]

    static mapping = {
        version false
        viewParams2 type: JsonbMapType
    }

    static constraints = {
        author maxSize: 200, nullable: true
        name maxSize: 200
        viewName nullable: true
        viewParams nullable: true
        fieldOrder nullable: true
        supportMultipleTranscriptions defaultValue: 'false'
    }

    public String toString() {
        return name
    }
}
