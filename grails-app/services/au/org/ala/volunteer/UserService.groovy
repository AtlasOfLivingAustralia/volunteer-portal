package au.org.ala.volunteer

class UserService {

    def authService

    static transactional = true

    def serviceMethod() {}

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
