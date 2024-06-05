package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.gorm.transactions.Transactional
import groovy.time.TimeCategory
import groovy.util.logging.Slf4j

import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.ZoneId

import static grails.async.Promises.waitAll

@Slf4j
@Transactional
class ReportRequestService {

    def grailsApplication
    def taskService
    def authService
    def settingsService
    def projectService
    def institutionService
    def userService

    static final String FILE_DIR_HOME = "reports"
    static final String NO_DATA = "nodata"

    static final String REPORT_NAME_USER = "user"
    static final String REPORT_NAME_PROJECT_SUMMARY = "project-summary"

    /**
     * Returns the report directory name. See setting <code>images.home</code>
     * @return the report directory name.
     */
    String getReportDirectory() {
        return grailsApplication.config.getProperty('images.home', String) + "/" + FILE_DIR_HOME
    }

    /**
     * Returns the reports filename. Generated from the reports name, ID and file extension (Defaults to csv).
     * @param reportRequest the report request
     * @param fileExtension the file extension, defaults to 'csv'.
     * @return the generated filename.
     */
    String getReportFilename(ReportRequest reportRequest, String fileExtension = 'csv') {
        return "${reportRequest.reportName}-${reportRequest.id}.${fileExtension}"
    }

    /**
     * Returns the filepath for the report file.
     * @param name the name of the file.
     * @return the filepath.
     */
    String createFilePath(String name) {
        return reportDirectory + "/" + name
    }

    private final Closure taggedUserReportColumnsDef = {
        'user_id' { it[0] }
        'display_name' { it[1] }
        'email' { it[2] }
        'hours_transcribed' { it[3] }
        'task_institution' { it[4] }
        'task_expedition' { it[5] }
        'task_id' { it[6] }
        'date_transcribed' { it[7] }
    }

    private final Closure allUserReportColumnsDef = {
        'user_id' { it[0] }
        'email' { it[1] }
        'display_name' { it[2] }
        'organisation' { it[3] }
        'location' { it[4] }
        'transcribed_count' { it[5] }
        'validated_count' { it[6] }
        'last_activity' { it[7] ?: NO_DATA }
        'projects_count' { it[8] }
        'volunteer_since' { it[9] }
        'is_admin' { it[10] }
        'is_institution_admin' { it[11] }
        'is_ala_validator' { it[12] }
        'is_validator' { it[13] }
        'is_forum_mod' { it[14] }
    }

    private final Closure projectSummaryColumnsDef = {
        'Expedition Id' { it.project.id }
        'Expedtion Name' { it.project.featuredLabel }
        'Institution' { it.project.institution ? it.project.institution.name : it.project.featuredOwner }
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
    }

    private final Closure dateStr = { Date d ->
        def sdf = new SimpleDateFormat("yyyy-MM-dd")
        if (d) {
            return sdf.format(d)
        }
        return ""
    }

    private final Closure daysBetween = { Date d1, Date d2 ->
        if (d1 && d2) {
            return TimeCategory.minus(d2, d1).days
        }
        return ""
    }

    /**
     * Job execute method, processing pending report generation requests
     */
    @Transactional
    def processPendingReportRequests() {
        log.debug("ReportRequestService: Process Pending Report Requests")
        def dir = new File(reportDirectory)
        if (!dir.exists()) {
            dir.mkdirs()
        }

        def pendingReports = ReportRequest.findAllByDateCompletedIsNull(sort: "dateCreated", order: "asc")
        // Get the first one only.
        if (pendingReports.size() > 0) {
            def report = pendingReports?.first()
            if (report) {
                report.dateCompleted = new Date()
                report.save(flush: true, failOnError: true)

                switch(report.reportName) {
                    case REPORT_NAME_USER:
                        log.debug("Loading User report")
                        userReport(report)
                        break
                    case REPORT_NAME_PROJECT_SUMMARY:
                        log.debug("Loading Project Summary report")
                        projectSummaryReport(report)
                        break
                }
            }
        }
    }

    /**
     * Job execute method to clean up report directory.
     */
    @Transactional
    def cleanUpReports() {
        log.info("ReportRequestService: Clean up reports directory")
        def dir = new File(reportDirectory)
        if (!dir.exists()) {
            dir.mkdirs()
            return
        }

        def ageInWeeks = settingsService.getSetting(SettingDefinition.ReportCleanupAge) as Integer
        def cleanupEnabled = settingsService.getSetting(SettingDefinition.ReportCleanupEnabled) as Boolean
        final int _day = 1
        final int _week = 7 * _day

        if (cleanupEnabled) {
            LocalDate startDate = LocalDate.now().minusDays(ageInWeeks * _week)
            //LocalDate startDate = LocalDate.now().minusDays(1)
            Date date = Date.from(startDate.atStartOfDay(ZoneId.systemDefault()).toInstant())
            log.debug("Looking for reports older than ${date}")
            def oldReports = ReportRequest.findAllByDateArchivedIsNullAndDateCompletedLessThan(date)
            int count = 0
            oldReports.each { report ->
                log.debug("Deleting report file for: ${report.fileName}")
                def fileName = getReportFilename(report)
                def filePath = createFilePath(fileName)
                def csvFile = new File(filePath)

                if (csvFile.exists()) {
                    csvFile.delete()
                    count++
                }

                report.dateArchived = new Date()
                report.save(flush: true, failOnError: true)
            }
            log.info("Deleted (${count}) files.")
        } else {
            log.warn("Report cleanup has been disabled in the Advanced settings.")
        }

        log.info("Finished Clean up")
    }

    /**
     * Checks if the report file still exists on the system. Returns the filepath to the file if it exists, null if
     * it does not.
     * @param reportRequest the report being checked
     * @return the filepath if file exists or null if it doesn't
     */
    def checkReportFile(ReportRequest reportRequest) {
        log.debug("Checking report file")
        def fileName = getReportFilename(reportRequest, 'csv')
        def filePath = createFilePath(fileName)
        def csvFile = new File(filePath)
        return csvFile.exists() ? fileName : null
    }

    /**
     * Returns the web version of the file path for a report.
     * @return
     */
    def getReportUrlPrefix() {
        String serverUrl = grailsApplication.config.getProperty('server.url', String)
        String urlPrefix = grailsApplication.config.getProperty('images.urlPrefix', String)
        "${serverUrl}/${urlPrefix}reports/"
    }

    /**
     * Set up method for the file for reporting.
     * @param reportRequest the report request
     * @return the File object for writing.
     */
    private def setupFile(ReportRequest reportRequest) {
        def fileName = getReportFilename(reportRequest)
        def filePath = createFilePath(fileName)
        def csvFile = new File(filePath)

        if (csvFile.exists()) {
            // Stop, another process may be writing to the file, so don't continue.
            log.warn("Picked up an existing file for this report.")
            csvFile.delete()
        }

        csvFile
    }

    /**
     * Generates a user report for a given set of parameters.
     * @param reportRequest the report request to generate
     */
    def userReport(ReportRequest reportRequest) {
        log.debug("User report running...")
        def csvFile = setupFile(reportRequest)

//        def fileName = getReportFilename(reportRequest)
//        def filePath = createFilePath(fileName)
//        def csvFile = new File(filePath)
//
//        if (csvFile.exists()) {
//            // Stop, another process may be writing to the file, so don't continue.
//            log.warn("Picked up an existing file for this report.")
//            csvFile.delete()
//        }

        // Report Parameters
        def params = reportRequest.reportParams
        def startDate = new SimpleDateFormat(DateConstants.DATE_FORMAT_SHORT).parse(params.get('dateStart') as String)
        def endDate = new SimpleDateFormat(DateConstants.DATE_FORMAT_SHORT).parse(params.get('dateEnd') as String)
        use (TimeCategory) {
            endDate = endDate + 23.hour + 59.minute + 59.second
        }
        def labelFilter = params.labelFilter != "null" ? Label.findById(params.labelFilter as Long) : null
        log.debug("Params: startDate: ${startDate}, endDate: ${endDate}, labelFilter: ${labelFilter}")

        FileWriter fileWriter = new FileWriter(csvFile)
        def writer = new PrintWriter(fileWriter)
        def csvWriter
        def report = []

        if (!labelFilter) {
            csvWriter = new CSVHeadingsWriter(writer, allUserReportColumnsDef)
            csvWriter.writeHeadings()

            // Old user report/All users
            def asyncCounts = Task.async.withStatelessSession {
                getTaskCounts()
            }

            def asyncLastActivities = ViewedTask.async.withStatelessSession {
                def sw2 = Stopwatch.createStarted()
                def lastActivities = taskService.getUserActivity()
                sw2.stop()
                log.debug("UserReport viewedTasks took ${sw2.toString()}")
                lastActivities
            }

            def asyncProjectCounts = Transcription.async.withStatelessSession {
                def sw4 = Stopwatch.createStarted()
                def projectCounts = taskService.getProjectTranscriptionCounts()
                sw4.stop()
                log.debug("UserReport projectCounts took ${sw4.toString()}")
                projectCounts
            }

            def sw3 = Stopwatch.createStarted()
            def asyncUserDetails = User.async.task {
                getUserDetails(labelFilter)
            }
            sw3.stop()
            log.debug("UserReport user details took ${sw3.toString()}")

            def asyncResults = waitAll(asyncCounts, asyncLastActivities, asyncProjectCounts, asyncUserDetails)

            // transform raw results into map(id -> count)
            def validateds = asyncResults[0].vs
            def transcribeds = asyncResults[0].ts

            def lastActivities = asyncResults[1]
            def projectCounts = asyncResults[2]

            def users = asyncResults[3].users as List<User>
            def serviceResults = asyncResults[3].results

            final realAdminRole = 'ROLE_ADMIN'
            final adminRole = CASRoles.ROLE_ADMIN
            final validatorRole = CASRoles.ROLE_VALIDATOR

            def sw5 = Stopwatch.createStarted()
            for (User user: users) {
                def id = user.userId
                def transcribedCount = transcribeds[id] ?: 0
                def validatedCount = validateds[id] ?: 0
                def lastActivity = lastActivities[id]
                def projectCount = projectCounts[id]?: 0

                def serviceResult = serviceResults?.users?.get(id)
                def location = (serviceResult?.city && serviceResult?.state) ? "${serviceResult?.city}, ${serviceResult?.state}" : (serviceResult?.city ?: (serviceResult?.state ?: ''))

                //def userRoles = user.userRoles
                def userRoles = UserRole.findAllByUser(user)
                def roleObjs = userRoles*.role
                def roles = (roleObjs*.name + serviceResult?.roles).toSet()
                def isAdmin = !roles.intersect([realAdminRole, adminRole]).isEmpty()
                def isAlaValidator = !roles.intersect([validatorRole]).isEmpty()
                def isValidator = !roles.intersect([BVPRole.VALIDATOR]).isEmpty()
                def isForumModerator = !roles.intersect([BVPRole.FORUM_MODERATOR]).isEmpty()
                def isInstitutionAdmin = !roles.intersect([BVPRole.INSTITUTION_ADMIN]).isEmpty()

                report.add([serviceResult?.userId ?: id,
                            serviceResult?.userName ?: user.email,
                            serviceResult?.displayName ?: user.displayName,
                            serviceResult?.organisation ?: user.organisation ?: '',
                            location,
                            transcribedCount,
                            validatedCount,
                            lastActivity,
                            projectCount,
                            user.created,
                            isAdmin,
                            isInstitutionAdmin,
                            isAlaValidator,
                            isValidator,
                            isForumModerator])
            }
            sw5.stop()
            log.debug("UserReport generate report took ${sw5}")

            sw5.reset().start()
            // Sort by the transcribed count
            report.sort({ row1, row2 -> row2[5] - row1[5]})
            sw5.stop()
            log.debug("UserReport sort took ${sw5.toString()}")

        } else {

            csvWriter = new CSVHeadingsWriter(writer, taggedUserReportColumnsDef)
            csvWriter.writeHeadings()

            def asyncTranscribeTimes = Transcription.async.withStatelessSession {
                getTranscribeTimes(startDate, endDate)
            }

            def asyncTasks = Transcription.async.withStatelessSession {
                getTranscriptions(startDate, endDate)
            }

            def sw3 = Stopwatch.createStarted()
            def asyncUserDetails = User.async.task {
                getUserDetails(labelFilter)
            }
            sw3.stop()
            log.debug("UserReport user details took ${sw3.toString()}")

            def asyncResults = waitAll(asyncTranscribeTimes, asyncTasks, asyncUserDetails)
            def transcribeTimes = asyncResults[0]
            def transcriptionList = asyncResults[1] as List<Transcription>
            def users = asyncResults[2].users as List<User>
            def serviceResults = asyncResults[2].results

            def reportUsers = []

            def sw5 = Stopwatch.createStarted()
            for (User user : users) {
                def id = user.userId
                def transcribeTime = transcribeTimes ? (transcribeTimes[id] ?: 0) : 0
                transcribeTime = (transcribeTime / 60 / 60)
                DecimalFormat df = new DecimalFormat("#.00")
                transcribeTime = df.format(transcribeTime)
                def serviceResult = serviceResults?.users?.get(id)
                def userTranscriptionList = transcriptionList.findAll { t ->
                    t.fullyTranscribedBy == id
                }

                reportUsers.add([
                        id               : serviceResult?.userId ?: id,
                        displayName      : serviceResult?.displayName ?: user.displayName,
                        email            : serviceResult?.userName ?: user.email,
                        transcribeTime   : transcribeTime,
                        transcriptionList: userTranscriptionList
                ])
            }

            log.debug("Report Users: ${reportUsers}")
            reportUsers.each { user ->

                log.debug("${user}")
                def userInfo = []
                userInfo.addAll([user['id'],
                                 user['displayName'],
                                 user['email'],
                                 user['transcribeTime']])

                if (user.transcriptionList.size() > 0) {
                    user.transcriptionList.each { Transcription tx ->
                        def row = []
                        row.addAll(userInfo)
                        def txGet = Transcription.get(tx.id)
                        def project = txGet.project
                        def institution = project.institution
                        def task = txGet.task
                        row.addAll([institution.name,
                                    project.name,
                                    task.id,
                                    txGet.dateFullyTranscribed])
                        report.add(row)
                    }
                } else {
                    def row = []
                    row.addAll(userInfo)
                    row.addAll([NO_DATA, NO_DATA, NO_DATA, NO_DATA])
                    report.add(row)
                }
            }

            sw5.stop()
            log.debug("UserReport generate report took ${sw5}")
        }

        log.debug("Writing report to file:")
        for (def row : report) {
            log.debug("${row}")
            csvWriter << row
        }

        writer.close()
        log.debug("User report completed.")
    }

    /**
     * Project Summary report (migrated from AdminController)
     * @param reportRequest the report request.
     */
    def projectSummaryReport(ReportRequest reportRequest) {
        log.debug("Project Summary report running...")

        def csvFile = setupFile(reportRequest)
        def projects
        def user = reportRequest.requestUser
        def userLevel = UserService.USER_LEVEL_USER
        if (reportRequest.reportParams != null) {
            userLevel = reportRequest.reportParams.get("userLevel")
            log.debug("userLevel: ${userLevel}")
        }

        def institutionList = []
        if (userLevel == UserService.USER_LEVEL_INSTITUTION) {
            institutionList.addAll(userService.getAdminInstitutionList(user))
            projects = institutionService.listProjectsForInstititutionList(institutionList)
        } else {
            projects = Project.list([sort:'id'])
        }

        def dates = taskService.getProjectDates()

        def projectSummaries = projectService.getAllProjectSummaries(institutionList, true)
        def summaryMap = projectSummaries.projectRenderList.collectEntries { [(it.project.id) : it ] }

        def data = projects.collect { project ->
            def summary = summaryMap[project.id]
            [project: project, summary: summary, dates: dates[project.id]]
        }

        FileWriter fileWriter = new FileWriter(csvFile)
        def writer = new PrintWriter(fileWriter)
        def csvWriter = new CSVHeadingsWriter(writer, projectSummaryColumnsDef)

        for (def row : data) {
            log.debug("row: ${row}")
            csvWriter << row
        }

        writer.close()
        log.debug("Project Summary report completed.")
    }

    /**
     * Dynamic query for selecting reports based on provided status or report filters.
     * @param statusFilter the status filter if any. Accepted values: all, active and archived.
     * @param reportFilter the report filter if any
     * @param params Map of query parameters such as <code>sortColumn</code>, <code>sortOrder</code>, <code>max</code>,
     * and <code>offset</code>.
     * @return Map: {@code[reportList: List<ReportRequest>, reportCount: Integer]}
     */
    def getReportsForAdmin(def params) {
        def fetchReports = {
            if (params.statusFilter) {
                switch (params.statusFilter) {
                    case 'active':
                        and {
                            isNotNull('dateCompleted')
                            isNull('dateArchived')
                        }
                        break
                    case 'archived':
                        isNotNull('dateArchived')
                        break
                }
            }
            if (params.reportFilter) {
                eq('reportName', params.reportFilter)
            }
            if (params.userFilter) {
                eq('requestUser', params.userFilter)
            }
        }

        log.debug("params: ${params}")

        def results = ReportRequest.createCriteria().list() {
            fetchReports.delegate = delegate
            fetchReports()
            if (params.max) {
                maxResults(params.get('max') as int)
            }
            if (params.offset) {
                firstResult(params.get('offset') as int)
            }
            if (params.sortColumn) {
                order(params.sortColumn as String, params.sortOrder as String)
            }
        } as List<ReportRequest>

        int resultCount = ReportRequest.createCriteria().get() {
            fetchReports.delegate = delegate
            fetchReports()
            projections {
                count('id')
            }
        }

        [reportList: results, count: resultCount]
    }

    /**
     * Returns a list of distinct report names from the {@link ReportRequest} table.
     * @return a {@code List<String>} of report names.
     */
    def getReportNames() {
        def reportNames = ReportRequest.createCriteria().list() {
            projections {
                distinct('reportName')
            }
        } as List<String>

        reportNames
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

    /**
     * Retrieves transcribe times for users within a given date range.
     * @param startDate the starting date of the range
     * @param endDate the end date of the range
     * @return a list of maps containing the user ID (from Transcription.fullyTranscribedBy) and the total transcibing
     * time in seconds.
     */
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

        log.debug("Times: ${transcribeTimes}")
        transcribeTimes
    }

    /**
     * Returns a list of transcriptions between a given date range.
     * @param startDate the starting date of the range
     * @param endDate the end date of the range
     * @return a list of transcriptions.
     */
    private def getTranscriptions(Date startDate, Date endDate) {
        def sw1 = Stopwatch.createStarted()

        def transcriptionList = Transcription.withCriteria {
            and {
                isNotNull ('dateFullyTranscribed')
                ge ('dateFullyTranscribed', startDate)
                le ('dateFullyTranscribed', endDate)
            }
        }
        sw1.stop()
        log.debug("User counts took ${sw1.toString()}")

        transcriptionList
    }

    /**
     * Returns a list of users and user details from the ALA auth service.
     * @param labelFilter optional label filter
     * @return A list of user objects and corresponding user info from the auth service.
     */
    private def getUserDetails(Label labelFilter = null) {
        def users
        if (labelFilter) {
            users = labelFilter.userList.toList()
        } else {
            users = User.list()
        }
        def serviceResults = [:]
        try {
            serviceResults = authService.getUserDetailsById(users*.userId, true)
        } catch (Exception e) {
            log.warn("couldn't get user details from web service", e)
        }

        [users: users, results: serviceResults]
    }
}
