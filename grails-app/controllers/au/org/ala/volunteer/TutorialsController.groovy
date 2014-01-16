package au.org.ala.volunteer

class TutorialsController {

    def tutorialService

    def index = {
        def tutorials = tutorialService.getTutorialGroups()
        [tutorials: tutorials]
    }

}
