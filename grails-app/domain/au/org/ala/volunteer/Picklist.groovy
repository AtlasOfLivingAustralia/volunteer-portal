package au.org.ala.volunteer

class Picklist implements Serializable {

    String name
    String clazz

    String getUiLabel() {
        if (clazz) {
            "$name ($clazz)"
        } else {
            name
        }
    }

    static mapping = {
      version false
    }
    static constraints = {
        clazz nullable: true
    }
}
