package au.org.ala.volunteer

class User {

  Date created
  Integer recordsTranscribedCount
  Integer transcribedValidatedCount
  String userId

  static hasMany = [roles:Role]

  static mapping = {
    table 'vp_user'
    version false
  }

  static constraints = {
    created maxSize: 19
    recordsTranscribedCount nullable: true
    transcribedValidatedCount nullable: true
    userId maxSize: 200
  }
}
