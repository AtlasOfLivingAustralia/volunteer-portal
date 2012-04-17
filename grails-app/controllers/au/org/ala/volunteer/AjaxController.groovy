package au.org.ala.volunteer

import grails.converters.JSON
import org.codehaus.groovy.grails.commons.ConfigurationHolder
import au.com.bytecode.opencsv.CSVWriter
import java.text.SimpleDateFormat

class AjaxController {

    def taskService;
    def userService;
    def authService;
    def taskLoadService;

    def index = {
        render(['VolunteerPortal' : 'Version 1.0'] as JSON)
    }

    def stats = {

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

        if (params.wt && params.wt == 'csv') {

            def writer = new CSVWriter(response.writer, (char) '\t')
            writer.writeNext("user_id", "display_name", "transcribed_count", "validated_count", "last_activity", "projects_count", "volunteer_since")
            for (def row : report) {
                writer.writeNext((String) row[0], (String) row[1], (String) row[2], (String) row[3], (String) row[4], (String) row[5], (String) row[6] )
            }
            writer.flush()
        } else {
            render report as JSON
        }
    }

    def loadProgress = {

        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 1L);
        response.setHeader("Cache-Control", "no-cache");
        response.addHeader("Cache-Control", "no-store");

        render( taskLoadService.status() as JSON)
    }

    def taskLoadReport = {

        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 1L);
        response.setHeader("Cache-Control", "no-cache");
        response.addHeader("Cache-Control", "no-store");
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

}
