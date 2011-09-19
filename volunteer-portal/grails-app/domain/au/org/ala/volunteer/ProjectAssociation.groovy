package au.org.ala.volunteer

import org.apache.commons.lang.builder.EqualsBuilder
import org.apache.commons.lang.builder.HashCodeBuilder

class ProjectAssociation implements Serializable {

  Project project
  String entityUid

  static mapping = {
    version false
  }

  static constraints = {
    entityUid maxSize: 200
  }

    public String toString() {
        return entityUid
    }
}
