package au.org.ala.volunteer

import grails.gorm.transactions.Transactional
import groovy.json.JsonBuilder
import groovyx.net.http.ContentType
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

/**
 * Temp code before adding to Images Client Plugin
 */
//@Transactional
class ImageServiceService {

    def grailsApplication
    def imagesWebService

    private String getServiceUrl() {
        def url = grailsApplication.config.ala.image.service.url ?: "http://devt.ala.org.au:8080/ala-images"
        if (!url.endsWith("/")) {
            url += "/"
        }
        return url
    }

    static def postJSON(url, Map params) {
        def result = [:]
        HTTPBuilder builder = new HTTPBuilder(url)
        builder.request(Method.POST, ContentType.JSON) { request ->

            requestContentType : 'application/JSON'
            body = new JsonBuilder(params).toString()

            response.success = {resp, message ->
                result.status = resp.status
                result.content = message
            }

            response.failure = {resp ->
                result.status = resp.status
                result.error = "Error POSTing to ${url}"
            }

        }
        result
    }

    public Map getImageInfoForIds(List imageIds) {

        def url = "${serviceUrl}ws/getImageInfoForIdList"

        def results = postJSON(url, [imageIds: imageIds])

        if (results.status == 200) {
            def resultsMap = results.content.results
            def map = [:]
            imageIds.each { img ->

                def imgResults = resultsMap[img]
                if (imgResults) {
                    map[img] = imgResults
                }
            }
            return map
        } else {
            log.warn(results)
        }
        return null
    }
}
