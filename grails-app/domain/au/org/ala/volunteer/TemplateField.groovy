package au.org.ala.volunteer

class TemplateField {

    DarwinCoreField fieldType
    String label
    String defaultValue
    FieldCategory category
    FieldType type
    Boolean mandatory
    Boolean multiValue
    String helpText
    String validationRule
    Template template
    Integer displayOrder
    String layoutClass

    static mapping = {
        version false
    }

    static constraints = {
        fieldType maxSize: 200
        label nullable: true
        defaultValue maxSize: 200
        mandatory nullable: true
        multiValue nullable: true
        helpText nullable:true, widget:'textarea', maxSize: 2000
        validationRule nullable:true
        template nullable: true
        displayOrder nullable: true
        layoutClass nullable: true
    }

}

  
