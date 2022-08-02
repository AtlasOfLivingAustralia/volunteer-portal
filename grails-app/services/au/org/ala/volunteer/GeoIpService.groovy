package au.org.ala.volunteer

import au.org.ala.volunteer.freegeoip.FreeGeoipClient
import com.google.gson.FieldNamingPolicy
import com.google.gson.GsonBuilder
import grails.gorm.transactions.NotTransactional
import grails.plugin.cache.Cacheable
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

import javax.annotation.PostConstruct

class GeoIpService {

    def grailsApplication
    FreeGeoipClient geoipClient

    @PostConstruct
    def init() {
        final baseUrl = grailsApplication.config.freegeoip.baseUrl ?: 'https://freegeoip.net'
        final gson = new GsonBuilder().setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES).create()
        final retrofit = new Retrofit.Builder().baseUrl(baseUrl).addConverterFactory(GsonConverterFactory.create(gson)).build()
        geoipClient = retrofit.create(FreeGeoipClient)
    }

    @Cacheable('geoip')
    def lookup(String ip) {
        try {
            final call = geoipClient.getIpGeolocation(ip).execute()
            if (call.successful) {
                return call.body()
            } else {
                log.info("Geo IP service allocation exhausted")
            }
        } catch (e) {
            log.info("Geo IP service is unavailable")
        }
        return null
    }
}
