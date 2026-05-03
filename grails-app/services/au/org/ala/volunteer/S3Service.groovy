package au.org.ala.volunteer

import software.amazon.awssdk.core.ResponseInputStream
import software.amazon.awssdk.core.sync.RequestBody
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.*

/**
 * Service for interacting with AWS S3 for file storage.
 */
class S3Service {

    def grailsApplication
    S3Client awsS3Client

    public static final String S3_PREFIX = "s3/"

    /**
     * Check if S3 integration is enabled based on application configuration.
     * @return true if S3 is enabled, false otherwise
     */
    boolean isS3Enabled() {
        return grailsApplication.config.getProperty('aws.s3.enabled', Boolean, false)
    }

    /**
     * Get the configured S3 bucket name from application configuration. Throws an exception if not configured.
     * @return The S3 bucket name
     */
    String getBucket() {
        String bucketStr = grailsApplication.config.getProperty('aws.s3.bucket', String)
        if (!bucketStr) {
            throw new IllegalStateException("AWS S3 bucket is not configured. Please set 'aws.s3.bucket' in the application configuration.")
        }
        bucketStr
    }

    /**
     * Get the configured AWS region for S3 from application configuration. Throws an exception if not configured.
     * @return The AWS Region object
     */
    Region getRegion() {
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
     * Delete all objects in the S3 bucket that match a given prefix. This is useful for deleting all files related to a
     * specific project or task.
     *
     * @param prefix The prefix to filter objects by (e.g., "projectId/taskId/"). Must be provided.
     */
    void deleteForPrefix(String prefix) {
        def objectsToDelete = listObjectsForPrefix(prefix)
        if (objectsToDelete) {
            def deleteObjectsRequest = DeleteObjectsRequest.builder()
                    .bucket(getBucket())
                    .delete(Delete.builder()
                            .objects(objectsToDelete.collect { s3Object ->
                                ObjectIdentifier.builder().key(s3Object.key).build()
                            })
                            .build())
                    .build() as DeleteObjectsRequest
            awsS3Client.deleteObjects(deleteObjectsRequest)
        }
    }

    /**
     * Get a public URL for an object in the S3 bucket. This assumes the object is accessible by the public (e.g.,
     * via bucket policies or ACLs). If the object is private, this URL may not work unless appropriate permissions are set.
     *
     * @param key The S3 object key.
     * @return A URL that can be used to access the S3 object.
     */
    URL getUrl(String key) {
        awsS3Client.utilities().getUrl(GetUrlRequest.builder()
                .bucket(getBucket())
                .key(key)
                .build() as GetUrlRequest)
    }

    /**
     * Get the Object from S3 Storage
     * @param key The S3 object key.
     * @return A ResponseInputStream containing the GetObjectResponse, which includes the object's data and metadata.
     */
    ResponseInputStream<GetObjectResponse> getObject(String key) {
        awsS3Client.getObject(GetObjectRequest.builder()
                .bucket(getBucket())
                .key(key)
                .build() as GetObjectRequest)
    }

    /**
     * List objects in the S3 bucket that match a given prefix. This can be used to list objects within a "folder" structure.
     *
     * @param prefix The prefix to filter objects by (e.g., "projectId/taskId/"). Must be provided.
     * @param maxKeys Maximum number of keys to return (default 1000)
     * @return List of objects matching the prefix, each with key, size, last modified date, and storage class
     */
    List listObjectsForPrefix(String prefix, int maxKeys = 1000) {
        if (!prefix) {
            throw new IllegalArgumentException("Prefix must be provided to list objects for prefix.")
        }
        def request = ListObjectsV2Request.builder()
                .bucket(getBucket())
                .prefix(prefix)
                .maxKeys(maxKeys)
                .build() as ListObjectsV2Request

        def response = awsS3Client.listObjectsV2(request)

        return response.contents().collect { s3Object ->
            [
                key: s3Object.key(),
                size: s3Object.size(),
                lastModified: s3Object.lastModified(),
                storageClass: s3Object.storageClass()
            ]
        }
    }

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
