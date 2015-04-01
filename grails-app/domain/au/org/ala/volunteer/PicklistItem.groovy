package au.org.ala.volunteer

class PicklistItem implements Serializable {

    Picklist picklist
    String key
    String value
    String institutionCode

    static mapping = {
      version false
    }

    static constraints = {
        key nullable: true
        institutionCode nullable: true
    }
}
