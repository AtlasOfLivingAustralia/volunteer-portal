package au.org.ala.volunteer

class ProjectType implements Serializable {

    String name
    String label
    String description

    static final String PROJECT_TYPE_CAMERATRAP = 'cameratraps'
    static final String PROJECT_TYPE_FIELDNOTES = 'fieldnotes'
    static final String PROJECT_TYPE_SPECIMEN = 'specimens'
    static final String PROJECT_TYPE_AUDIO = 'audio'

    static hasMany = [projects: Project, landingPages: LandingPage]

    static constraints = {
        name nullable: false
        label nullable: false
        description nullable: true
    }

    String toString() {
        return name
    }

    String getKey() {
        return name ?: ''
    }

    boolean supportsMultipleTranscriptions() {
        return (this.name.equalsIgnoreCase(PROJECT_TYPE_CAMERATRAP) || this.name.equalsIgnoreCase(PROJECT_TYPE_AUDIO))
    }

}
