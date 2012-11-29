package au.org.ala.volunteer

class StagingFieldDefinition {

    ProjectStagingProfile profile
    String fieldName
    FieldDefinitionType fieldDefinitionType
    String format

    static belongsTo = [profile:ProjectStagingProfile]

    static constraints = {
        profile nullable: false
        fieldName nullable: false, blank: false
        fieldDefinitionType nullable: true
        format nullable: true
    }

}
