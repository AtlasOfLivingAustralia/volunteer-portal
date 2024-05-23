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
        redirect(action: 'userReport', params: params)
    }

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
        }

        def newReport = new ReportRequest(requestUser: userService.currentUser, reportName: reportRequestService.REPORT_NAME_USER)
        newReport.dateCreated = new Date()
        newReport.reportParams = [dateStart: dateStart, dateEnd: dateEnd, labelFilter: (filterByLabel) ? filterByLabel.id : null]
        newReport.save(flush: true, failOnError: true)

        log.info("Report requiest: user report, start date: ${dateStart}, end date: ${dateEnd}, labelFilter: [${filterByLabel}]")
        redirect(action: 'userReport')
    }

    def getReports() {
        if (!userService.isAdmin()) {
            render status: SC_FORBIDDEN
            return
        }

        log.info("Report list...")
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
        log.info("Found ${reportList.size()} reports.")

        def results = []
        reportList.each { report ->
            def out = [dateCreated: report.dateCreated.format(DateConstants.DATE_TIME_FORMAT),
            requestUser: [id: report.requestUser.id, displayName: report.requestUser.displayName],
            dateCompleted: report.dateCompleted?.format(DateConstants.DATE_TIME_FORMAT),
            params: report.reportParams]
            results.add(out)
        }

        render results as JSON
    }
}
