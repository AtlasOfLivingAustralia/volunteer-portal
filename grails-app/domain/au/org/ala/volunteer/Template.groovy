package au.org.ala.volunteer

class Template implements Serializable {

    String name
    String viewName  //this should be the GSP in use for this template
    String fieldOrder = "[]" // not used - consider removing
    String author
    Map<String, String> viewParams

    static hasMany = [project: Project]

    static mapping = {
        version false
    }

    static constraints = {
        author maxSize: 200, nullable: true
        name maxSize: 200
        viewName nullable: true
        viewParams nullable: true
        fieldOrder nullable: true
    }

    public String toString() {
        return name
    }
}
