package au.org.ala.volunteer

class TemplateField {

    DarwinCoreField dataType
    String name
    String defaultValue
    FieldCategory category
    FieldType type
    Boolean mandatory
    Boolean multiValue
    String validationRule
    Template template

    static mapping = {
        version false
    }

    static constraints = {
        dataType maxSize: 200
        name nullable: true
        defaultValue maxSize: 200
        mandatory nullable: true
        multiValue nullable: true
        validationRule nullable: true
        template nullable: true
    }

}

  
