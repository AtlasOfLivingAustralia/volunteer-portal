package au.org.ala.volunteer

class Task {

  Project project
  String externalIdentifier
  String externalUrl
  Boolean fullyTranscribed = false
  Boolean fullyValidated = false
  Integer viewed = -1
  Date created

  static hasMany = [multimedia: Multimedia, viewedTasks: ViewedTask, fields: Field]

  static mapping = {
    version false
  }

  static constraints = {
    externalIdentifier nullable: true
    externalUrl nullable: true
    fullyTranscribed nullable: true
    fullyValidated nullable: true
    viewed nullable: true
    created nullable: true
  }
}
