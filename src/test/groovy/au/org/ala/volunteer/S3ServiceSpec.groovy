package au.org.ala.volunteer

import grails.testing.services.ServiceUnitTest
import org.mockito.Mockito
import software.amazon.awssdk.core.ResponseInputStream
import software.amazon.awssdk.core.pagination.sync.SdkIterable
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.s3.S3Utilities
import software.amazon.awssdk.services.s3.model.CommonPrefix
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest
import software.amazon.awssdk.services.s3.model.DeleteObjectsRequest
import software.amazon.awssdk.services.s3.model.GetObjectRequest
import software.amazon.awssdk.services.s3.model.GetObjectResponse
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request
import software.amazon.awssdk.services.s3.model.ListObjectsV2Response
import software.amazon.awssdk.services.s3.model.S3Object
import software.amazon.awssdk.services.s3.model.StorageClass
import software.amazon.awssdk.services.s3.paginators.ListObjectsV2Iterable
import spock.lang.Specification
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import software.amazon.awssdk.core.sync.RequestBody

import java.time.Instant

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

    void "uploadFile uploads file to S3 with correct parameters"() {
        given:
        def key = "test/image.jpg"
        def file = File.createTempFile("test", ".jpg")
        file.bytes = [0xFF, 0xD8] as byte[]
        def contentType = "image/jpeg"

        when:
        service.uploadFile(key, file, contentType)

        then:
        1 * mockS3.putObject(
                { PutObjectRequest req ->
                    req.bucket() == "test-bucket" &&
                            req.key() == key &&
                            req.contentType() == contentType
                },
                _ as RequestBody
        )

        cleanup:
        file.delete()
    }

    void "uploadFile throws exception when file does not exist"() {
        given:
        def key = "test/missing.jpg"
        def file = new File("/nonexistent/path/missing.jpg")
        def contentType = "image/jpeg"

        when:
        service.uploadFile(key, file, contentType)

        then:
        thrown(IllegalArgumentException)
    }

    void "uploadFile throws exception when path is a directory not a file"() {
        given:
        def key = "test/dir"
        def file = File.createTempDir()
        def contentType = "image/jpeg"

        when:
        service.uploadFile(key, file, contentType)

        then:
        thrown(IllegalArgumentException)

        cleanup:
        file.delete()
    }

    void "delete removes object from S3"() {
        given:
        def key = "test/file.jpg"

        when:
        service.delete(key)

        then:
        1 * mockS3.deleteObject(
                { DeleteObjectRequest req ->
                    req.bucket() == "test-bucket" &&
                            req.key() == key
                }
        )
    }

    void "deleteForPrefix deletes all objects matching prefix"() {
        given:
        def prefix = "project123/task456/"

        S3Object s3Object1 = S3Object.builder().key("${prefix}image1.jpg").size(100L).build()
        S3Object s3Object2 = S3Object.builder().key("${prefix}image2.jpg").size(200L).build()

        def listResponse = ListObjectsV2Response.builder()
                .contents(s3Object1, s3Object2)
                .isTruncated(false)
                .build()
        mockS3.listObjectsV2(_ as ListObjectsV2Request) >> listResponse

        when:
        service.deleteForPrefix(prefix)

        then:
        1 * mockS3.deleteObjects(
                { DeleteObjectsRequest req ->
                    req.bucket() == "test-bucket" &&
                            req.delete().objects().size() == 2
                }
        )
    }

    void "deleteForPrefix does nothing when no objects match prefix"() {
        given:
        def prefix = "nonexistent/"

        def listResponse = ListObjectsV2Response.builder()
                .contents()
                .isTruncated(false)
                .build()
        mockS3.listObjectsV2(_ as ListObjectsV2Request) >> listResponse

        when:
        service.deleteForPrefix(prefix)

        then:
        0 * mockS3.deleteObjects(_)
    }

    void "deleteForPrefix throws exception when prefix is empty"() {
        when:
        service.deleteForPrefix("")

        then:
        thrown(IllegalArgumentException)
    }

    void "deleteForPrefix throws exception when prefix is null"() {
        when:
        service.deleteForPrefix(null)

        then:
        thrown(IllegalArgumentException)
    }

    void "getObject returns ResponseInputStream from S3"() {
        given:
        def key = "test/file.jpg"
        def getObjectResponse = GetObjectResponse.builder()
                .contentType("image/jpeg")
                .contentLength(100L)
                .build()

        def fakeFileBytes = "fake-image-bytes".getBytes()
        def delegateStream = new ByteArrayInputStream(fakeFileBytes)

        def realResponseStream = new ResponseInputStream<>(getObjectResponse, delegateStream)
        mockS3.getObject(_ as GetObjectRequest) >> realResponseStream

        when:
        def result = service.getObject(key)

        then:
        result == realResponseStream
        result.response().contentType() == "image/jpeg"
        result.text == "fake-image-bytes"
    }

    void "getUrl returns URL for S3 object"() {
        given:
        def key = "test/file.jpg"

        S3Utilities realUtilities = S3Utilities.builder()
                .region(Region.AP_SOUTHEAST_2)
                .build()

        mockS3.utilities() >> realUtilities

        when:
        def result = service.getUrl(key)

        then:
        // Assert against the actual AWS URL structure generated by the real class
        result != null
        result.protocol == "https"
        result.host == "test-bucket.s3.ap-southeast-2.amazonaws.com"
        result.path == "/test/file.jpg"
    }

    void "listObjectsForPrefix returns list of objects matching prefix"() {
        given:
        def prefix = "project123/task456/"
        S3Object s3Object1 = S3Object.builder().key("${prefix}image1.jpg").size(1024L)
                .lastModified(Instant.now()).storageClass(StorageClass.STANDARD as String).build()

        def listResponse = ListObjectsV2Response.builder()
                .contents(s3Object1)
                .isTruncated(false)
                .build()
        mockS3.listObjectsV2(_ as ListObjectsV2Request) >> listResponse

        when:
        def result = service.listObjectsForPrefix(prefix)

        then:
        result.size() == 1
        result[0].key == "project123/task456/image1.jpg"
        result[0].size == 1024
    }

    void "listObjectsForPrefix throws exception when prefix is empty"() {
        when:
        service.listObjectsForPrefix("")

        then:
        thrown(IllegalArgumentException)
    }

    void "listObjectsForPrefix throws exception when prefix is null"() {
        when:
        service.listObjectsForPrefix(null)

        then:
        thrown(IllegalArgumentException)
    }

    void "listObjectsForPrefix returns empty list when no objects match"() {
        given:
        def prefix = "nonexistent/"

        def listResponse = ListObjectsV2Response.builder()
                .contents()
                .isTruncated(false)
                .build()
        mockS3.listObjectsV2(_ as ListObjectsV2Request) >> listResponse

        when:
        def result = service.listObjectsForPrefix(prefix)

        then:
        result.isEmpty()
    }

    void "calculateTotalSizeForPrefix returns sum of all object sizes for prefix"() {
        given:
        def prefix = "project123/task456"
        S3Object s3Object1 = S3Object.builder().key("${prefix}image1.jpg").size(1024L).build()
        S3Object s3Object2 = S3Object.builder().key("${prefix}image2.jpg").size(2048L).build()

        def listResponse = ListObjectsV2Response.builder()
                .contents(s3Object1, s3Object2)
                .isTruncated(false)
                .build()
        S3Client fakeClient = Mock(S3Client)
        fakeClient.listObjectsV2(_ as ListObjectsV2Request) >> listResponse
        ListObjectsV2Iterable realIterable = new ListObjectsV2Iterable(fakeClient, ListObjectsV2Request.builder().build())
        mockS3.listObjectsV2Paginator(_ as ListObjectsV2Request) >> realIterable

        when:
        def result = service.calculateTotalSizeForPrefix(prefix)

        then:
        result == 3072
    }

    void "calculateTotalSizeForPrefix adds trailing slash to prefix if missing"() {
        given:
        def prefix = "project123/task456"
        S3Object s3Object = S3Object.builder().key("${prefix}image1.jpg").size(1024L).build()

        def listResponse = ListObjectsV2Response.builder()
                .contents(s3Object)
                .isTruncated(false)
                .build()

        S3Client fakeClient = Mock(S3Client)
        fakeClient.listObjectsV2(_ as ListObjectsV2Request) >> listResponse
        ListObjectsV2Iterable realIterable = new ListObjectsV2Iterable(fakeClient, ListObjectsV2Request.builder().build())

        when:
        service.calculateTotalSizeForPrefix(prefix)

        then:
        1 * mockS3.listObjectsV2Paginator({ ListObjectsV2Request req ->
            req.prefix().endsWith("/")
        }) >> realIterable
    }

    void "calculateTotalSizeForPrefix throws exception when prefix is empty"() {
        when:
        service.calculateTotalSizeForPrefix("")

        then:
        thrown(IllegalArgumentException)
    }

    void "calculateTotalSizeForPrefix throws exception when prefix is null"() {
        when:
        service.calculateTotalSizeForPrefix(null)

        then:
        thrown(IllegalArgumentException)
    }

    void "getBucketInfo returns bucket statistics"() {
        given:
        S3Object s3Object1 = S3Object.builder().key("123/456/789").size(1024L).lastModified(Instant.now()).build()

        def listResponse = ListObjectsV2Response.builder()
                .contents(s3Object1)
                .keyCount(1)
                .isTruncated(false)
                .build()
        mockS3.listObjectsV2(_ as ListObjectsV2Request) >> listResponse

        when:
        def result = service.getBucketInfo()

        then:
        result.bucket == "test-bucket"
        result.region == "ap-southeast-2"
        result.status == "SUCCESS"
        result.objectsCount == 1
    }

    void "getBucketInfo handles pagination"() {
        given:
        def response1 = ListObjectsV2Response.builder()
                .contents()
                .keyCount(100)
                .isTruncated(true)
                .nextContinuationToken("token123")
                .build()

        def response2 = ListObjectsV2Response.builder()
                .contents()
                .keyCount(50)
                .isTruncated(false)
                .nextContinuationToken(null)
                .build()

        mockS3.listObjectsV2(_ as ListObjectsV2Request) >>> [response1, response2]

        when:
        def result = service.getBucketInfo()

        then:
        result.objectsCount == 150
        result.status == "SUCCESS"
    }

    void "getBucketInfo returns error status when exception occurs"() {
        given:
        mockS3.listObjectsV2(_) >> { throw new RuntimeException("S3 connection failed") }

        when:
        def result = service.getBucketInfo()

        then:
        result.status == "ERROR"
        result.message.contains("S3 connection failed")
    }

    void "listBucketTopLevel returns top-level objects and prefixes"() {
        given:
        S3Object s3Object = S3Object.builder().key("file.txt").size(1024L).lastModified(Instant.now())
                .storageClass(StorageClass.STANDARD as String).build()
        CommonPrefix commonPrefix = CommonPrefix.builder().prefix("folder/").build()

        def listResponse = ListObjectsV2Response.builder()
                .contents(s3Object)
                .keyCount(1)
                .commonPrefixes(commonPrefix)
                .isTruncated(false)
                .nextContinuationToken(null)
                .build()
        mockS3.listObjectsV2(_ as ListObjectsV2Request) >> listResponse

        when:
        def result = service.listBucketTopLevel()

        then:
        result.bucket == "test-bucket"
        result.status == "SUCCESS"
        result.topLevelObjects.size() == 1
        result.topLevelPrefixes.size() == 1
        result.totalItems == 2
    }

    void "listBucketObjects returns objects with optional prefix"() {
        given:
        S3Object s3Object = S3Object.builder().key("project123/file.jpg").size(2048L).lastModified(Instant.now())
                .storageClass(StorageClass.STANDARD as String).build()

        def listResponse = ListObjectsV2Response.builder()
                .contents(s3Object)
                .keyCount(1)
                .isTruncated(false)
                .nextContinuationToken(null)
                .build()
        mockS3.listObjectsV2(_ as ListObjectsV2Request) >> listResponse

        when:
        def result = service.listBucketObjects("project123/")

        then:
        result.bucket == "test-bucket"
        result.prefix == "project123/"
        result.status == "SUCCESS"
        result.objects.size() == 1
    }

    void "listBucketObjects returns empty list when prefix matches no objects"() {
        given:
        def listResponse = ListObjectsV2Response.builder()
                .contents()
                .keyCount(0)
                .isTruncated(false)
                .nextContinuationToken(null)
                .build()
        mockS3.listObjectsV2(_ as ListObjectsV2Request) >> listResponse

        when:
        def result = service.listBucketObjects("nonexistent/")

        then:
        result.objects.isEmpty()
        result.status == "SUCCESS"
    }

    void "isS3Enabled returns false when aws.s3.enabled is false"() {
        given:
        service.grailsApplication.config.aws.s3.enabled = false

        when:
        def result = service.isS3Enabled()

        then:
        !result
    }

    void "isS3Enabled returns true when aws.s3.enabled is true"() {
        given:
        service.grailsApplication.config.aws.s3.enabled = true

        when:
        def result = service.isS3Enabled()

        then:
        result
    }

    void "getBucket returns configured bucket name"() {
        when:
        def result = service.getBucket()

        then:
        result == "test-bucket"
    }

    void "getBucket throws exception when bucket not configured"() {
        given:
        service.grailsApplication.config.aws.s3.bucket = null

        when:
        service.getBucket()

        then:
        thrown(IllegalStateException)
    }

    void "getRegion returns configured region"() {
        when:
        def result = service.getRegion()

        then:
        result.id() == "ap-southeast-2"
    }

    void "getRegion throws exception when region not configured"() {
        given:
        service.grailsApplication.config.aws.s3.region = null

        when:
        service.getRegion()

        then:
        thrown(IllegalStateException)
    }
}