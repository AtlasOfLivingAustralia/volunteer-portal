package au.org.ala.volunteer

import grails.persistence.Entity

import javax.persistence.Table
import org.apache.commons.lang.builder.HashCodeBuilder

class LatestTranscribersTask implements Serializable {

    Long id
    Long taskId
    String externalIdentifier
    String externalUrl
    String fullyTranscribedBy
    Date dateFullyTranscribed
    Boolean isValid
    Integer viewed = -1
    Date created
    Date dateLastUpdated
    Long lastViewed
    String lastViewedBy

    static belongsTo = [project: Project]

    static hasMany = [multimedia: LatestTranscribersTaskMultimedia]

    static mapping = {
        version false
    }

    static constraints = {
        externalIdentifier nullable: true
        externalUrl nullable: true
        fullyTranscribedBy nullable: true
        dateFullyTranscribed nullable: true
        isValid nullable: true
        viewed nullable: true
        created nullable: true
        dateLastUpdated nullable: true
        lastViewed nullable: true
        lastViewedBy nullable: true
    }

}
