package au.org.ala.volunteer

class Role implements Serializable {

    String name

    static mapping = {
    version false
    }

    static constraints = {
        name nullable: false
    }

}
