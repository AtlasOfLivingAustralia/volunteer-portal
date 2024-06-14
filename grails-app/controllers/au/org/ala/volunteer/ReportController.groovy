package au.org.ala.volunteer

import grails.converters.JSON
import grails.gorm.transactions.Transactional
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import static javax.servlet.http.HttpServletResponse.SC_FORBIDDEN

class ReportController {

    static final String DATE_FORMAT = "dd/MM/yyyy"


    def userService
    def reportRequestService

    def index() {
        redirect(action: 'reportHistory', params: params)
    }

    /**
     *
     * @return
     */
    def userReport() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def userLabelCategory = LabelCategory.findByName('user')
        def userLabelList = Label.findAllByCategory(userLabelCategory)
        LocalDate startDate = LocalDate.now().minusDays(7)
        final DateTimeFormatter dtf = DateTimeFormatter.ofPattern(DATE_FORMAT, Locale.ENGLISH);
        String startDateStr = startDate.format(dtf);
        String endDateStr = LocalDate.now().format(DateTimeFormatter.ofPattern(DATE_FORMAT, Locale.ENGLISH))

        [userLabelList: userLabelList, defaultStartDate: startDateStr, defaultEndDate: endDateStr]
    }

    /**
     *
     * @return
     */
    @Transactional
    def requestUserReport() {
        if (!userService.isAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def dateStart = params.get('dateStart')
        def dateEnd = params.get('dateEnd')
        def labelFilter = params.long('labelFilter')
        def filterByLabel = Label.get(labelFilter)

        if (!dateStart || !dateEnd) {
            flash.message = message(code: 'default.invalid.parameter.message',
                    args: ["Start and/or End Date"]) as String
            redirect(action: 'userReport')
            return
        }

        def newReport = new ReportRequest(requestUser: userService.currentUser,
                reportName: ReportRequestService.REPORT_NAME_USER)
        newReport.dateCreated = new Date()
        newReport.reportParams = [dateStart: dateStart, dateEnd: dateEnd, labelFilter: (filterByLabel) ? filterByLabel.id : null]
        newReport.save(flush: true, failOnError: true)

        log.debug("Report requiest: user report, start date: ${dateStart}, end date: ${dateEnd}, labelFilter: [${filterByLabel}]")
        redirect(action: 'userReport')
    }

    /**
     *
     * @return
     */
    def projectSummary() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        render(view: 'projectSummary')
    }

    /**
     *
     * @return
     */
    @Transactional
    def requestProjectSummaryReport() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }

        def newReport = new ReportRequest(requestUser: userService.currentUser,
                reportName: ReportRequestService.REPORT_NAME_PROJECT_SUMMARY)
        newReport.dateCreated = new Date()
        if (userService.isSiteAdmin()) {
            newReport.reportParams = [userLevel: UserService.USER_LEVEL_ADMIN]
        } else if (userService.isInstitutionAdmin() && !userService.isSiteAdmin()) {
            newReport.reportParams = [userLevel: UserService.USER_LEVEL_INSTITUTION]
        } else {
            newReport.reportParams = [userLevel: UserService.USER_LEVEL_USER]
        }
        newReport.save(flush: true, failOnError: true)

        log.debug("Report requiest: project summary report")
        redirect(action: 'projectSummary')
    }

    /**
     *
     * @return
     */
    def reportHistory() {
        if (!userService.isInstitutionAdmin()) {
            render(view: '/notPermitted')
            return
        }
        log.debug("page params: ${params}")
        def sortColumn = params.sort as String ?: 'dateCompleted'
        def sortOrder = params.order as String ?: 'desc'
        def max = Math.min(params.max ? params.int('max') : 25, 100)
        def offset = (params.offset ? params.int('offset') : 0)

        log.debug("Sort: ${sortColumn}, order: ${sortOrder}")

        def queryParams = [sortColumn: sortColumn,
                           sortOrder: sortOrder,
                           max: max,
                           offset: offset,
                           statusFilter: !userService.isAdmin() ? null : params.statusFilter,
                           reportFilter: params.reportFilter]
        if (!userService.isAdmin()) {
            queryParams.userFilter = userService.currentUser
        }

        // If not a site admin, get only their reports and only the ones that still have the file on disk.
        def reportResults = reportRequestService.getReportsForAdmin(queryParams)
        def reportList = reportResults.reportList
        def reportCount = reportResults.count

        def reportListComplete = []
        reportList.each { report ->
            def row = [:]
            def filename = reportRequestService.checkReportFile(report)
            def filepath = (filename) ? reportRequestService.getReportUrlPrefix() + filename : ""
            row.report = report
            row.filepath = filepath
            reportListComplete.add(row)
        }

        //def reportFilterList = reportList.collect{ it.reportName }.unique()
        def reportFilterList = reportRequestService.getReportNames()

        [reportList: reportListComplete, reportCount: reportCount, reportFilterList: reportFilterList]
    }

    /**
     *
     * @return
     */
    def getReports() {
        if (!userService.isInstitutionAdmin()) {
            render status: SC_FORBIDDEN
            return
        }

        log.debug("Report list...")
        def reportName = params.get('reportName') as String
        def user = userService.getCurrentUser()
        def reportList

        if (reportName == "all") {
            reportList = ReportRequest.listOrderByDateCreated(order: 'desc')
        } else if (reportName) {
            reportList = ReportRequest.findAllByRequestUserAndReportName(user, reportName)
        } else {
            reportList = []
        }
        log.debug("Found ${reportList.size()} reports.")

        def results = []
        reportList.each { report ->
            def filename = reportRequestService.checkReportFile(report)

            def out = [dateCreated  : report.dateCreated.format(DateConstants.DATE_TIME_FORMAT),
                       requestUser  : [id: report.requestUser.id, displayName: report.requestUser.displayName],
                       dateCompleted: report.dateCompleted?.format(DateConstants.DATE_TIME_FORMAT),
                       dateArchived : report.dateArchived?.format(DateConstants.DATE_TIME_FORMAT),
                       params       : report.reportParams,
                       filepath     : (filename) ? reportRequestService.getReportUrlPrefix() + filename : ""]
            results.add(out)
        }

        render results as JSON
    }
}
