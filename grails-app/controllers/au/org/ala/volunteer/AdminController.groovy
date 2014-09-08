package au.org.ala.volunteer

import org.hibernate.FlushMode
import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.MultipartFile
import org.apache.commons.lang.StringUtils
import grails.converters.JSON

class AdminController {

    def authService
    def taskService
    def grailsApplication
    def tutorialService
    def sessionFactory
    def userService

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

        if (userService.isAdmin()) {
            return true;
        }

        flash.message = "You do not have permission to view this page"
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

    /**
     * Some template definitions include recordedByID as a hidden field which conflicts with an existing "hard-coded" version of the same field
     * This results in the field values becoming an array, which ends up causing the value to lost completely as the array is 'toString'ed into the database
     * This routine attempts to find all 'recorded by id' fields whose value contains 'String' and attempts to look up the real collector id from a relevant picklist.
     * It is entirely possible that not collector id can be found, in which case the field value is cleared
     */
    def fixRecordedByID() {
        if (!checkAdmin()) {
             throw new RuntimeException("Not authorised!")
        }

        // First find the candidate fields
        def fields = Field.findAllByNameAndValueLikeAndSuperceded('recordedByID', '%String%', false)
        def count = 0
        def collectorsFound = 0
        def picklist = Picklist.findByName("recordedBy")

        sessionFactory.currentSession.setFlushMode(FlushMode.MANUAL)

        try {
            fields.each { field ->
                // find the collector name
                def collectorNameField = Field.findByTaskAndNameAndRecordIdxAndSuperceded(field.task, "recordedBy", field.recordIdx, false)
                def collectorName = collectorNameField?.value
                def newValue = ''

                if (collectorName) {
                    def instCode = field.task.project.picklistInstitutionCode
                    def items
                    if (instCode) {
                        items = PicklistItem.findAllByPicklistAndInstitutionCodeAndValue(picklist, instCode, collectorName)
                    } else {
                        items = PicklistItem.findAllByPicklistAndValue(picklist, collectorName)
                    }

                    if (items && items.size() > 0) {

                        if (items.size() == 1 && items[0].key) {
                            newValue = items[0].key
                            println "1st chance. Found one collector number for ${collectorName}: ${newValue}"
                        } else {
                            for (int i = 0; i < items.size(); ++i) {
                                def item = items[i]
                                if (item.key) {
                                    println "2nd chance. Found a collector number for ${collectorName}: ${newValue}"
                                    newValue = item.key
                                    break;
                                }
                            }
                        }
                    }
                }

                println "Updating field ${field.id} value from '${field.value}' to '${newValue}'."
                field.value = newValue;

                if (newValue) {
                    collectorsFound++
                }

                count++
                if (count % 1000 == 0) {
                    // Doing this significantly speeds up imports...
                    sessionFactory.currentSession.flush()
                    println "${count} rows flushed."
                }
            }
            // flush the last lot
            sessionFactory.currentSession.flush()
        } finally {
            sessionFactory.currentSession.flushMode = FlushMode.AUTO
        }

        def message = "${count} fields updated, $collectorsFound of which were set to a collector number."
        flash.message = message
        println message

        redirect(action:'index')
    }


    def fixUserCounts() {

        if (!checkAdmin()) {
             throw new RuntimeException("Not authorised!")
        }

        def users = User.list();
        int count = 0
        users.each { user ->
            def transcribedCount = Task.countByFullyTranscribedBy(user.userId)
            def validatedCount = Task.countByFullyValidatedBy(user.userId)

            if (user.transcribedCount < transcribedCount) {
                println "Updating transcribed count for ${user.userId} from ${user.transcribedCount} to ${transcribedCount}"
                user.transcribedCount = transcribedCount
            }

            if (user.validatedCount < validatedCount) {
                println "Updating validated count for ${user.userId} from ${user.validatedCount} to ${validatedCount}"
                user.validatedCount = validatedCount
            }
            count++
        }

        flash.message ="${count} users checked."

        redirect(action:'index')
    }

    def currentUsers() {
    }

    def userActivityFragment() {
        def activities = UserActivity.list([sort:'timeLastActivity', order:'desc'])
        [activities: activities]
    }

    def tools() {
    }

    def mappingTool() {

    }

    def migrateProjectsToInstitutions() {
        final projectsWithOwners = Project.executeQuery("select new map (id as id, name as name, featuredOwner as featuredOwner) from Project where institution is null order by ${params.sort ?: 'featuredOwner'} ${params.order ?: 'asc'}").each { it.put('lowerFeaturedOwner', it?.featuredOwner?.replaceAll('\\s', '')?.toLowerCase()) }
        final insts = Institution.executeQuery("select new map(id as id, name as name) from Institution").each { it.put('lowerName', it?.name?.replaceAll('\\s', '')?.toLowerCase()) }

        final projectsWithScores = projectsWithOwners.collect { proj ->
            final projOwner = proj.lowerFeaturedOwner ?: ''
            final scores = insts.collect {
                final name = it.lowerName ?: ''
                [id: it.id, name: it.name, score: Fuzzy.ldRatio(projOwner, name)]
            }.sort { it.score }.reverse()//.subList(0, 10)
            [id: proj.id, name: proj.name, owner: proj.featuredOwner, scores: scores ]
        }

        respond projectsWithScores, model: [projectsWithScores: projectsWithScores]
    }

    def doMigrateProjectsToInstitutions() {
        def cmd = request.JSON
        cmd.each {
            def proj = Project.get(it.id)
            proj.institution = Institution.get(it.inst)
            proj.save()
        }
        render status: 205
    }

}
