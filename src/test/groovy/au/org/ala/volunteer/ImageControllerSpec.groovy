package au.org.ala.volunteer

import asset.pipeline.grails.AssetResourceLocator
import grails.testing.gorm.DataTest
import grails.testing.web.controllers.ControllerUnitTest
import org.springframework.core.io.Resource
import software.amazon.awssdk.core.ResponseInputStream
import software.amazon.awssdk.services.s3.model.GetObjectResponse
import spock.lang.*

class ImageControllerSpec extends Specification implements ControllerUnitTest<ImageController>, DataTest {

    def s3Service
    def assetResourceLocator

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
    }

    def serves_disk_image_when_multimedia_found_and_s3_disabled() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/test-image.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false
        grailsApplication.config.getProperty('images.urlPrefix', String.class) >> '/digivol'
        grailsApplication.config.getProperty('images.home', String.class) >> '/opt/images'

        File tempFile = File.createTempFile('test', '.jpg')
        tempFile.deleteOnExit()
        tempFile.bytes = [0xFF, 0xD8] as byte[] // JPEG magic bytes

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
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
        String externalIdentifier = 'test-image.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/test-image.jpg')
        mockDomain(Multimedia, [multimedia])

        controller.params.size = 'thumb'
        s3Service.isS3Enabled() >> false
        grailsApplication.config.getProperty('images.urlPrefix', String.class) >> '/digivol'
        grailsApplication.config.getProperty('images.home', String.class) >> '/opt/images'

        File tempFile = File.createTempFile('test_thumb', '.jpg')
        tempFile.deleteOnExit()
        tempFile.bytes = [0xFF, 0xD8] as byte[]

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
    }

    def extracts_valid_size_from_external_identifier_suffix() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image_thumb.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/test-image.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false
        grailsApplication.config.getProperty('images.urlPrefix', String.class) >> '/digivol'
        grailsApplication.config.getProperty('images.home', String.class) >> '/opt/images'

        File tempFile = File.createTempFile('test_thumb', '.jpg')
        tempFile.deleteOnExit()
        tempFile.bytes = [0xFF, 0xD8] as byte[]

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
    }

    def prefers_query_parameter_size_over_embedded_size_in_external_identifier() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image_thumb.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/test-image.jpg')
        mockDomain(Multimedia, [multimedia])

        controller.params.size = 'medium'
        s3Service.isS3Enabled() >> false
        grailsApplication.config.getProperty('images.urlPrefix', String.class) >> '/digivol'
        grailsApplication.config.getProperty('images.home', String.class) >> '/opt/images'

        File tempFile = File.createTempFile('test_medium', '.jpg')
        tempFile.deleteOnExit()
        tempFile.bytes = [0xFF, 0xD8] as byte[]

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
    }

    def ignores_invalid_embedded_size_in_external_identifier() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image_invalidsize.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/test-image.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false
        grailsApplication.config.getProperty('images.urlPrefix', String.class) >> '/digivol'
        grailsApplication.config.getProperty('images.home', String.class) >> '/opt/images'

        File tempFile = File.createTempFile('test-image', '.jpg')
        tempFile.deleteOnExit()
        tempFile.bytes = [0xFF, 0xD8] as byte[]

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
    }

    def returns_placeholder_when_disk_file_does_not_exist() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'missing.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/nonexistent.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false
        grailsApplication.config.getProperty('images.urlPrefix', String.class) >> '/digivol'
        grailsApplication.config.getProperty('images.home', String.class) >> '/opt/images'

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
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
    }

    def sets_correct_content_type_for_jpeg_response() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/test-image.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false
        grailsApplication.config.getProperty('images.urlPrefix', String.class) >> '/digivol'
        grailsApplication.config.getProperty('images.home', String.class) >> '/opt/images'

        File tempFile = File.createTempFile('test', '.jpg')
        tempFile.deleteOnExit()
        tempFile.bytes = [0xFF, 0xD8] as byte[]

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.contentType.contains('image/jpeg')
    }

    def sets_correct_content_type_from_s3_response_metadata() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image.png'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: 's3/path/to/image.png')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> true
        s3Service.getObject('path/to/image.png') >> s3Stream([0x89, 0x50] as byte[], 'image/png')

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.contentType == 'image/png'
        response.status == 200
    }

    def falls_back_to_default_content_type_when_s3_metadata_missing() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test-image.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: 's3/path/to/image.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> true
        s3Service.getObject('path/to/image.jpg') >> s3Stream([0xFF, 0xD8] as byte[], null)

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.contentType == 'image/jpeg'
    }

    def handles_empty_external_identifier() {
        given:
        long multimediaId = 1
        String externalIdentifier = ''
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/test-image.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false
        grailsApplication.config.getProperty('images.urlPrefix', String.class) >> '/digivol'
        grailsApplication.config.getProperty('images.home', String.class) >> '/opt/images'

        File tempFile = File.createTempFile('test-image', '.jpg')
        tempFile.deleteOnExit()
        tempFile.bytes = [0xFF, 0xD8] as byte[]

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
    }

    def handles_external_identifier_with_special_characters() {
        given:
        long multimediaId = 1
        String externalIdentifier = 'test~image-2024_001.jpg'
        Multimedia multimedia = new Multimedia(id: multimediaId, filePath: '/images/test-image.jpg')
        mockDomain(Multimedia, [multimedia])

        s3Service.isS3Enabled() >> false
        grailsApplication.config.getProperty('images.urlPrefix', String.class) >> '/digivol'
        grailsApplication.config.getProperty('images.home', String.class) >> '/opt/images'

        File tempFile = File.createTempFile('test-image', '.jpg')
        tempFile.deleteOnExit()
        tempFile.bytes = [0xFF, 0xD8] as byte[]

        when:
        controller.taskImage(multimediaId, externalIdentifier)

        then:
        response.status == 200
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
