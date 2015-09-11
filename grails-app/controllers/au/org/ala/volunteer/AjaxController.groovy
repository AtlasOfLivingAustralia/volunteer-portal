package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryProviderDto
import com.google.common.base.Stopwatch
import com.google.common.collect.ImmutableMap
import com.google.common.collect.Sets
import com.google.gson.Gson
import grails.converters.JSON
import grails.converters.XML

import java.text.SimpleDateFormat
import groovy.sql.Sql
import javax.sql.DataSource
import java.sql.ResultSet
import org.grails.plugins.csv.CSVWriter
import org.grails.plugins.csv.CSVWriterColumnsBuilder

import static grails.async.Promises.*

class AjaxController {

    def taskService
    def userService
    def taskLoadService
    def statsService
    DataSource dataSource
    def multimediaService
    def institutionService
    def domainUpdateService
    def authService
    def settingsService
    def achievementService
    def sessionFactory

    static responseFormats = ['json', 'xml']

    def index() {
        def results = [ "${message(code:"default.application.name")}" : 'Version 1.0']
        respond results
    }

    def stats() {

        setNoCache()

        def stats = [:]

        def projectTypes = ProjectType.list()

        projectTypes.each {
            def projects = Project.findAllByProjectType(it)
            stats[it.description ?: it.name] = Task.countByProjectInList(projects)
        }
        
        def volunteerCounts = userService.userCounts
        stats.volunteerCount = volunteerCounts?.size()
        if (volunteerCounts?.size() >= 10) {
            stats.topTenVolunteers = volunteerCounts[0..9]
        }

        def projects = Project.list();
        stats.expeditionCount = projects.size()
        def projectCounts = taskService.getProjectTaskTranscribedCounts()
        def projectTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()

        int completedCount = 0
        int incompleteCount = 0
        int deactivated = 0
        for (Project p : projects) {
            if (p.inactive) {
                deactivated++
            } else {
                if (projectCounts[p.id] == projectTranscribedCounts[p.id]) {
                    completedCount++
                } else {
                    incompleteCount++
                }
            }
        }

        stats.activeExpeditionsCount = incompleteCount
        stats.completedExpeditionsCount = completedCount
        stats.deactivatedExpeditionsCount = deactivated

        respond stats
    }

    def userReport() {

        setNoCache()

        if (!userService.isAdmin()) {
            render "Must be logged in as an administrator to use this service!"
            return;
        }


        // Pre-create the writer and write the headings straight away to prevent a read timeout.
        def writer
        if (params.wt && params.wt == 'csv') {
            def nodata = params.nodata ?: 'nodata'

            response.addHeader("Content-type", "text/plain")

            writer = new CSVHeadingsWriter((Writer) response.writer, {
                'user_id' { it[0] }
                'display_name' { it[1] }
                'organisation' { it[2] }
                'location' { it[3] }
                'transcribed_count' { it[4] }
                'validated_count' { it[5] }
                'last_activity' { it[6] ?: nodata }
                'projects_count' { it[7] }
                'volunteer_since' { it[8] }
            })
            writer.writeHeadings()
            response.flushBuffer()
        }


        def asyncCounts = Task.async.withStatelessSession {
            def sw1 = new Stopwatch().start()
            def vs = (Task.withCriteria {
                projections {
                    groupProperty('fullyValidatedBy')
                    count('id')
                }
            }).collectEntries { [(it[0]): it[1]] }
            def ts = (Task.withCriteria {
                projections {
                    groupProperty('fullyTranscribedBy')
                    count('id')
                }
            }).collectEntries { [(it[0]): it[1]] }
            sw1.stop()
            log.debug("UserReport counts took ${sw1.toString()}")
            [vs: vs, ts: ts]
        }

        def asyncLastActivities = ViewedTask.async.withStatelessSession {
            def sw2 = new Stopwatch().start()
            def lastActivities = ViewedTask.executeQuery("select vt.userId, to_timestamp(max(vt.lastView)/1000) from ViewedTask vt group by vt.userId").collectEntries { [(it[0]): it[1]] }
            sw2.stop()
            log.debug("UserReport viewedTasks took ${sw2.toString()}")
            lastActivities
        }

        def asyncProjectCounts = Task.async.withStatelessSession {
            def sw4 = new Stopwatch().start()
            def projectCounts = Task.executeQuery("select t.fullyTranscribedBy, count(distinct t.project) from Task t group by t.fullyTranscribedBy ").collectEntries { [(it[0]): it[1]] }
            sw4.stop()
            log.debug("UserReport projectCounts took ${sw4.toString()}")
            projectCounts
        }

        def sw3 = new Stopwatch().start()
        def asyncUserDetails = User.async.list().then { users ->
            def serviceResults = [:]
            try {
                serviceResults = authService.getUserDetailsById(users*.userId, true)
            } catch (Exception e) {
                log.warn("couldn't get user details from web service", e)
            }
            sw3.stop()
            log.debug("UserReport user details took ${sw3.toString()}")

            [users: users, results: serviceResults]
        }

        def asyncResults = waitAll(asyncCounts, asyncLastActivities, asyncProjectCounts, asyncUserDetails)

        // transform raw results into map(id -> count)
        def validateds = asyncResults[0].vs
        def transcribeds = asyncResults[0].ts

        def lastActivities = asyncResults[1]
        def projectCounts = asyncResults[2]

        def users = asyncResults[3].users
        def serviceResults = asyncResults[3].results

        def report = []

        def sw5 = new Stopwatch().start()
        for (User user: users) {
            def id = user.userId
            def transcribedCount = transcribeds[id] ?: 0
            def validatedCount = validateds[id] ?: 0
            def lastActivity = lastActivities[id]
            def projectCount = projectCounts[id]?: 0

            def serviceResult = serviceResults?.users?.get(id)
            def location = (serviceResult?.city && serviceResult?.state) ? "${serviceResult?.city}, ${serviceResult?.state}" : (serviceResult?.city ?: (serviceResult?.state ?: ''))
            report.add([serviceResult?.userName ?: user.email, serviceResult?.displayName ?: user.displayName, serviceResult?.organisation ?: user.organisation ?: '', location, transcribedCount, validatedCount, lastActivity, projectCount, user.created])
        }
        sw5.stop()
        log.debug("UserReport generate report took ${sw5}")

        sw5.reset().start()
        // Sort by the transcribed count
        report.sort({ row1, row2 -> row2[3] - row1[3]})
        sw5.stop()
        log.debug("UserReport sort took ${sw5.toString()}")


        if (params.wt && params.wt == 'csv') {

            for (def row : report) {
                writer << row
            }
            response.flushBuffer()
        } else {
            respond report
        }
    }

    def loadProgress() {
        setNoCache()
        respond taskLoadService.status()
    }

    def taskLoadReport() {
        setNoCache()
        response.addHeader("Content-type", "text/plain")

        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss yyyy-MM-dd")

        def writer = new CSVWriter(response.writer,  {
            'time' { sdf.format(it.time) }
            'project' { it.taskDescriptor?.project?.name }
            'task_id' { it.taskDescriptor?.externalIdentifier }
            'succeeded' { it.succeeded }
            'error_message' { it.message }
            'image_url' { it.taskDescriptor?.imageUrl  }
        })

        def errors = taskLoadService.lastReport
        if (errors && errors.size() > 0) {
            for (def error : errors) {
                writer << error
            }
        }
        response.writer.flush()
    }

    def expeditionInfo() {
        setNoCache()
        def sql = new Sql(dataSource:dataSource)

        def projects = Project.list()
        def results = []
        for (Project p : projects) {
            def project = [:]
            project.name = p.name
            project.description = p.description
            project.expeditionPageURL = createLink(controller: 'project', action: 'index', id: p.id, absolute: true)
            project.taskCount = Task.countByProject(p)
            project.transcribedCount = Task.countByProjectAndFullyTranscribedByNotIsNull(p)
            project.validatedCount = Task.countByProjectAndFullyValidatedByNotIsNull(p)

            sql.query("select count(distinct(fully_transcribed_by)) from task where project_id = ${p.id} and length(fully_transcribed_by) > 0") { ResultSet rs ->
                if (rs.next()) {
                    project.volunteerCount = rs.getInt(1)
                }
            }

            project.dataURL = createLink(controller: 'ajax', action: 'expeditionBiocacheData', id: p.id, absolute: true)

            results.add(project)
        }

        render results as JSON
    }

    def expeditionBiocacheData() {
        setNoCache()
        response.addHeader("Content-type", "text/plain")

        if (params.id) {
            def projectInstance = Project.get(params.id)
            if (projectInstance) {

                def findValue = { List<Field> fieldValues, String name ->
                    fieldValues.find { it.name == name } ?.value?:""
                }

                def columns = {
                    'catalogNumber' { findValue(it.fieldValues, 'catalogNumber') }
                    'institutionCode' { findValue(it.fieldValues, 'institutionCode') }
                    'scientificName' { findValue(it.fieldValues, 'scientificName') }
                    'decimalLatitude' { findValue(it.fieldValues, 'decimalLatitude') }
                    'decimalLongitude' { findValue(it.fieldValues, 'decimalLongitude') }
                    'locality' { findValue(it.fieldValues, 'locality')}
                    'transcriber' { it.task.fullyTranscribedBy }
                    'eventDate' { findValue(it.fieldValues, 'eventDate') }
                    'associatedMedia' { multimediaService.getImageUrl((Multimedia) it.task?.multimedia?.first()) }
                    'occurrenceId' { createLink(controller: 'task', action: 'show', id: it?.task?.id, absolute: true ) }
                }

                def fieldNames = new CSVWriterColumnsBuilder(columns).columns.collect { it.key }
                def writer = new CSVWriter(response.writer, columns)
                def fields = Field.findAll("from Field as f where f.task in (from Task as task where task.project = :project) and f.superceded = false and f.name in (:fields)",[project: projectInstance, fields: fieldNames]).groupBy { it.task }

                for (Task t : fields.keySet()) {
                    writer << [task: t, fieldValues: fields[t]]
                }

                response.writer.flush()
            }
        } else {
            render([success: false, message:"Unable to retrieve project with id '${params.id}'"] as JSON)
        }
    }

    def keepSessionAlive() {
        def results = ['success':'true', 'currentTime': formatDate(date: new Date(), format: DateConstants.DATE_TIME_FORMAT), systemMessage: flash.systemMessage ]
        respond results
    }

    private def setNoCache() {
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Cache-Control", "no-cache");
        response.addHeader("Cache-Control", "no-store");
    }

    def statsTranscriptionsByMonth() {
        def results = statsService.transcriptionsByMonth()
        respond results
    }

    def statsValidationsByMonth() {
        def results = statsService.validationsByMonth()
        respond results
    }

    def taskInfo() {
        def task = Task.get(params.int("id") ?: params.int("taskId"))
        if (task) {
            def taskInfo = [:]
            taskInfo.projectId = task.project.id
            taskInfo.externalIdentifier = task.externalIdentifier
            taskInfo.externalUrl = task.externalUrl
            taskInfo.fullyTranscribedBy = task.fullyTranscribedBy
            taskInfo.fullyValidatedBy = task.fullyValidatedBy
            taskInfo.isValid = task.isValid
            taskInfo.created = task.created?.format("yyyy-MM-dd HH:mm:ss")
            taskInfo.fields = []
            task.fields.each { field ->
                def fieldInfo = [fieldId: field.id ]
                fieldInfo.name = field.name
                fieldInfo.value = field.value
                fieldInfo.recordIdx = field.recordIdx
                fieldInfo.transcribedByUserId = field.transcribedByUserId
                fieldInfo.validatedByUserId = field.validatedByUserId
                fieldInfo.superceded = field.superceded
                fieldInfo.created = field.created?.format("yyyy-MM-dd HH:mm:ss")
                fieldInfo.updated = field.updated?.format("yyyy-MM-dd HH:mm:ss")
                taskInfo.fields << fieldInfo
            }
            taskInfo.multimedia = []
            task.multimedia.each { mm ->
                def mmInfo = [multimediaId: mm.id]
                mmInfo.licence = mm.licence
                mmInfo.mimeType = mm.mimeType
                mmInfo.created = mm.created?.format("yyyy-MM-dd HH:mm:ss")
                mmInfo.creator = mm.creator
                mmInfo.url = multimediaService.getImageUrl(mm)
                taskInfo.multimedia << mmInfo
            }
            respond taskInfo
        } else {
            respond null // 404
        }
    }

    def harvest() {
        harvesting()
    }

    def harvesting() {
        final harvestables = Project.findAllByHarvestableByAla(true)
        def results = harvestables.collect({
            final link = createLink(absolute: true, controller: 'project', action: 'index', id: it.id)
            final fullyTranscribedCount = it.tasks.count { t -> t.dateFullyTranscribed as boolean }
            final fullyValidatedCount = it.tasks.count { t -> t.dateFullyValidated as boolean }
            final dataUrl = createLink(absolute: true, controller:'ajax', action:'expeditionBiocacheData', id: it.id)
            final topics = ProjectForumTopic.findAllByProject(it)
            def forumMessagesCount = 0
            if (topics) {
                topics.each { topic -> forumMessagesCount += (ForumMessage.countByTopicAndDeleted(topic, false) ?: 0) + (ForumMessage.countByTopicAndDeletedIsNull(topic) ?: 0) }
            }
            [id: it.id, name: it.name, description: it.description, forumMessagesCount: forumMessagesCount, newsItemsCount: it.newsItems.size(), tasksCount: it.tasks.size(), tasksTranscribedCount: fullyTranscribedCount, tasksValidatedCount: fullyValidatedCount, expeditionHomePage: link, dataUrl: dataUrl]
        })

        respond results
    }

    def collectoryObjectDetails(String id) {
        final gson = new Gson()
        CollectoryProviderDto provider = institutionService.getCollectoryObjectFromUid(id)
        withFormat {
            json { render(text: gson.toJson(provider), contentType: 'application/json', encoding: 'UTF-8') }
            xml { render provider as XML }
        }
    }

    def availableCollectoryProviders() {

        def collectoryObjects = institutionService.getCombinedInsitutionsAndCollections()

        def instById = collectoryObjects.collectEntries { ImmutableMap.of(it.uid, it) }
        def ids = instById.keySet()
        def existing = Institution.executeQuery("select collectoryUid from Institution where collectoryUid in :ids", [ids: ids])
        def missing = Sets.difference(ids, existing.toSet())

        def results = missing.collect {
            def inst = instById[it]
            [id: it, name: inst.name]
        }
        respond results
    }

    def getUpdateQueueLength() {
        def length = domainUpdateService.getQueueLength()
        def results = ['success': true, 'queueLength': length]
        respond results
    }

    def acceptAchievements() {
        def ids = params.list('ids[]') ?: []
        def longIds = ids*.toLong()
        if (!longIds) {
            render status: 204
            return
        }
        def cu = userService.currentUser
        def validAwards = AchievementAward.findAllByIdInListAndUser(longIds, cu)
        if (validAwards) achievementService.markAchievementsViewed(validAwards*.id)
        render status: 204
    }

}
