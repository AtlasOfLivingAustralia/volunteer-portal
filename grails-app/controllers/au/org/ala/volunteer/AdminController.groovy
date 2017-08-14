package au.org.ala.volunteer

import groovy.time.TimeCategory
import org.elasticsearch.action.search.SearchType
import grails.plugins.csv.CSVWriter
import org.hibernate.FlushMode
import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.MultipartFile

import java.text.SimpleDateFormat

class AdminController {

    def taskService
    def grailsCacheAdminService
    def tutorialService
    def sessionFactory
    def userService
    def projectService
    def fullTextIndexService
    def domainUpdateService
    def taskLoadService
    def eventSourceService

    def index() {
        checkAdmin()
        return
    }

    def mailingList() {
        if (checkAdmin()) {
            def userIds = User.withCriteria {
                projections {
                    property('userId', 'userId')
                }
            }
            def emails = userService.getEmailAddressesForIds(userIds)
            def list = emails.join(";\n")
            render(text:list, contentType: "text/plain")
        }
    }

    boolean checkAdmin() {

        if (userService.isAdmin()) {
            return true;
        }

        flash.message = message(code: "admin.you_do_not_have_permission")
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
                    flash.message = message(code: "admin.file_must_be_one_of", args: [allowedMimeTypes])
                    redirect(action:'tutorialManagement')
                    return;
                }

                try {
                    tutorialService.uploadTutorialFile(f)
                    flash.message = message(code: "admin.tutorial_uploaded_successfully");
                } catch (Exception ex) {
                    flash.message = message(code: "admin.failed_to_upload_tutorial") + ex.message;
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
                flash.message = message(code: "admin.tutorial_deleted_successfully")
            } catch (Exception ex) {
               flash.message =message(code: "admin.failed_to_delete_tutorial") + ex.message
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
               flash.message =message(code: "admin.failed_to_rename_tutorial") + ex.message
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
                // find the collector i18nName
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

        def message = message(code: "admin.fields_updated_message", args: [count,collectorsFound])
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
                // Don't hit network to get email address here as it's only logging
                println "Updating transcribed count for ${user.userId} (${user.email}) from ${user.transcribedCount} to ${transcribedCount}"
                user.transcribedCount = transcribedCount
            }

            if (user.validatedCount < validatedCount) {
                // Don't hit network to get email address here as it's only logging
                println "Updating validated count for ${user.userId} (${user.email}) from ${user.validatedCount} to ${validatedCount}"
                user.validatedCount = validatedCount
            }
            count++
        }

        flash.message = message(code: "admin.users_checked")

        redirect(action:'index')
    }

    def currentUsers() {
    }

    def userActivityInfo() {
        def activities = UserActivity.list([sort:'timeLastActivity', order:'desc'])
        def emailToIdMap
        if (activities) {
            emailToIdMap = User.withCriteria {
                inList('email', activities*.userId)
                projections {
                    property('email')
                    property('userId')
                }
            }.toMap()
        } else {
            emailToIdMap = [:]
        }

        def actWithOpenEventSources = activities*.properties.collect { it + [ openESRequests: eventSourceService.getOpenRequestsForUser(emailToIdMap[it.userId] ?: '') ] }
        respond([activities: actWithOpenEventSources])
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

    def projectSummaryReport() {
        if (checkAdmin()) {
            def projects = Project.list([sort:'id'])

            def data = []

            def dates = taskService.getProjectDates()

            def projectSummaries = projectService.getProjectSummaryList()

            projects.each { project ->
                def summary = projectSummaries.projectRenderList.find { it.project.id == project.id }
                data << [project: project, summary: summary, dates: dates[project.id]]

            }

            response.setHeader("Content-Disposition", "attachment;filename=expedition-summary.csv");
            response.addHeader("Content-type", "text/plain")
            def sdf = new SimpleDateFormat("yyyy-MM-dd")

            def dateStr = { d ->
                if (d) {
                    return sdf.format(d)
                }
                return ""
            }

            def daysBetween = { Date d1, Date d2 ->
                if (d1 && d2) {
                    return TimeCategory.minus(d2, d1).days
                }
                return ""
            }

            def writer = new CSVWriter((Writer) response.writer,  {
                'Expedition Id' { it.project.id }
                'Expedtion Name' { it.project.i18nName }
                'Institution' { it.project.institution ? it.project.institution.i18nName : it.project.featuredOwner }
                'Institution Id' { it.project.institution?.id ?: "" }
                'Inactive' { it.project.inactive ? "t" : "f" }
                'Template' { it.project.template?.name }
                'Expedition Type' { it.project.projectType?.name ?: "<unknown>" }
                'Tasks' { it.summary?.taskCount ?: 0 }
                'Transcribed Tasks' { it.summary?.transcribedCount ?: 0 }
                'Validated Tasks' { it.summary?.validatedCount ?: 0 }
                'Percent Transcribed' { it.summary?.percentTranscribed }
                'Percent Validated' { it.summary?.percentValidated }
                'Active Transcribers' { it.summary?.transcriberCount }
                'Active Validators' { it.summary?.validatorCount }
                'Transcription Start Date' { dateStr(it.dates?.transcribeStartDate) }
                'Transcription End Date' { dateStr(it.dates?.transcribeEndDate) }
                'Time taken (Transcribe)' { daysBetween(it.dates?.transcribeStartDate, it.dates?.transcribeEndDate) }
                'Validation Start Date' { dateStr(it.dates?.validateStartDate) }
                'Validation End Date' { dateStr(it.dates?.validateEndDate) }
                'Time taken (Validate)' { daysBetween(it.dates?.validateStartDate, it.dates?.validateEndDate) }

            })

            for (def row : data) {
                writer << row
            }
            response.flushBuffer()
        }
    }

    def reindexAllTasks() {
        if (checkAdmin()) {

            def c = Task.createCriteria()
            def results = c.list() {
                projections {
                    property("id")
                    order("lastViewed", "desc")
                }
            }

            results?.each { long taskId ->
                DomainUpdateService.scheduleTaskIndex(taskId)
            }

        }
        redirect(action:'tools')
    }

    def rebuildIndex() {
        if (checkAdmin()) {
            fullTextIndexService.reinitialiseIndex()
        }

        redirect(action:'tools')
    }
    
    def testQuery(String query, String searchType, String aggregation) {
        def searchTypeVal = searchType ? SearchType.fromString(searchType) : SearchType.DEFAULT
        log.debug("SearchType: $searchType, $searchTypeVal")

//        def offset = params.offset
//        def

        def result = fullTextIndexService.rawSearch(query, searchTypeVal, aggregation, fullTextIndexService.elasticSearchToJsonString)
        
        response.setContentType("application/json")
        render result
    }

    // clear the grails gsp caches
    def clearPageCaches() {
        if (!checkAdmin()) {
            render status: 403
            return
        }
        grailsCacheAdminService.clearTemplatesCache()
        grailsCacheAdminService.clearBlocksCache()
        flash.message = message(code: "admin.template_and_blocks_caches_cleared")
        redirect action: 'tools'
    }

    def clearAllCaches() {
        if (!checkAdmin()) {
            render status: 403
            return
        }
        grailsCacheAdminService.clearAllCaches()
        flash.message = message(code: "admin.all_caches_cleared")
        redirect action: 'tools'
    }

    def stagingTasks() {
        if (!checkAdmin()) {
            render status: 403
            return
        }

        def status = taskLoadService.status()
        def queueItems = taskLoadService.currentQueue()

        respond queueItems, model: [status: status]
    }

    def cancelStagingQueue() {
        if (!checkAdmin()) {
            render status: 403
            return
        }

        taskLoadService.cancelLoad()
        flash.message = message(code: "admin.task_load_cancel_message_sent")

        redirect action: 'stagingTasks'
    }

    def clearStagingQueue() {
        if (!checkAdmin()) {
            render status: 403
            return
        }

        def items = taskLoadService.clearQueue()
        flash.message = message(code: "admin.task_load_queue_cleared", args: [items.join(', ')])


        redirect action: 'stagingTasks'
    }

    def updateUsers() {
        if (!checkAdmin()) {
            render status: 403
            return
        }

        userService.updateAllUsers()

        redirect(controller: 'user', action: 'list')
    }

}
