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

  boolean equals(o) {
    if (this.is(o)) return true
    if ( !DomainUtils.instanceOf(o, User) ) return false

    // We would cast here, but there is no guarantee that o isn't a gorm proxy, so it might throw a classcastexception
    def that = o

    if (userId != that.userId) return false

    return true
  }

  int hashCode() {
    Objects.hash(userId)
  }
}
