package au.org.ala.volunteer

import org.hibernate.FlushMode
import java.util.regex.Pattern
import org.springframework.web.multipart.MultipartFile
import grails.converters.JSON

class CollectionEventController {

    def collectionEventService
    def logService

    def searchFragment() {
        def taskInstance = Task.get(params.int("taskId"))
        def collectors = []
        (0..3).each {
            collectors << params["collector" + it] ?: ""
        }
        def eventDate = params.eventDate
        [collectors:collectors, eventDate: eventDate, taskInstance: taskInstance]
    }

    def searchResultsFragment() {

        def taskInstance = Task.get(params.int("taskId"))

        int maxRows = params.maxResults ? params.int("maxResults") : 500;

        def eventDate = params.eventDate
        def events = []
        def finished = false;

        def collectors = []
        (0..3).each {
            collectors << params["collector" + it] ?: ""
        }

        int loopcount = 0;

        def locality = params.search_locality

        def queryDate = eventDate.toString();

        def useExpandedSearch = params.boolean('expandedSearch')

        while (!events && !finished && loopcount < 10) {

            List<List<String>> collectorNames = []
            (0..3).each {
                Arrays.asList(String.class)
                collectorNames << new ArrayList<String>(Arrays.asList((params["collector" + it] ?: "").split("\\.|\\s")))
            }

            while (collectorNames.find { it.size() > 0 }) {
                def queryCollectors = collectorNames.collect { it.join(" ")?.trim() }

                def collectionCode = taskInstance?.project?.collectionEventLookupCollectionCode ?: taskInstance?.project?.featuredOwner
                events = collectionEventService.findCollectionEvents(collectionCode, queryCollectors, queryDate, locality, maxRows)

                if (events && events.size() > 0 || !useExpandedSearch) {
                    finished = true;
                    break;
                }

                collectorNames.each { if (it.size() > 0) {
                    it.remove(0);
                }}

            }
            if (queryDate.indexOf("-") > 0 && useExpandedSearch) {
                queryDate = queryDate.substring(0, queryDate.lastIndexOf("-"))
            } else {
                finished = true;
                break;
            }

            loopcount++;
        }


        [collectors:collectors, eventDate: eventDate, collectionEvents: events, searchWidened: loopcount > 1, taskInstance: taskInstance]
    }

    def load() {
        def collectionCodes = collectionEventService.getCollectionCodes()?.join(", ");

        [collectionCodes: collectionCodes]
    }

    def loadCSV() {
        def collectionCode = params.collectionCode;
        MultipartFile f = request.getFile('csvfile')

        def results = collectionEventService.importEvents(collectionCode, f)

        flash.message = results.message

        render(view: 'load')
    }

    def getCollectionEventJSON() {

        CollectionEvent event = null;
        if (params.collectionEventId) {
            event = CollectionEvent.get(params.long("collectionEventId"))
        } else if (params.externalCollectionEventId && params.institutionCode) {
            event = CollectionEvent.findByExternalEventIdAndInstitutionCode(params.long('externalCollectionEventId'), params.institutionCode);
        }

        if (event) {
            render(event as JSON)
        } else {
            render(null as JSON)
        }
    }


}
