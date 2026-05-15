package au.org.ala.volunteer

import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.s3.S3Client

/**
 * Factory for creating S3Client instances. This allows for centralized configuration and easier testing.
 */
@Configuration
@ConditionalOnProperty(name="aws.s3.enabled", havingValue="true")
class S3ClientFactory {

    @Value('${aws.s3.region}')
    String region

    @Value('${aws.s3.auth-mode}')
    String authMode = AUTH_MODE_DEFAULT

    @Value('${aws.s3.access-key:}')
    String accessKey

    @Value('${aws.s3.access-secret:}')
    String secretKey

    public static final String AUTH_MODE_DEFAULT = "default"
    public static final String AUTH_MODE_SECRET = "secret"

    @Bean
    S3Client awsS3Client() {

        // If credentials are provided via properties, use them
        if (authMode == AUTH_MODE_SECRET) {
            if (!accessKey || !secretKey) {
                throw new IllegalStateException("AWS S3 access key and secret key must be provided when auth mode is set to 'secret'. Please set 'aws.s3.access-key' and 'aws.s3.access-secret' in the application configuration.")
            }
            return S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(
                            StaticCredentialsProvider.create(
                                    AwsBasicCredentials.create(accessKey, secretKey)
                            )
                    )
                    .build()
        } else if (authMode == AUTH_MODE_DEFAULT) {
            // Use default credentials provider (e.g. environment variables, EC2 instance profile, etc.)
            return S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(DefaultCredentialsProvider.create())
                    .build()
        } else {
            throw new IllegalStateException("Invalid AWS S3 authentication mode: ${authMode}. Supported modes are 'default' and 'secret'. Please set 'aws.s3.auth-mode' in the application configuration.")
        }
    }
}
