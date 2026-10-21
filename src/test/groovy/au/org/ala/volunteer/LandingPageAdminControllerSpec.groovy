package au.org.ala.volunteer

import grails.testing.gorm.DataTest
import grails.testing.web.controllers.ControllerUnitTest
import org.springframework.mock.web.MockMultipartFile
import spock.lang.Specification

class LandingPageAdminControllerSpec extends Specification implements ControllerUnitTest<LandingPageAdminController>, DataTest {

    def setup() {
        mockDomains(LandingPage)
    }

    void "uploadImage clears hero image when clear action is submitted"() {
        given:
        def landingPage = createLandingPage('existing.png')
        def fileUploadService = Mock(FileUploadService)
        controller.fileUploadService = fileUploadService
        params.id = landingPage.id.toString()
        params['clear-hero'] = 'Reset'

        when:
        controller.uploadImage()

        then:
        0 * fileUploadService._
        LandingPage.get(landingPage.id).landingPageImage == null
        flash.message == 'Image removed.'
        response.redirectedUrl == "/admin/landingPage/editImage/${landingPage.id}"
    }

    void "uploadImage stores image when upload action is submitted with a file"() {
        given:
        def landingPage = createLandingPage('existing.png')
        def fileUploadService = Mock(FileUploadService)
        controller.fileUploadService = fileUploadService
        params.id = landingPage.id.toString()
        params['save-hero'] = 'Upload'
        request.addFile(new MockMultipartFile('heroImage', 'hero.png', 'image/png', 'image-bytes'.bytes))

        when:
        controller.uploadImage()

        then:
        1 * fileUploadService.uploadImage('landingPage', _) >> new File('uploaded.png')
        LandingPage.get(landingPage.id).landingPageImage == 'uploaded.png'
        flash.message == 'Image uploaded.'
        response.redirectedUrl == "/admin/landingPage/editImage/${landingPage.id}"
    }

    void "uploadImage shows message and does not upload when no file is selected"() {
        given:
        def landingPage = createLandingPage('existing.png')
        def fileUploadService = Mock(FileUploadService)
        controller.fileUploadService = fileUploadService
        params.id = landingPage.id.toString()
        params['save-hero'] = 'Upload'

        when:
        controller.uploadImage()

        then:
        0 * fileUploadService.uploadImage(_, _)
        LandingPage.get(landingPage.id).landingPageImage == 'existing.png'
        flash.message == 'Select an image before uploading.'
        response.redirectedUrl == "/admin/landingPage/editImage/${landingPage.id}"
    }

    private LandingPage createLandingPage(String imageName) {
        new LandingPage(
                title: 'Test landing page',
                shortUrl: "test-${System.nanoTime()}",
                enabled: true,
                landingPageImage: imageName
        ).save(flush: true, failOnError: true)
    }
}



