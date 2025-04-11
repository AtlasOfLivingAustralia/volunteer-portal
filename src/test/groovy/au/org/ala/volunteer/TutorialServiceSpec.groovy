package au.org.ala.volunteer

import grails.testing.services.ServiceUnitTest
import spock.lang.Specification
import org.springframework.web.multipart.MultipartFile

class TutorialServiceSpec extends Specification implements ServiceUnitTest<TutorialService> {

    def setup() {
        service.metaClass.getTutorialDirectory = { -> "/mock/tutorials" } // Mock the directory path
    }

    def "uploadTutorialFile saves file with correct extension"() {
        given:
        def mockFile = Mock(MultipartFile)
        mockFile.originalFilename >> "tutorial"
        def mockNewFile = Mock(File)
        mockNewFile.name >> "tutorial.pdf"
        GroovySpy(File, global: true, useObjenesis: true) // Mock File constructor globally
        new File("/mock/tutorials/tutorial.pdf") >> mockNewFile

        when:
        def result = service.uploadTutorialFile(mockFile)

        then:
        1 * mockFile.transferTo(mockNewFile)
        result.name == "tutorial.pdf"
    }

    def "deleteTutorial removes file if it exists"() {
        given:
        def mockNewFile = Mock(File)
        mockNewFile.name >> "tutorial.pdf"
        GroovySpy(File, global: true, useObjenesis: true) // Mock File constructor globally
        new File("/mock/tutorials/tutorial.pdf") >> mockNewFile
        mockNewFile.exists() >> true

        when:
        def result = service.deleteTutorial("tutorial.pdf")

        then:
        1 * mockNewFile.delete()
        result == true
    }

    def "deleteTutorial returns false if file does not exist"() {
        given:
        service.metaClass.createFilePath = { name -> "/mock/tutorials/${name}" }
        def mockFile = Mock(File)
        mockFile.exists() >> false
        new File(_) >> mockFile

        when:
        def result = service.deleteTutorial("tutorial.pdf")

        then:
        result == false
    }

    def "renameTutorial renames file if new name does not exist"() {
        given:
        service.metaClass.createFilePath = { name -> "/mock/tutorials/${name}" }

        def mockOldFile = Mock(File)
        def mockNewFile = Mock(File)
        GroovySpy(File, global: true, useObjenesis: true)
        mockOldFile.exists() >> true
        mockNewFile.exists() >> false
        new File("/mock/tutorials/oldname.pdf") >> mockOldFile
        new File("/mock/tutorials/newname.pdf") >> mockNewFile

        when:
        service.renameTutorial("oldname.pdf", "newname.pdf")

        then:
        1 * mockOldFile.renameTo(mockNewFile)
    }

    def "generateTutorialFilename generates correct filename for tutorial with institution"() {
        given:
        def mockInstitution = Mock(Institution)
        mockInstitution.name >> "Test Institution"
        def mockTutorial = Mock(Tutorial)
        mockTutorial.id >> 123
        mockTutorial.institution >> mockInstitution
        service.institutionService = Mock(InstitutionService) {
            generateAcronym(_) >> "TI"
        }

        when:
        def result = service.generateTutorialFilename(mockTutorial)

        then:
        result ==~ /ti_123_tutorial_\d+\.pdf/
    }
}