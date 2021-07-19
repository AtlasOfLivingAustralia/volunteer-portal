package au.org.ala.volunteer

import grails.test.mixin.TestFor
import org.grails.plugins.testing.GrailsMockMultipartFile
import spock.lang.Specification

@TestFor(AdminController)
class AdminControllerSpec extends Specification {

    boolean admin = true

    def setup() {
        def userServiceStub = Stub(UserService) {
            isAdmin() >> admin
        }
        controller.userService = userServiceStub
    }

    void "Test when tutorialManagement action is returning the correct model"() {
        given:"The tutorial service list method"
        def tutorialServiceStub = Stub(TutorialService) {
            listTutorials(_) >> []
        }

        and:"Add tutorial service to controller"
        controller.tutorialService = tutorialServiceStub

        when:"The tutorialManagement action is executed"
        controller.tutorialManagement()

        then:"The model is correct"
        !model.tutorials
    }

    void "Test tutorial file upload is valid"() {
        given:"Define file parameters"
        def fileContentType = "application/pdf"
        def fileName = "Testfile.pdf"
        def fileContentBytes = '123' as byte[]
        def multipartFile = new GrailsMockMultipartFile('tutorialFile', fileName, fileContentType, fileContentBytes)
        request.addFile(multipartFile)

        def tutorialServiceStub = Stub(TutorialService) {
            uploadTutorialFile(_) >> null
        }

        and:"Add tutorial service to controller"
        controller.tutorialService = tutorialServiceStub

        when:"File is uploaded"
        controller.uploadTutorial()

        then:"User is redirected to the correct page"
        response.redirectedUrl == "/admin/tutorialManagement"
        flash.message == "Tutorial uploaded successfully"
    }

    void "Test invalid tutorial file type is not uploaded"() {
        given:"Define file parameters"
        def fileContentType = "application/vnd.ms-excel"
        def fileName = "Testfile.xlsx"
        def fileContentBytes = '123' as byte[]
        def multipartFile = new GrailsMockMultipartFile('tutorialFile', fileName, fileContentType, fileContentBytes)
        request.addFile(multipartFile)

        when:"File is uploaded"
        controller.uploadTutorial()

        then:"User is redirected to the correct page"
        def allowedMimeTypes = ['application/pdf']
        response.redirectedUrl == "/admin/tutorialManagement"
        flash.message == "The file must be one of the following file types: ${allowedMimeTypes}"
    }

    void "Test invalid tutorial file name is not uploaded"() {
        given:"Define file parameters"
        response.reset()
        def fileContentType = "application/pdf"
        //def fileName = "T:\\location\\directory\\Testfil/;{}e.pdf"
        def fileName = "`Testfile'.pdf"
        def fileContentBytes = '123' as byte[]
        def multipartFile = new GrailsMockMultipartFile('tutorialFile', fileName, fileContentType, fileContentBytes)
        request.addFile(multipartFile)

        when:"File is uploaded"
        controller.uploadTutorial()

        then:"User is redirected to the correct page"
        response.redirectedUrl == "/admin/tutorialManagement"
        flash.message == "Filename includes illegal characters (one or more of the following: @,#,\$,%,^,*,=,<,>,{,},\\,/,|,',\",;,:,?)" +
                ". <br />Please rename the file and try again."
    }

}
