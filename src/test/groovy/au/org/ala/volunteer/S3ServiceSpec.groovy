package au.org.ala.volunteer

import grails.testing.services.ServiceUnitTest
import spock.lang.Specification
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import software.amazon.awssdk.core.sync.RequestBody

class S3ServiceSpec extends Specification implements ServiceUnitTest<S3Service> {

    S3Client mockS3

    void setup() {
        mockS3 = Mock(S3Client)
        service.awsS3Client = mockS3

        service.grailsApplication.config.aws.s3.bucket = "test-bucket"
        service.grailsApplication.config.aws.s3.region = "ap-southeast-2"
    }

    void "upload sends object to S3"() {
        given:
        def key = "test/file.txt"
        def content = "hello world"
        def inputStream = new ByteArrayInputStream(content.bytes)

        when:
        service.upload(key, inputStream, "text/plain")

        then:
        1 * mockS3.putObject(
                { PutObjectRequest req ->
                    req.bucket() == "test-bucket" &&
                            req.key() == key &&
                            req.contentType() == "text/plain"
                },
                _ as RequestBody
        )
    }
}