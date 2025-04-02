package au.org.ala.volunteer

import org.apache.commons.lang3.builder.ToStringBuilder

/**
 * Tutorial Domain class.
 */
class Tutorial {

    long id
    String tutorialName
    String filename
    String description
    boolean isActive
    //Institution institution
    Long institutionId

    Date dateCreated
    Date dateUpdated
    // REPLACE WITH LONGS - HIBERNATE DOESNT LIKE THIS
    //User createdBy
    //User updatedBy
    long createdBy
    long updatedBy

    static belongsTo = [Project]
    static hasMany = ['projectList': Project]


    static constraints = {
        name nullable: false, maxSize: 60
        filename nullable: false, maxSize: 255
        description nullable: true, maxSize: 255
        isActive nullable: false
        institutionId nullable: true

        dateCreated nullable: false
        dateUpdated nullable: true
        createdBy nullable: false
        updatedBy nullable: true
    }

    static mapping = {
        //name column: 'tutorial_name'
        isActive defaultValue: true
    }

    @Override
    String toString() {
        return new ToStringBuilder(this)
                .append("filename", filename)
                .append("id", id)
                .append("name", name)
                .append("isActive", isActive)
                .toString();
    }
}
