package au.org.ala.volunteer

import org.hibernate.FlushMode
import java.util.regex.Pattern
import org.springframework.web.multipart.MultipartFile

class CollectionEventController {

    def collectionEventService

    def searchFragment = {
        def taskInstance = Task.get(params.int("taskId"))
        def collectors = []
        (0..3).each {
            collectors << params["collector" + it] ?: ""
        }
        def eventDate = params.eventDate
        [collectors:collectors, eventDate: eventDate, taskInstance: taskInstance]
    }

    def searchResultsFragment = {

        def taskInstance = Task.get(params.int("taskId"))

        int maxRows = params.maxResults ? params.int("maxResults") : 100;

        def collectors = []
        (0..3).each {
            collectors << params["collector" + it] ?: ""
        }

        def eventDate = params.eventDate
        def events = []
        def finished = false;
        def queryDate = eventDate.toString();

        int loopcount = 0;
        while (!events && !finished && loopcount < 10) {

            events = collectionEventService.findCollectionEvents(taskInstance.project.featuredOwner, collectors, queryDate, maxRows)

            if (queryDate.indexOf("-") > 0) {
                queryDate = queryDate.substring(0, queryDate.lastIndexOf("-"))
            } else {
                finished = true;
            }
            loopcount++;
        }

        [collectors:collectors, eventDate: eventDate, collectionEvents: events, searchWidened: loopcount > 1, taskInstance: taskInstance]
    }

    def load = {
        def collectionCodes = Project.createCriteria().list {
            projections {
                distinct("featuredOwner")
            }
        }

        [collectionCodes: collectionCodes]
    }

    def loadCSV = {
        def collectionCode = params.collectionCode;
        MultipartFile f = request.getFile('csvfile')

        def results = collectionEventService.importEvents(collectionCode, f)

        flash.message = results.message

        render(view: 'load')
    }


}
