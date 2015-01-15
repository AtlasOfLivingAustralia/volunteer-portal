package au.org.ala.volunteer

class Task implements Serializable {

    //Project project
    String externalIdentifier
    String externalUrl
    String fullyTranscribedBy
    Date dateFullyTranscribed
    String fullyValidatedBy
    Date dateFullyValidated
    Boolean isValid
    Integer viewed = -1
    Date created
    Date dateLastUpdated
    Long lastViewed
    String lastViewedBy

    static belongsTo = [project: Project]
    static hasMany = [multimedia: Multimedia, viewedTasks: ViewedTask, fields: Field, comments: TaskComment]

    static mapping = {
        version false
        multimedia cascade: 'all,delete-orphan'
        viewedTasks cascade: 'all,delete-orphan'
        fields cascade: 'all,delete-orphan'
        comments cascade: 'all,delete-orphan'
    }

    static constraints = {
        externalIdentifier nullable: true
        externalUrl nullable: true
        fullyTranscribedBy nullable: true
        dateFullyTranscribed nullable: true
        fullyValidatedBy nullable: true
        dateFullyValidated nullable: true
        isValid nullable: true
        viewed nullable: true
        created nullable: true
        dateLastUpdated nullable: true
        lastViewed nullable: true
        lastViewedBy nullable: true
    }

}
