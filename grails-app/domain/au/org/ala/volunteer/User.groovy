package au.org.ala.volunteer

class User {

  String userId
  String email
  String displayName
  Integer transcribedCount = 0   //the number of tasks completed by the user
  Integer validatedCount = 0     // the number of task completed by this user and then validated by a validator
  Date created               //set to the date when the user first contributed

  static hasMany = [userRoles:UserRole, achievementAwards: AchievementAward]

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

  @Override
  boolean equals(o) {
    if (this.is(o)) return true
    if ( !instanceOf(o, User) ) return false

    // We would cast here, but there is no guarantee that o isn't a gorm proxy, so it might throw a classcastexception
    def that = o

    if (userId != that.userId) return false

    return true
  }

  /**
   * Check that o is an instanceOf aClass, using the gorm .instanceOf(aClass) method but
   * swallowing the MissingMethodException if o isn't a gorm object.
   *
   * @param o The Object to check
   * @param aClass The type to check
   * @return true if o is an instanceof aClass, false otherwise
   */
  static boolean instanceOf(o, Class<?> aClass) {
    if (o == null) return false // short circuit try block
    try {
      return o.instanceOf(aClass)
    } catch (MissingMethodException e) {
      return aClass.isInstance(o)
    }
  }

  @Override
  int hashCode() {
    Objects.hash(userId)
  }
}
