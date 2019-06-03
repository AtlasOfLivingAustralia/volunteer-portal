package au.org.ala.volunteer

import org.apache.commons.lang.builder.HashCodeBuilder

class LatestTranscribers implements Serializable {

    String fullyTranscribedBy
    Date maxDate

    static belongsTo = [project: Project]

    static mapping = {
        version false
        id composite: ['fullyTranscribedBy', 'maxDate']
    }

    static constraints = {
    }

    boolean equals(other) {
        if (!(other instanceof LatestTranscribers)) {
            return false
        }

        other.fullyTranscribedBy == fullyTranscribedBy && other.maxDate == maxDate
    }

    int hashCode() {
        def builder = new HashCodeBuilder()
        builder.append fullyTranscribedBy
        builder.append maxDate
        builder.toHashCode()
    }
}
