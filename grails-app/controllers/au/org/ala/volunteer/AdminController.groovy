package au.org.ala.volunteer

class AdminController {

    def authService
    def taskService
    def ROLE_ADMIN = grailsApplication.config.auth.admin_role

    def index = {
        checkAdmin()
    }

    def mailingList = {
        if (checkAdmin()) {
            def userIds = User.all.collect{ it.userId }
            def list = userIds.join(";\n")
            render(text:list, contentType: "text/plain")
        }
    }

    boolean checkAdmin() {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(ROLE_ADMIN)) {
            return true;
        }

        flash.message = "You do not have permission to view this page (${ROLE_ADMIN} required)"
        redirect(uri:"/")
    }

}
