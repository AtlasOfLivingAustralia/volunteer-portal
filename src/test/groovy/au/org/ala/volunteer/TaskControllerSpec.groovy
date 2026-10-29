package au.org.ala.volunteer

import grails.testing.gorm.DataTest
import grails.testing.web.controllers.ControllerUnitTest
import groovy.util.logging.Slf4j
import org.grails.datastore.mapping.query.api.BuildableCriteria
import software.amazon.awssdk.core.ResponseInputStream
import software.amazon.awssdk.services.s3.model.GetObjectResponse
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request
import software.amazon.awssdk.services.s3.model.ListObjectsV2Response
import software.amazon.awssdk.services.s3.model.S3Object
import spock.lang.Specification

import javax.imageio.ImageIO
import java.awt.image.BufferedImage

@Slf4j
class TaskControllerSpec extends Specification implements ControllerUnitTest<TaskController>, DataTest {

    def s3Service
    Multimedia multimedia
    Task task

    private static final String CONFIG_IMAGES_HOME = '/tmp/grails-image-test'
    private static final String CONFIG_IMAGES_URL_PREFIX = '/data/volunteer/'
    private static final String TEST_PREFIX = "project123/task456/"
    private static final String TEST_S3_FILE_PATH = S3Service.S3_PREFIX + TEST_PREFIX
    private static final String TEST_LOCAL_FILE_PATH = CONFIG_IMAGES_URL_PREFIX + TEST_PREFIX
    private static final String TEST_FILE_NAME = "test-image.jpg"

    def setup() {
        s3Service = Mock(S3Service)
        controller.s3Service = s3Service

        task = new Task(externalIdentifier: TEST_FILE_NAME)
    }

    private Multimedia createMockS3Multimedia(long id, String fileName) {
        def filePath = TEST_S3_FILE_PATH + fileName
        return new Multimedia(id: id, filePath: filePath, mimeType: 'image/jpeg')
    }

    private Multimedia createMockMultimedia(long id, String fileName) {
        def filePath = TEST_LOCAL_FILE_PATH + fileName
        return new Multimedia(id: id, filePath: filePath, mimeType: 'image/jpeg')
    }

    private byte[] createMockImageBytes() {
        def bufferedImage = new BufferedImage(100, 100, BufferedImage.TYPE_INT_RGB)
        def baos = new ByteArrayOutputStream()
        ImageIO.write(bufferedImage, "jpg", baos)
        return baos.toByteArray()
    }

    void "imageDownload returns 200 when multimedia exists and S3 is enabled"() {
        given:
        def prefix = "project123/task456/"
        long multimediaId = 1
        //def filePath = S3Service.S3_PREFIX + prefix + "test-image.jpg"
        multimedia = createMockS3Multimedia(multimediaId, TEST_FILE_NAME)
        multimedia.task = task
        mockDomain(Multimedia, [multimedia])
        controller.params.id = multimediaId.toString()

        def getObjectResponse = GetObjectResponse.builder()
                .contentType("image/jpeg")
                .contentLength(100L)
                .build()
        def fakeFileBytes = createMockImageBytes()
        def delegateStream = new ByteArrayInputStream(fakeFileBytes)

        def realResponseStream = new ResponseInputStream<>(getObjectResponse, delegateStream)

        s3Service.isS3Enabled() >> true
        s3Service.getObject(TEST_PREFIX + TEST_FILE_NAME) >> realResponseStream

        when:
        controller.imageDownload()

        then:
        response.status == 200
        response.headers("Content-disposition").contains("inline;filename=test-image.jpg")
    }

    void "imageDownload returns 200 when multimedia exists and S3 is disabled"() {
        given:
        long multimediaId = 1
        multimedia = createMockMultimedia(multimediaId, TEST_FILE_NAME)
        multimedia.task = task
        mockDomain(Multimedia, [multimedia])
        controller.params.id = multimediaId.toString()
        log.debug("Created mock multimedia: ${multimedia}")

        s3Service.isS3Enabled() >> false
        config.images.urlPrefix = CONFIG_IMAGES_URL_PREFIX
        config.images.home = CONFIG_IMAGES_HOME

        def expectedPhysicalPath = CONFIG_IMAGES_HOME + "/" + TEST_PREFIX + TEST_FILE_NAME
        log.debug("Expected physical path for test image: ${expectedPhysicalPath}")
        File expectedFile = new File(expectedPhysicalPath)
        expectedFile.parentFile.mkdirs()

        def bufferedImage = new BufferedImage(100, 100, BufferedImage.TYPE_INT_RGB)
        ImageIO.write(bufferedImage, "jpg", expectedFile)

        when:
        controller.imageDownload()

        then:
        response.status == 200
        response.headers("Content-disposition").contains("inline;filename=test-image.jpg")
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0

        cleanup:
        if (expectedFile.exists()) {
            expectedFile.delete()
        }
        new File(CONFIG_IMAGES_HOME).deleteDir()
    }

    void "imageDownload redirects to placeholder when multimedia does not exist"() {
        given:
        long multimediaId = 999
        controller.params.id = multimediaId.toString()

        when:
        controller.imageDownload()

        then:
        response.status == 302
        response.redirectedUrl == "/image/taskPlaceholder"
    }

    void "imageDownload redirects to placeholder when S3 image is not found"() {
        given:
        long multimediaId = 1
        multimedia = createMockS3Multimedia(multimediaId, TEST_FILE_NAME)
        multimedia.task = task
        mockDomain(Multimedia, [multimedia])
        controller.params.id = multimediaId.toString()

        s3Service.isS3Enabled() >> true
        s3Service.getObject(TEST_PREFIX + TEST_FILE_NAME) >> { throw new RuntimeException("S3 object not found") }

        when:
        controller.imageDownload()

        then:
        response.status == 302
        response.redirectedUrl == "/image/taskPlaceholder"
    }

    void "imageDownload redirects to placeholder when disk image not found"() {
        given:
        long multimediaId = 1
        multimedia = createMockMultimedia(multimediaId, TEST_FILE_NAME)
        multimedia.task = task
        mockDomain(Multimedia, [multimedia])
        controller.params.id = multimediaId.toString()

        s3Service.isS3Enabled() >> false
        config.images.urlPrefix = CONFIG_IMAGES_URL_PREFIX
        config.images.home = CONFIG_IMAGES_HOME

        when:
        controller.imageDownload()

        then:
        response.status == 302
        response.redirectedUrl == "/image/taskPlaceholder"
    }

    void "showDetails defaults to updated sort and groups fields by transcriber with Unknown fallback"() {
        given:
        def project = new Project(id: 11L)
        def taskInstance = new Task(id: 22L, project: project)
        def sampleFields = [
                new Field(id: 1L, name: 'catalogNumber', transcribedByUserId: 'user-1', updated: new Date(3)),
                new Field(id: 2L, name: 'scientificName', transcribedByUserId: null, updated: new Date(2)),
                new Field(id: 3L, name: 'country', transcribedByUserId: 'user-1', updated: new Date(1))
        ]

        controller.userService = new Expando(
                currentUserId: 'validator-1',
                isValidator : { Project p -> true }
        )

        GroovySpy(Task, global: true)
        GroovySpy(Field, global: true)
        GroovySpy(Transcription, global: true)
        GroovySpy(ViewedTask, global: true)

        Task.get(22) >> taskInstance
        Map capturedCriteriaParams = [:]
        BuildableCriteria criteria = Mock(BuildableCriteria)
        Field.createCriteria() >> criteria
        criteria.list(_, _) >> { listParams, ignored ->
            capturedCriteriaParams = listParams
            sampleFields
        }
        Transcription.findAllByTaskAndFullyTranscribedByIsNotNull(_, _) >> []
        ViewedTask.findAllByTask(_, _) >> []

        controller.params.id = '22'

        when:
        def model = controller.showDetails()

        then:
        capturedCriteriaParams.sort?.toString() == 'updated'
        capturedCriteriaParams.order?.toString() == 'asc'
        capturedCriteriaParams.max?.toString() == '100'
        model.fieldsByTranscriber.keySet().toList() == ['user-1', 'Unknown']
        model.fieldsByTranscriber['user-1']*.name == ['catalogNumber', 'country']
        model.fieldsByTranscriber['Unknown']*.name == ['scientificName']
    }

    void "showDetails preserves requested sort/order and caps max to 100"() {
        given:
        def project = new Project(id: 41L)
        def taskInstance = new Task(id: 42L, project: project)

        controller.userService = new Expando(
                currentUserId: 'validator-2',
                isValidator : { Project p -> true }
        )

        GroovySpy(Task, global: true)
        GroovySpy(Field, global: true)
        GroovySpy(Transcription, global: true)
        GroovySpy(ViewedTask, global: true)

        Task.get(42) >> taskInstance
        Map capturedCriteriaParams = [:]
        BuildableCriteria criteria = Mock(BuildableCriteria)
        Field.createCriteria() >> criteria
        criteria.list(_, _) >> { listParams, ignored ->
            capturedCriteriaParams = listParams
            []
        }
        Transcription.findAllByTaskAndFullyTranscribedByIsNotNull(_, _) >> []
        ViewedTask.findAllByTask(_, _) >> []

        controller.params.id = '42'
        controller.params.sort = 'name'
        controller.params.order = 'asc'
        controller.params.max = '999'

        when:
        controller.showDetails()

        then:
        capturedCriteriaParams.sort?.toString() == 'name'
        capturedCriteriaParams.order?.toString() == 'asc'
        capturedCriteriaParams.max?.toString() == '100'
    }
}