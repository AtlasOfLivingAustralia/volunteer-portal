package au.org.ala.volunteer

import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider
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

    @Bean
    S3Client awsS3Client() {
        return S3Client.builder()
                .region(Region.of(region))
                .credentialsProvider(DefaultCredentialsProvider.create())
                .build()
    }
}
