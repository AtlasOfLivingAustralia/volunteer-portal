package au.org.ala.volunteer

class TutorialsController {

    def tutorialService

    def index = {
        def tutorials = tutorialService.getTutorialGroups()
        [tutorials: tutorials]
    }

    def transcribingFieldNotes = {
        redirect(url: resource(dir: 'pdf', file: 'fieldNotesTutorial.pdf'))
    }

    def transcribingSpecimenLabels = {
    }

    def transcribingAnicCockroaches = {
    }
}
