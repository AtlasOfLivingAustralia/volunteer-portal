package au.org.ala.volunteer

class TutorialsController {

    def index = {
        render(view: '/tutorials')
    }

    def transcribingFieldNotes = {
        redirect(url: resource(dir: 'pdf', file: 'fieldNotesTutorial.pdf'))
    }

    def transcribingSpecimenLabels = {
    }

    def transcribingAnicCockroaches = {
    }
}
