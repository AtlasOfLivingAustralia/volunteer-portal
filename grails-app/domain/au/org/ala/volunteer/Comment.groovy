package au.org.ala.volunteer

class Comment {

  String comment
  Integer relatesToField
  Integer relatesToRecord
  Integer replyTo
  String userId
  Task task
  Field field

  static mapping = {
    version false
  }

  static constraints = {
    comment nullable: true
    relatesToField nullable: true
    relatesToRecord nullable: true
    replyTo nullable: true
    userId maxSize: 200
    field nullable: true
    task nullable: true
  }
}
