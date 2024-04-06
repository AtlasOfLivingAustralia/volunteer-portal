package au.org.ala.volunteer

import groovy.transform.ToString

@ToString()
class Label implements Serializable {

    Long id
    LabelCategory category
    String value
    Boolean isDefault
    Date updatedDate
    Long createdBy

    static belongsTo = [Project, LandingPage, LabelCategory]
    static hasMany = [projects: Project, landingPages: LandingPage]

    static mapping = {
        isDefault defaultValue: false
        updatedDate defaultValue: new Date()
        createdBy defaultValue: 0L
    }

    static constraints = {
        //category unique: 'value'
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (!(o instanceof Label)) return false

        Label label = (Label) o

        if (category.name != label.category.name) return false
        if (value != label.value) return false

        return true
    }

    int hashCode() {
        int result
        result = (category.name!= null ? category.name.hashCode() : 0)
        result = 31 * result + (value != null ? value.hashCode() : 0)
        return result
    }

    LinkedHashMap<String,Object> toMap() {
        [id: id, category: category.name, value: value]
    }

    @Override
    public String toString() {
        return "Label{" +
                "id=" + id +
                ", category='" + category.name + '\'' +
                ", value='" + value + '\'' +
                '}';
    }
}
