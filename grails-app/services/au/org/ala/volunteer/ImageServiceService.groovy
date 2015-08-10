package au.org.ala.volunteer

import grails.transaction.Transactional

/**
 * Temp code before adding to Images Client Plugin
 */
//@Transactional
class ImageServiceService {

    def imagesWebService

    public Map getImageInfoForIds(List imageIds) {

        def url = "${imagesWebService.serviceUrl}ws/getImageInfoForIdList"

        def results = imagesWebService.postJSON(url, [imageIds: imageIds])

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
            println results
        }
        return null
    }
}
