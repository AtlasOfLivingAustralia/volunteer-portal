package au.org.ala.volunteer

import asset.pipeline.grails.AssetResourceLocator
import grails.plugins.cacheheaders.CacheHeadersTrait
import grails.testing.gorm.DataTest
import grails.testing.web.controllers.ControllerUnitTest
import groovy.util.logging.Slf4j
import org.springframework.core.io.Resource
import software.amazon.awssdk.core.ResponseInputStream
import software.amazon.awssdk.services.s3.model.GetObjectResponse
import spock.lang.*

import javax.imageio.ImageIO
import java.awt.image.BufferedImage

@Slf4j
class ImageControllerSpec extends Specification implements ControllerUnitTest<ImageController>, DataTest {

    def s3Service
    def assetResourceLocator

    String tempBaseDir
    String urlPrefix = '/data/volunteer/'

    def setup() {
        s3Service = Mock(S3Service)
        controller.s3Service = s3Service

        assetResourceLocator = Mock(AssetResourceLocator)
        controller.assetResourceLocator = assetResourceLocator

        def placeholderResource = Mock(Resource)
        placeholderResource.exists() >> true
        placeholderResource.filename >> 'sample-task.jpg'
        placeholderResource.inputStream >> new ByteArrayInputStream([0xFF, 0xD8] as byte[])

        assetResourceLocator.findAssetForURI(_) >> placeholderResource

        tempBaseDir = System.getProperty("java.io.tmpdir") + "grails-image-test-${System.nanoTime()}"
        config.images.home = tempBaseDir
        config.images.urlPrefix = urlPrefix
    }

    private File createTempImageFile(String filename, String prefix = "") {
        String filePath = "${tempBaseDir}/${prefix}${filename}"
        File file = new File(filePath)
        file.parentFile.mkdirs()
        file.bytes = [0xFF, 0xD8, 0xFF, 0xE0] as byte[] // Valid minimal JPEG header
        boolean timeSet = file.setLastModified(System.currentTimeMillis())
        log.debug("Created temp image file at: ${file.absolutePath} with size: ${file.length()} bytes")
        return file
    }

    def cleanup() {
        if (tempBaseDir) {
            new File(tempBaseDir).deleteDir()
        }
    }

    def serves_disk_image_when_multimedia_found_and_s3_disabled() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image.jpg'
        String prefix = "project123/task456/"

        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: "${urlPrefix}${prefix}test-image.jpg")
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false

        // Temp image generation
        File expectedFile = createTempImageFile(externalIdentifier, prefix)
        def expectedFilename = expectedFile.name

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=${expectedFilename}")
        // log.debug("Response headers: ${response.headerNames.collectEntries { [(it): response.getHeader(it)] }}")
    }

    def serves_s3_image_when_s3_enabled_and_multimedia_found() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: 's3/path/to/image.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> true
        s3Service.getObject('path/to/image.jpg') >> s3Stream([0xFF, 0xD8] as byte[], 'image/jpeg')

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
    }

    def returns_placeholder_when_multimedia_not_found() {
        given:
        long multimediaId = 999
        String externalIdentifier = 'missing.jpg'
        mockDomain(Multimedia, [])

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
    }

    def applies_size_from_query_parameter_to_image_path() {
        given:
        long multimediaId = 1
        String prefix = "project123/task456/"
        String externalIdentifier = 'test-image.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: "${urlPrefix}${prefix}test-image.jpg")
        mockDomain(Multimedia, [multimedia])
        controller.params.size = 'thumb'
        s3Service.isS3Enabled() >> false

        // Temp image generation
        def expectedFilename = "test-image_thumb.jpg"
        File expectedFile = createTempImageFile(expectedFilename, prefix)

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=${expectedFilename}")

        cleanup:
        if (tempBaseDir) {
            new File(tempBaseDir).deleteDir()
        }
    }

    def extracts_valid_size_from_external_identifier_suffix() {
        given:
        long multimediaId = 1
        String prefix = "project123/task456/"
        String externalIdentifier = 'test-image_thumb.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: "${urlPrefix}${prefix}test-image.jpg")
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false

        // Temp image generation
        def expectedFilename = "test-image_thumb.jpg"
        File expectedFile = createTempImageFile(expectedFilename, prefix)

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=${expectedFilename}")
    }

    def prefers_query_parameter_size_over_embedded_size_in_external_identifier() {
        given:
        long multimediaId = 1
        String prefix = "project123/task456/"
        String externalIdentifier = 'test-image_thumb.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: "${urlPrefix}${prefix}test-image.jpg")
        mockDomain(Multimedia, [multimedia])

        controller.params.size = 'medium'
        s3Service.isS3Enabled() >> false

        // Temp image generation
        def expectedFilename = "test-image_medium.jpg"
        File expectedFile = createTempImageFile(expectedFilename, prefix)

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=${expectedFilename}")
    }

    def ignores_invalid_embedded_size_in_external_identifier() {
        given:
        long multimediaId = 1
        String prefix = "project123/task456/"
        String externalIdentifier = 'test-image_invalidsize.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: "${urlPrefix}${prefix}test-image.jpg")
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false

        // Temp image generation
        def expectedFilename = "test-image.jpg"
        File expectedFile = createTempImageFile(expectedFilename, prefix)

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=${expectedFilename}")
    }

    def returns_placeholder_when_disk_file_does_not_exist() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'missing.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/nonexistent.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=sample-task.jpg")
    }

    def returns_placeholder_when_s3_retrieval_fails_with_exception() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: 's3/path/to/image.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> true
        s3Service.getObject('path/to/image.jpg') >> { throw new RuntimeException('S3 connection failed') }

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=sample-task.jpg")
    }

    def returns_placeholder_when_s3_service_returns_invalid_stream() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: 's3/path/to/image.jpg')
        mockDomain(Multimedia, [multimedia])

        def brokenStream = new InputStream() {
            @Override
            int read() throws IOException {
                throw new IOException('Stream error')
            }
        }

        s3Service.isS3Enabled() >> true
        s3Service.getObject('path/to/image.jpg') >> s3Stream(brokenStream, 'image/jpeg')

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=sample-task.jpg")
    }

    def handles_empty_external_identifier() {
        given:
        long multimediaId = 1
        String prefix = "project123/task456/"
        String externalIdentifier = ''
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: "${urlPrefix}${prefix}test-image.jpg")
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false

        // Temp image generation
        def expectedFilename = "test-image.jpg"
        File expectedFile = createTempImageFile(expectedFilename, prefix)

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=${expectedFilename}")
    }

    def handles_external_identifier_with_special_characters() {
        given:
        long multimediaId = 1
        String prefix = "project123/task456/"
        String externalIdentifier = 'test~image-2024_001.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: "${urlPrefix}${prefix}test-image.jpg")
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false

        // Temp image generation
        def expectedFilename = "test-image.jpg"
        File expectedFile = createTempImageFile(expectedFilename, prefix)

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
        response.contentType == 'image/jpeg'
        response.contentAsByteArray.length > 0
        response.header("Content-disposition").equalsIgnoreCase("inline;filename=${expectedFilename}")
    }

    private ResponseInputStream<GetObjectResponse> s3Stream(byte[] bytes, String contentType) {
        s3Stream(new ByteArrayInputStream(bytes), contentType)
    }

    private ResponseInputStream<GetObjectResponse> s3Stream(InputStream inputStream, String contentType) {
        def responseBuilder = GetObjectResponse.builder()
        if (contentType != null) {
            responseBuilder.contentType(contentType)
        }
        new ResponseInputStream<GetObjectResponse>(responseBuilder.build(), inputStream)
    }

}
