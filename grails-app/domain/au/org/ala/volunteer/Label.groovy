package au.org.ala.volunteer

import groovy.transform.ToString

@ToString()
class Label {

    String category
    String value

    static belongsTo = Project
    static hasMany = [projects: Project]

    static constraints = {
        category unique: 'value'
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (!(o instanceof Label)) return false

        Label label = (Label) o

        if (category != label.category) return false
        if (value != label.value) return false

        return true
    }

    int hashCode() {
        int result
        result = (category != null ? category.hashCode() : 0)
        result = 31 * result + value.hashCode()
        return result
    }
}
