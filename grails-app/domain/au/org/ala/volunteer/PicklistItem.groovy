package au.org.ala.volunteer

class PicklistItem implements Serializable {

    Picklist picklist
    Integer index = 0
    String key
    String value
    String institutionCode

    static mapping = {
        version false
        index defaultValue: "0"
        value type: 'text'
        sort 'index'
        picklist index: 'picklist_item_picklist_id_institution_code_idx'
        institutionCode index: 'picklist_item_picklist_id_institution_code_idx'
    }

    static constraints = {
        key maxSize: 1024, nullable: true
        institutionCode nullable: true
    }
}
