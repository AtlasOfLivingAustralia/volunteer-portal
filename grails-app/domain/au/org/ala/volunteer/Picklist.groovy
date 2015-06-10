package au.org.ala.volunteer

class Picklist implements Serializable {

    String name
    String fieldTypeClassifier

    String getUiLabel() {
        if (fieldTypeClassifier) {
            "$name ($fieldTypeClassifier)"
        } else {
            name
        }
    }

    static mapping = {
      version false
    }
    static constraints = {
        fieldTypeClassifier nullable: true
    }
}
