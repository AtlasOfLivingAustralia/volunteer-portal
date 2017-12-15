package au.org.ala.volunteer

class TemplateField {

    DarwinCoreField fieldType
    String fieldTypeClassifier
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

    def getUiLabel() {
        label ?: fieldType.label
    }

    static mapping = {
        version false
    }

    static constraints = {
        fieldTypeClassifier nullable: true
        label nullable: true
        defaultValue maxSize: 200, nullable: true
        mandatory nullable: true
        multiValue nullable: true
        helpText nullable:true, widget:'textarea', maxSize: 2000
        validationRule nullable:true
        template nullable: true
        displayOrder nullable: true
        layoutClass nullable: true
    }

}

  
