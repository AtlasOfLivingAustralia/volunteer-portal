package au.org.ala.volunteer

import org.apache.commons.lang.builder.EqualsBuilder
import org.apache.commons.lang.builder.HashCodeBuilder

class Role implements Serializable {

    String name

    static mapping = {
    version false
    }

    static constraints = {
        name nullable: false
    }

}
