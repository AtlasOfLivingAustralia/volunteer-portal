package au.org.ala.volunteer

class Field implements Serializable {

  Task task
  String name
  String value
  Integer recordIdx
  String transcribedByUserId
  String validatedByUserId
  boolean superceded = false
  Date created = new Date()
  Date updated = new Date()

  static mapping = {
    version false
  }

  static constraints = {
    task nullable: true
    name maxSize: 200
    value type:'text'
    recordIdx nullable: true
    transcribedByUserId maxSize: 200
    validatedByUserId nullable: true, maxSize: 200
    value nullable: true
    superceded nullable: true
  }
}
