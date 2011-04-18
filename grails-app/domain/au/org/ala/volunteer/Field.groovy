package au.org.ala.volunteer

class Field {

  Task task
  String name
  String value
  Integer recordIdx
  String transcribedByUserId
  String validatedByUserId
  boolean superceded = false

  static mapping = {
    version false
  }

  static constraints = {
    task nullable: true
    name maxSize: 200
    recordIdx nullable: true
    transcribedByUserId maxSize: 200
    validatedByUserId nullable: true, maxSize: 200
    value nullable: true
    superceded nullable: true
  }
}
