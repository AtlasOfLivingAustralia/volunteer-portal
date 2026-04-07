package au.org.ala.volunteer

import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider
import software.amazon.awssdk.core.sync.RequestBody
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.*
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest

import java.time.Duration

/**
 * Service for interacting with AWS S3 for file storage.
 */
class S3Service {

    def grailsApplication
    S3Client awsS3Client

    public static final String S3_PREFIX = "s3/"

    public String getBucket() {
        String bucketStr = grailsApplication.config.getProperty('aws.s3.bucket', String)
        if (!bucketStr) {
            throw new IllegalStateException("AWS S3 bucket is not configured. Please set 'aws.s3.bucket' in the application configuration.")
        }
        bucketStr
    }

    public Region getRegion() {
        String regionStr = grailsApplication.config.getProperty('aws.s3.region', String)
        if (!regionStr) {
            throw new IllegalStateException("AWS S3 region is not configured. Please set 'aws.s3.region' in the application configuration.")
        }
        Region.of(regionStr)
    }

    /**
     * Upload an object to the S3 bucket.
     *
     * @param key The S3 object key.
     * @param inputStream The input stream of the object to upload.
     * @param contentType The content type of the object.
     */
    void upload(String key, InputStream inputStream, String contentType) {
        log.debug("Uploading object to S3 with key: ${key} and content type: ${contentType}")
        log.debug("Input stream available bytes: ${inputStream?.available()}")

        def builder = PutObjectRequest.builder()
                .bucket(getBucket())
                .key(key)
                .contentType(contentType)
                .ifNoneMatch("*")
                .build()
        awsS3Client.putObject(
                builder as PutObjectRequest,
                RequestBody.fromInputStream(inputStream, inputStream.available())
        )
    }

    /**
     * Delete an object from the S3 bucket.
     *
     * @param key The S3 object key to delete.
     */
    void delete(String key) {
        awsS3Client.deleteObject(DeleteObjectRequest.builder()
                .bucket(getBucket())
                .key(key)
                .build() as DeleteObjectRequest)
    }

    /**
     * Generate a pre-signed URL for accessing an object in S3. The URL will be valid for the specified duration.
     * This is typically used for providing temporary access to private S3 objects.
     * Private images are not currently implemented but added for future reference.
     *
     * @param key The S3 object key.
     * @param expiry The duration for which the pre-signed URL is valid. Default is 15 minutes.
     * @return A URL that can be used to access the S3 object.
     */
//    URL generatePresignedUrl(String key, Duration expiry = Duration.ofMinutes(15)) {
//        def presigner = S3Presigner.builder()
//                .region(region)
//                .credentialsProvider(DefaultCredentialsProvider.create())
//                .build()
//
//        def getRequest = GetObjectRequest.builder()
//                .bucket(bucket)
//                .key(key)
//                .build() as GetObjectRequest
//
//        def presigned = presigner.presignGetObject(
//                GetObjectPresignRequest.builder()
//                        .signatureDuration(expiry)
//                        .getObjectRequest(getRequest)
//                        .build()
//        )
//
//        presigner.close()
//        return presigned.url()
//    }

/**
 * List top-level objects in the configured S3 bucket.
 *
 * @param maxKeys Maximum number of keys to return (default 1000)
 * @return Map containing list of top-level objects and metadata
 */
    Map listBucketTopLevel(int maxKeys = 1000) {
        try {
            log.debug("Listing top-level objects in S3 bucket: ${getBucket()}")

            def request = ListObjectsV2Request.builder()
                    .bucket(getBucket())
                    .maxKeys(maxKeys)
                    .delimiter("/")  // Use "/" as delimiter to get only top-level items
                    .build()

            def response = awsS3Client.listObjectsV2(request)

            def topLevelObjects = response.contents().collect { s3Object ->
                [
                        key: s3Object.key(),
                        size: s3Object.size(),
                        lastModified: s3Object.lastModified(),
                        storageClass: s3Object.storageClass()
                ]
            }

            def topLevelPrefixes = response.commonPrefixes().collect { prefix ->
                [
                        prefix: prefix.prefix(),
                        isDirectory: true
                ]
            }

            return [
                    bucket: getBucket(),
                    region: getRegion().id(),
                    objectsFound: response.keyCount(),
                    isTruncated: response.isTruncated(),
                    continuationToken: response.nextContinuationToken(),
                    topLevelObjects: topLevelObjects,
                    topLevelPrefixes: topLevelPrefixes,
                    totalItems: topLevelObjects.size() + topLevelPrefixes.size(),
                    status: 'SUCCESS'
            ]

        } catch (Exception e) {
            log.error("Error listing bucket top level", e)
            return [
                    bucket: getBucket(),
                    region: getRegion().id(),
                    status: 'ERROR',
                    message: e.message,
                    errorClass: e.class.simpleName
            ]
        }
    }

/**
 * Alternative: List all objects (including nested) in the configured bucket.
 * Use for deeper inspection of bucket structure.
 *
 * @param prefix Optional prefix to search within (e.g., "projectId/taskId/")
 * @param maxKeys Maximum number of keys to return (default 1000)
 * @return Map containing all objects matching the prefix
 */
    Map listBucketObjects(String prefix = "", int maxKeys = 1000) {
        try {
            log.debug("Listing all objects in S3 bucket: ${getBucket()} with prefix: ${prefix}")

            def request = ListObjectsV2Request.builder()
                    .bucket(getBucket())
                    .prefix(prefix)
                    .maxKeys(maxKeys)
                    .build()

            def response = awsS3Client.listObjectsV2(request)

            def objects = response.contents().collect { s3Object ->
                [
                        key: s3Object.key(),
                        size: s3Object.size(),
                        lastModified: s3Object.lastModified(),
                        storageClass: s3Object.storageClass()
                ]
            }

            return [
                    bucket: getBucket(),
                    region: getRegion().id(),
                    prefix: prefix,
                    objectsFound: response.keyCount(),
                    isTruncated: response.isTruncated(),
                    continuationToken: response.nextContinuationToken(),
                    objects: objects,
                    status: 'SUCCESS'
            ]

        } catch (Exception e) {
            log.error("Error listing bucket objects", e)
            return [
                    bucket: getBucket(),
                    region: getRegion().id(),
                    prefix: prefix,
                    status: 'ERROR',
                    message: e.message,
                    errorClass: e.class.simpleName
            ]
        }
    }

}
