package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.gorm.transactions.Transactional
import groovy.util.logging.Slf4j

import java.text.SimpleDateFormat

@Slf4j
@Transactional
class ReportRequestService {

    def grailsApplication
    def taskService
    def authService

    static final String FILE_DIR_HOME = "reports"
    static final String REPORT_NAME_USER = "user"
    static final String NO_DATA = "nodata"

    private String getReportDirectory() {
        return grailsApplication.config.getProperty('images.home', String) + "/" + FILE_DIR_HOME
    }

    private String getReportFilename(ReportRequest reportRequest, String fileExtension) {
        return "${reportRequest.reportName}-${reportRequest.id}.${fileExtension}"
    }

    private String createFilePath(String name) {
        return reportDirectory + "/" + name
    }

    private final Closure taggedUserReportColumnsDef = {
        'user_id' { it[0] }
        'display_name' { it[1] }
        'email' { it[2] }
        'time_transcribed' { it[3] }
        'task_institution' { it[4] }
        'task_expedition' { it[5] }
        'task_id' { it[6] }
        'date_transcribed' { it[7] }
    }

    /**
     *
     */
    def processPendingReportRequests() {
        log.info("ReportRequestService: Process Pending Report Requests")
        def dir = new File(reportDirectory)
        if (!dir.exists()) {
            dir.mkdirs();
        }

        def pendingReports = ReportRequest.findAllByDateCompletedIsNull(sort: "dateCreated", order: "asc")
        // Get the first one only.
        def report = pendingReports?.first()
        if (report) {
            switch(report.reportName) {
                case REPORT_NAME_USER:
                    userReport(report)
            }
        }
    }

    /**
     *
     * @param reportRequest
     */
    def userReport(ReportRequest reportRequest) {
        def fileName = getReportFilename(reportRequest, 'csv')
        def filePath = createFilePath(fileName)
        def csvFile = new File(filePath)

        if (csvFile.exists()) {
            // Stop, another process may be writing to the file, so don't continue.
            return
        }

        // Report Parameters
        def params = reportRequest.reportParams
        //def startDate = params.get('dateStart') as String
        def startDate = new SimpleDateFormat(DateConstants.DATE_TIME_FORMAT).parse(params.get('dateStart') as String)
        //def endDate = params.dateEnd
        def endDate = new SimpleDateFormat(DateConstants.DATE_TIME_FORMAT).parse(params.get('dateEnd') as String)
        def labelFilter = params.labelFilter != "null" ? Label.findById(params.labelFilter as Long) : null

        def writer = new PrintWriter(csvFile)
        def csvWriter = new CSVHeadingsWriter(writer, taggedUserReportColumnsDef)
        csvWriter.writeHeadings()

        /*
        def asyncCounts = Task.async.withStatelessSession {
            getTaskCounts()
        }
         */

        /*
        def asyncUserActivities = ViewedTask.async.withStatelessSession {
            def sw2 = Stopwatch.createStarted()
            def userActivity = taskService.getUserActivityBetweenDates(startDate, endDate)
            sw2.stop()
            log.debug("UserReport user activity took ${sw2.toString()}")
            userActivity
        }
         */

        def asyncTranscribeTimes = Task.async.withStatelessSession {
            getTranscribeTimes(startDate, endDate)
        }

        def asyncTaskCounts = Task.async.withStatelessSession {
            getTasks(startDate, endDate)
        }

        def sw3 = Stopwatch.createStarted()
        def asyncUserDetails = User.async.task {
            getUserDetails(labelFilter)
        }
        sw3.stop()
        log.debug("UserReport user details took ${sw3.toString()}")
    }

    /**
     * Retrieves transcription and validation counts for all users.
     * @return a Map containing the results of a transcription count query and a validation count query.
     */
    private def getTaskCounts() {
        def sw1 = Stopwatch.createStarted()
        def vs = (Task.withCriteria {
            projections {
                groupProperty('fullyValidatedBy')
                count('id')
            }
        }).collectEntries { [(it[0]): it[1]] }

        def ts = (Transcription.withCriteria {
            projections {
                groupProperty('fullyTranscribedBy')
                count('id')
            }
        }).collectEntries { [(it[0]): it[1]] }
        sw1.stop()

        log.debug("User counts took ${sw1.toString()}")
        [vs: vs, ts: ts]
    }

    private def getTranscribeTimes(Date startDate, Date endDate) {
        def transcribeTimes = (Transcription.withCriteria {
            and {
                isNotNull ('dateFullyTranscribed')
                ge ('dateFullyTranscribed', startDate)
                le ('dateFullyTranscribed', endDate)
            }
            projections {
                groupProperty('fullyTranscribedBy')
                sum('timeToTranscribe')
            }
        }).collectEntries { [(it[0]): it[1]] }

        transcribeTimes
    }

    /**
     *
     * @param startDate
     * @param endDate
     * @return
     */
    private def getTasks(Date startDate, Date endDate) {
        def sw1 = Stopwatch.createStarted()

        def taskList = Transcription.withCriteria {
            and {
                isNotNull ('dateFullyTranscribed')
                ge ('dateFullyTranscribed', startDate)
                le ('dateFullyTranscribed', endDate)
            }
        }
        sw1.stop()
        log.debug("User counts took ${sw1.toString()}")

        taskList
    }

    /**
     *
     * @param labelFilter
     * @return
     */
    private def getUserDetails(Label labelFilter = null) {
        def users
        if (labelFilter) {
            Set<Label> labelSet = [labelFilter]
            users = User.findAllByLabels(labelSet)
        } else {
            users = User.list()
        }
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
}
