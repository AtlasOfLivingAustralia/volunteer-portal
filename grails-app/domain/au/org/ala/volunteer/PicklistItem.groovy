package au.org.ala.volunteer

class PicklistItem implements Serializable {

    Picklist picklist
    String key
    String value
    String institutionCode

    static mapping = {
      version false
        picklist index: 'picklist_item_picklist_id_institution_code_idx'
        institutionCode index: 'picklist_item_picklist_id_institution_code_idx'
    }

    static constraints = {
        key nullable: true
        institutionCode nullable: true
    }
}
