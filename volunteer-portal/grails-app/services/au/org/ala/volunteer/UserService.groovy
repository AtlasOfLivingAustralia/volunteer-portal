package au.org.ala.volunteer

class UserService {

    def authService

    static transactional = true

    def serviceMethod() {}

   /**
    * Update a user stats
    * @param userId
    * @return
    */
    def updateUserTranscribedCount(String userId){
      def transcribedCount = Task.countByFullyTranscribedBy(userId)
      User.executeUpdate("""update User u set u.transcribedCount = :transcribedCount where u.userId = :userId """,
        [transcribedCount:transcribedCount, userId:userId])
    }

   /**
    * Update a user stats
    * @param userId
    * @return
    */
    def updateUserValidatedCount(String userId){
      def validatedCount = Task.countByFullyTranscribedByAndFullyValidatedByIsNotNull(userId)
      User.executeUpdate("""update User u set u.validatedCount = :validatedCount where u.userId = :userId """,
        [validatedCount:validatedCount, userId:userId])
    }

   /**
    * Register the current user in the system.
    */
    def registerCurrentUser = {
      def userId = authService.username()
      def displayName = authService.displayName()
      println("Checking user is registered: " + userId+", " + displayName )
      if(userId){
        if(User.findByUserId(userId)==null){
          User user = new User()
          user.userId = userId
          user.created = new Date()
          user.displayName = displayName
          user.save(flush:true)
        }
      }
    }
}
