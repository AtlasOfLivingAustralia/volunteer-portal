package au.org.ala.volunteer

import groovy.transform.ToString

@ToString()
class Label implements Serializable {

    Long id
    String category
    String value

    static belongsTo = [Project, LandingPage]
    static hasMany = [projects: Project, landingPages: LandingPage]

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
        result = 31 * result + (value != null ? value.hashCode() : 0)
        return result
    }

    LinkedHashMap<String,Object> toMap() {
        [id: id, category: category, value: value]
    }


    @Override
    public String toString() {
        return "Label{" +
                "id=" + id +
                ", category='" + category + '\'' +
                ", value='" + value + '\'' +
                '}';
    }
}
