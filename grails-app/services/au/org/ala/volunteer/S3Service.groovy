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
    private S3Client s3Client
    private String bucket
    private Region region

    /**
     * Initialize the S3 client using configuration from grailsApplication.
     * Expects aws.s3.bucket and aws.s3.region to be set in the configuration.
     */
    def init() {
        def conf = grailsApplication.config.getProperty('aws.s3')
        bucket = conf.bucket
        region = Region.of(conf.region as String)

        s3Client = S3Client.builder()
                .region(region)
                .credentialsProvider(DefaultCredentialsProvider.create())
                .build()

        log.info("Initialized S3 client for bucket: ${bucket} in region: ${region}")
    }

    /**
     * Set a custom S3 client. Primarily used for testing.
     *
     * @param s3Client The S3 client to use.
     */
    void setS3Client(S3Client s3Client) {
        this.s3Client = s3Client
    }

    /**
     * Upload an object to the S3 bucket.
     *
     * @param key The S3 object key.
     * @param inputStream The input stream of the object to upload.
     * @param contentType The content type of the object.
     */
    void upload(String key, InputStream inputStream, String contentType) {
        def builder = PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType(contentType)
                .ifNoneMatch("*")
                .build()
        s3Client.putObject(
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
        s3Client.deleteObject(DeleteObjectRequest.builder()
                .bucket(bucket)
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
    URL generatePresignedUrl(String key, Duration expiry = Duration.ofMinutes(15)) {
        def presigner = S3Presigner.builder()
                .region(region)
                .credentialsProvider(DefaultCredentialsProvider.create())
                .build()

        def getRequest = GetObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .build() as GetObjectRequest

        def presigned = presigner.presignGetObject(
                GetObjectPresignRequest.builder()
                        .signatureDuration(expiry)
                        .getObjectRequest(getRequest)
                        .build()
        )

        presigner.close()
        return presigned.url()
    }
}
