package au.org.ala.volunteer

class UserService {

    def authService

    static transactional = true

    def serviceMethod() {}

    def registerCurrentUser = {
      def userId = authService.username()
      if(userId){
        if(User.findByUserId(userId)==null){
          User user = new User()
          user.userId = userId
          user.created = new Date()
          user.save(flush:true)
        }
      }
    }
}
