package au.org.ala.volunteer

import grails.converters.JSON
import org.codehaus.groovy.grails.commons.ConfigurationHolder
import au.com.bytecode.opencsv.CSVWriter
import java.text.SimpleDateFormat
import groovy.sql.Sql
import javax.sql.DataSource
import java.sql.ResultSet
import javax.servlet.http.HttpServletRequest

class AjaxController {

    def taskService
    def userService
    def authService
    def taskLoadService
    def statsService
    DataSource dataSource

    def index = {
        render(['VolunteerPortal' : 'Version 1.0'] as JSON)
    }

    def stats = {

        setNoCache()

        def stats = [:]

        stats.specimensTranscribed = taskService.countTranscribedByProjectType("default")
        stats.journalPagesTranscribed = taskService.countTranscribedByProjectType("Journal")
        def volunteerCounts = userService.getUserCounts()
        stats.volunteerCount = volunteerCounts?.size()
        if (volunteerCounts?.size() >= 10) {
            stats.topTenVolunteers = volunteerCounts[0..9]
        }

        def projects = Project.list();
        stats.expeditionCount = projects.size()
        def projectCounts = taskService.getProjectTaskTranscribedCounts()
        def projectTranscribedCounts = taskService.getProjectTaskFullyTranscribedCounts()

        int completedCount = 0;
        int incompleteCount = 0;
        for (Project p : projects) {
            if (projectCounts[p.id] == projectTranscribedCounts[p.id]) {
                completedCount++;
            } else {
                incompleteCount++;
            }
        }

        stats.activeExpeditionsCount = incompleteCount;
        stats.completedExpeditionsCount = completedCount;

        render stats as JSON

    }

    def userReport = {

        setNoCache()

        if (!authService.userInRole("ROLE_VP_ADMIN")) {
            render "Must be logged in as an administrator to use this service!"
            return;
        }

        def report = []
        def users = User.list()

        for (User user : users) {
            def transcribedCount = Task.countByFullyTranscribedBy(user.userId)
            def validatedCount = Task.countByFullyValidatedBy(user.userId)
            def lastActivity = ViewedTask.executeQuery("select to_timestamp(max(vt.lastView)/1000) from ViewedTask vt where vt.userId = :userId", [userId: user.userId])[0]

            def projectCount = ViewedTask.executeQuery("select distinct t.project from Task t where t.fullyTranscribedBy = :userId", [userId:  user.userId]).size()

            report.add([user.userId, user.displayName, transcribedCount, validatedCount, lastActivity, projectCount, user.created])
        }

        // Sort by the transcribed count
        report.sort({ row1, row2 -> row2[2] - row1[2]})

        def nodata = params.nodata ?: 'nodata'

        if (params.wt && params.wt == 'csv') {

            def writer = new CSVWriter(response.writer, (char) '\t')
            writer.writeNext("user_id", "display_name", "transcribed_count", "validated_count", "last_activity", "projects_count", "volunteer_since")
            for (def row : report) {
                writer.writeNext((String) row[0], (String) row[1], (String) row[2], (String) row[3], (String) row[4] ?: nodata, (String) row[5], (String) row[6] )
            }
            writer.flush()
        } else {
            render report as JSON
        }
    }

    def loadProgress = {
        setNoCache()
        render( taskLoadService.status() as JSON)
    }

    def taskLoadReport = {
        setNoCache()
        response.addHeader("Content-type", "text/plain")

        def writer = new CSVWriter(response.writer, (char) '\t')
        writer.writeNext("time", "project", "task id", "succeeded", "message", "image url")

        def errors = taskLoadService.lastReport
        if (errors && errors.size() > 0) {
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss yyyy-MM-dd")
            for (def error : errors) {
                writer.writeNext( sdf.format(error.time), error.taskDescriptor.project.name, (String) error.taskDescriptor.externalIdentifier, (String) error.succeeded, error.message, error.taskDescriptor.imageUrl );
            }
        }
        writer.flush()
    }

    def expeditionInfo = {
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

    def expeditionBiocacheData = {

        setNoCache()
        response.addHeader("Content-type", "text/plain")
        def writer = new CSVWriter(response.writer)
        writer.writeNext("catalog_id", "institution_code", "scientific_name", "decimal_latitude","decimal_longitude","associated_media", "occurrence_id")

        if (params.id) {

            def fieldNames = ['catalogNumber', 'institutionCode', 'scientificName', 'decimalLatitude', 'decimalLongitude']

            def projectInstance = Project.get(params.id)
            if (projectInstance) {
                def fields = Field.findAll("from Field as f where f.task in (from Task as task where task.project = :project) and f.name in (:fields)",[project: projectInstance, fields: fieldNames]).groupBy { it.task }

                for (Task t : fields.keySet()) {
                    def fieldValues = fields[t]
                    def values = []
                    values.add(fieldValues.find { it.name == 'catalogNumber' } ?.value?:"")
                    values.add(fieldValues.find { it.name == 'institutionCode' } ?.value?:"")
                    values.add(fieldValues.find { it.name == 'scientificName' } ?.value?:"")
                    values.add(fieldValues.find { it.name == 'decimalLatitude' } ?.value?:"")
                    values.add(fieldValues.find { it.name == 'decimalLongitude' } ?.value?:"")
                    values.add("${ConfigurationHolder.config.server.url}${t.multimedia.toList()[0].filePath}")
                    values.add(createLink(controller: 'task', action: 'show', id: t.id, absolute: true ))
                    writer.writeNext((String[]) values.toArray())
                }
            }
        }

        writer.flush()
    }

    def keepSessionAlive = {
        render(['status':'ok', 'currentTime': formatDate(date: new Date(), format: "dd MMM yyyy hh:mm:ss"), systemMessage: flash.systemMessage ] as JSON)
    }

    private def setNoCache() {
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Cache-Control", "no-cache");
        response.addHeader("Cache-Control", "no-store");
    }

    def statsTranscriptionsByMonth = {
        def results = statsService.transcriptionsByMonth()
        println results
        render results as JSON
    }

}
