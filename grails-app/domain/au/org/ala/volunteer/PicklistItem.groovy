package au.org.ala.volunteer

class PicklistItem {

    Picklist picklist
    String key
    String value

    static mapping = {
      version false
    }

    static constraints = {
        key nullable: true
    }
}
