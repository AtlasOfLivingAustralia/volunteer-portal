package au.org.ala.volunteer

class Picklist implements Serializable {

    String name
    String clazz
    static mapping = {
      version false
    }
    static constraints = {
        clazz nullable: true
    }
}
