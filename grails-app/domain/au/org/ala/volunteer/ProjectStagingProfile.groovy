package au.org.ala.volunteer

class ProjectStagingProfile {

    Project project

    static hasMany = [fieldDefinitions:StagingFieldDefinition]
    static belongsTo = [project:Project]

    static constraints = {
        project nullable: false
    }
}
