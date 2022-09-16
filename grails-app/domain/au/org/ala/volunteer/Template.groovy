package au.org.ala.volunteer

import net.kaleidos.hibernate.usertype.JsonbMapType

class Template implements Serializable {

    String name
    String viewName  //this should be the GSP in use for this template
    String fieldOrder = "[]" // not used - consider removing
    String author
    Map<String, String> viewParams
    Map viewParams2 // Like view params but can store hierarchical data
    Boolean supportMultipleTranscriptions = false
    Boolean isGlobal = false
    Boolean isHidden = false

    static hasMany = [projects: Project]

    static mapping = {
        version false
        viewParams fetch: 'join'
        viewParams2 type: JsonbMapType
    }

    static constraints = {
        author maxSize: 200, nullable: true
        name maxSize: 200
        viewName nullable: true
        viewParams nullable: true
        viewParams2 nullable: true
        fieldOrder nullable: true
        supportMultipleTranscriptions defaultValue: 'false'
        isGlobal defaultValue: 'false'
        isHidden defaultValue: 'false'
    }

    String toString() {
        //return "Template: ${name}, [view: ${viewName}, isGlobal: ${isGlobal}, isHidden: ${isHidden}, Project Count: ${projects.size()}]"
        return "${name}" + (isGlobal ? " (Global)" : "") + (isHidden ? " (Hidden)" : "") + (projects.size() == 0 ? " (Unassigned)" : "")
    }

    def getTemplateMap() {
        return [id: id, name: name, isGlobal: isGlobal, isHidden: isHidden]
    }

}
