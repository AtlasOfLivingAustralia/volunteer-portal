package au.org.ala.volunteer

import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.MultipartFile
import org.apache.commons.lang.StringUtils
import grails.converters.JSON

class AdminController {

    def authService
    def taskService
    def grailsApplication
    def tutorialService

    def index = {
        checkAdmin()
    }

    def mailingList = {
        if (checkAdmin()) {
            def userIds = User.all.collect{ it.userId }
            def list = userIds.join(";\n")
            render(text:list, contentType: "text/plain")
        }
    }

    boolean checkAdmin() {
        def currentUser = authService.username()
        if (currentUser != null && authService.userInRole(CASRoles.ROLE_ADMIN)) {
            return true;
        }

        flash.message = "You do not have permission to view this page (${CASRoles.ROLE_ADMIN} required)"
        redirect(uri:"/")
    }

    def tutorialManagement() {
        def tutorials = tutorialService.listTutorials()
        [tutorials: tutorials]
    }

    def uploadTutorial() {

        if(request instanceof MultipartHttpServletRequest) {
            MultipartFile f = ((MultipartHttpServletRequest) request).getFile('tutorialFile')
            if (f != null) {
                def allowedMimeTypes = ['application/pdf']
                if (!allowedMimeTypes.contains(f.getContentType())) {
                    flash.message = "The file must be one of: ${allowedMimeTypes}"
                    redirect(action:'tutorialManagement')
                    return;
                }

                try {
                    tutorialService.uploadTutorialFile(f)
                } catch (Exception ex) {
                    flash.message = "Failed to upload tutorial file: " + ex.message;
                }

            }
        }

        redirect(action:'tutorialManagement')
    }

    def deleteTutorial() {
        def filename = params.tutorialFile
        if (filename) {
            try {
                tutorialService.deleteTutorial(filename)
            } catch (Exception ex) {
               flash.message ="Failed to delete tutorial file: " + ex.message
            }
        }
        redirect(action:'tutorialManagement')
    }

    def renameTutorial() {
        def filename = params.tutorialFile
        def newName = params.newName

        if (filename && newName) {
            try {
                tutorialService.renameTutorial(filename, newName)
            } catch (Exception ex) {
               flash.message ="Failed to rename tutorial file: " + ex.message
            }
        }

        redirect(action:'tutorialManagement')

    }

    def fixCollectionEvents = {
        if (!checkAdmin()) {
             throw new RuntimeException("Not authorised!")
        }

        def c = Field.createCriteria()

        def fields = c {
            and {
                eq("name", "eventID")
                eq("superceded", false)
                isNotNull("value")
                ne("value", "")
            }
        }

        if (!params.collectionCode) {
            params.collectionCode = "ANIC"
        }

        // def fields = Field.findAllByNameAndSuperceded("eventID", false)

        fields.removeAll {
            StringUtils.isEmpty(it.value)
        }

        if (params.collectionCode) {
            fields.removeAll {
                it.task.project.collectionEventLookupCollectionCode != params.collectionCode
            }
        }

        def candidateMap = [:]
        fields.each { field ->
            def collectionCode = field.task.project.collectionEventLookupCollectionCode
            def candidates = []
            def event = CollectionEvent.findByExternalEventIdAndInstitutionCode(field.value, collectionCode)
            if (event) {
                candidates << event
            }
            def events = CollectionEvent.findByExternalLocalityIdAndInstitutionCode(field.value, collectionCode)
            events?.each {
                if (!candidates.contains(it)) {
                    candidates << it
                }
            }
            candidateMap[field.task.id] = candidates
        }

        [fields:fields, candidateMap: candidateMap]
    }

    def updateEventId() {
        def field = Field.get(params.int("fieldId"))
        def eventId = params.externalEventId

        if (field && eventId) {
            println "Uppdating field " + field.id + " to " + eventId
            field.value = eventId
        }

        render([status:'ok'] as JSON)
    }

}
