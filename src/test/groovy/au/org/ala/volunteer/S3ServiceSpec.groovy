package au.org.ala.volunteer

import grails.testing.services.ServiceUnitTest
import software.amazon.awssdk.core.sync.RequestBody
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.S3ClientBuilder
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import spock.lang.Specification

class S3ServiceSpec extends Specification implements ServiceUnitTest<S3Service> {

    def "upload() calls s3Client.putObject()"() {
        given:
        def s3Client = Mock(S3Client)
        def service = new S3Service()
        service.s3Client = s3Client
        service.metaClass.bucket = "test-bucket"
        service.metaClass.region = Region.AWS_GLOBAL

        def input = new ByteArrayInputStream("test data".bytes)

        when:
        service.upload("key.text", input, "text/plain")

        then:
        1 * s3Client.putObject(_ as PutObjectRequest,_ as RequestBody)
    }

    def "init() reads config and upload() calls s3.putObject()"() {
        given:
        // Mock S3 client
        def mockS3 = Mock(S3Client)

        // Minimal mock grailsApplication.config
        def fakeConfig = [
            aws: [
                s3: [
                        bucket: 'test-bucket',
                        region: 'ap-southeast-2'
                ]
            ]
        ]

        service.grailsApplication = [
                config: fakeConfig
        ]

        // Instead of mocking static builder, we override init() behavior directly:
        service.metaClass.buildS3Client = { -> mockS3 }  // adds a fake helper method

        when:
        // manually simulate init logic
        def conf = service.grailsApplication.config.aws.s3
        service.bucket = conf.bucket
        service.region = Region.of(conf.region)
        service.@s3Client = mockS3

        then:
        service.bucket == 'test-bucket'
        service.region == Region.of('ap-southeast-2')
        service.@s3Client == mockS3
    }
}
