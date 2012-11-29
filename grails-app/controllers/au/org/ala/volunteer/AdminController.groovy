package au.org.ala.volunteer

import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.MultipartFile

class AdminController {

    def authService
    def taskService
    def grailsApplication
    def tutorialService

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
        if (currentUser != null && authService.userInRole(CASRoles.ROLE_ADMIN)) {
            return true;
        }

        flash.message = "You do not have permission to view this page (${CASRoles.ROLE_ADMIN} required)"
        redirect(uri:"/")
    }

    def tutorialManagement() {
        def tutorials = tutorialService.listTutorials()
        [tutorials: tutorials]
    }

    def uploadTutorial() {

        if(request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('tutorialFile')
            if (f != null) {
                def allowedMimeTypes = ['application/pdf']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    flash.message = "The file must be one of: ${allowedMimeTypes}"
                    redirect(action:'tutorialManagement')
                    return;
                }

                try {
                    tutorialService.uploadTutorialFile(f)
                } catch (Exception ex) {
                    flash.message = "Failed to upload tutorial file: " + ex.message;
                }

            }
        }

        redirect(action:'tutorialManagement')
    }

    def deleteTutorial() {
        def filename = params.tutorialFile
        if (filename) {
            try {
                tutorialService.deleteTutorial(filename)
            } catch (Exception ex) {
               flash.message ="Failed to delete tutorial file: " + ex.message
            }
        }
        redirect(action:'tutorialManagement')
    }

    def renameTutorial() {
        def filename = params.tutorialFile
        def newName = params.newName

        if (filename && newName) {
            try {
                tutorialService.renameTutorial(filename, newName)
            } catch (Exception ex) {
               flash.message ="Failed to rename tutorial file: " + ex.message
            }
        }

        redirect(action:'tutorialManagement')

    }

}
