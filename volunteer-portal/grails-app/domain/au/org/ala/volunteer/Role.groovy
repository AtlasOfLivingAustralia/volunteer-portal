package au.org.ala.volunteer

import org.apache.commons.lang.builder.EqualsBuilder
import org.apache.commons.lang.builder.HashCodeBuilder

class Role implements Serializable {

  User user
  String role

  static mapping = {
    version false
  }

  static constraints = {
    userId maxSize: 200
    role maxSize: 100
  }
}
