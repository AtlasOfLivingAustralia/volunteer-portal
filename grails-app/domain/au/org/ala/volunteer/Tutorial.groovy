package au.org.ala.volunteer

import org.apache.commons.lang3.builder.ToStringBuilder

/**
 * Tutorial Domain class.
 */
class Tutorial {

    String name
    String filename
    String description
    boolean isActive
    Institution institution

    Date dateCreated
    Date lastUpdated
    User createdBy
    User updatedBy

    static belongsTo = [Project]
    static hasMany = ['projects': Project]


    static constraints = {
        name nullable: false, maxSize: 130
        filename nullable: false, maxSize: 255
        description nullable: true, maxSize: 255
        isActive nullable: false
        institution nullable: true
        dateCreated nullable: true
        lastUpdated nullable: true
        createdBy nullable: true
        updatedBy nullable: true
    }

    static mapping = {
        autoTimestamp false
        name column: 'tutorial_name'
        isActive defaultValue: true
        projects joinTable: [name: 'tutorial_projects', key: 'tutorial_id']
    }

    /**
     * Ensures the date created is defaulted to the current datetime.
     * @return
     */
    def beforeInsert() {
        if (!dateCreated) {
            dateCreated = new Date()
        }
    }

    def beforeUpdate() {
        if (!lastUpdated) {
            lastUpdated = new Date()
        }
    }

    @Override
    String toString() {
        return new ToStringBuilder(this)
                .append("filename", filename)
                .append("id", id)
                .append("name", name)
                .append("isActive", isActive)
                .append("dateCreated", dateCreated)
                .toString();
    }
}
