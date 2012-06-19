package au.org.ala.volunteer

import org.springframework.web.multipart.MultipartFile

class LocalityController {

    def localityService;

    def index = { }

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

        def results = localityService.importLocalities(collectionCode, f)

        flash.message = results.message

        render(view: 'load')
    }

    def searchFragment = {
        def taskInstance = Task.get(params.long("taskId"))
        [taskInstance: taskInstance]
    }

    def searchResultsFragment = {
        def taskInstance = Task.get(params.long("taskId"))
        if (taskInstance) {
            def q = params.searchLocality;
            def localities = localityService.findLocalities(q, taskInstance.project.featuredOwner, 500)
            return [taskInstance: taskInstance, localities: localities]
        }
    }
}
