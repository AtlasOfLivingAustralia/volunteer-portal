package au.org.ala.volunteer

class User {

  String userId
  String email
  String displayName
  Integer transcribedCount = 0   //the number of tasks completed by the user
  Integer validatedCount = 0     // the number of task completed by this user and then validated by a validator
  Date created               //set to the date when the user first contributed

  static hasMany = [userRoles:UserRole]

  static mapping = {
    table 'vp_user'
    version false
  }

  static constraints = {
    created maxSize: 19
    transcribedCount nullable: true
    validatedCount nullable: true
    userId maxSize: 200
    email maxSize: 200
  }

}
