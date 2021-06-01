package au.org.ala.volunteer

import au.com.bytecode.opencsv.CSVWriter
import com.google.common.base.Charsets
import grails.converters.JSON

class StatsController {

    static int defaultDayDiff = 7
    static dateFormats = ['yyyy-MM-dd', "yyyy-MM-dd'T'hh:mm:ss.SSSXXX", "dd/MM/yyyy"]

    def statsService
    def settingsService
    def leaderBoardService
    def userService

    def index() {
        if (!userService.isInstitutionAdmin()) {
            redirect(uri: "/")
            return
        }

        def institutionList
        if (userService.isSiteAdmin()) {
            institutionList = Institution.list([sort: 'name', order: 'asc'])
        } else {
            institutionList = userService.getAdminInstitutionList()
        }

        render(view: 'index', model: [institutionList: institutionList])
    }

    def volunteerStats() {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }
        def fromDate = params?.date('startDate', dateFormats) ?: new Date() - defaultDayDiff
        def toDate = params?.date('endDate', dateFormats) ?: new Date()
        Institution institution = Institution.get(params.long('institutionId'))

        def result = statsService.getNewUser(fromDate, toDate, institution)
        render result as JSON
    }

    def activeTranscribers() {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }
        def reportType =  StatsType.activeTranscribers
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionsByVolunteerAndProject() {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }
        def reportType =  StatsType.transcriptionsByVolunteerAndProject
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionsByDay() {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }
        def reportType =  StatsType.transcriptionsByDay
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def validationsByDay() {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }
        def reportType =  StatsType.validationsByDay
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def hourlyContributions() {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }
        def reportType =  StatsType.hourlyContributions
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def historicalHonourBoard() {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }
        def reportType =  StatsType.historicalHonourBoard
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionsByInstitution() {
        if (!userService.isAdmin()) {
            render status: 403
            return
        }
        def reportType =  StatsType.transcriptionsByInstitution
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionsByInstitutionByMonth() {
        if (!userService.isAdmin()) {
            render status: 403
            return
        }
        def reportType = StatsType.transcriptionsByInstitutionByMonth
        def result = prepareJsonData(reportType)
        render result as JSON
    }

    def validationsByInstitution() {
        if (!userService.isAdmin()) {
            render status: 403
            return
        }
        def reportType =  StatsType.validationsByInstitution
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionTimeByProjectType() {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }
        def reportType = StatsType.transcriptionTimeByProjectType
        def result = prepareJsonData(reportType)
        render result as JSON
    }

    private def prepareJsonData (StatsType reportType) {
        def statResult = getStatData(reportType)
        def header = statResult.get('header')
        def array = statResult.get('statsData')
        def values = array.collect { arr -> [ c: arr.collect { item -> [ v: item ] } ] }
        def result = [cols: header, rows: values]
        return result
    }

    private def getStatData(StatsType reportType) {
        def fromDate = params?.date('startDate', dateFormats) ?: new Date() - defaultDayDiff
        def toDate = (params?.date('endDate', dateFormats) ?: new Date()) + 1
        Institution institution = Institution.get(params?.long('institutionId'))

        def header
        def statsData = []
        switch (reportType) {
            case StatsType.activeTranscribers.name():
                statsData = statsService.getActiveTasks(fromDate, toDate, institution)

                header = [[ id: "activetranscribers",   label: "Active Transcribers", type: "string" ],
                          [ id: "transcriptioncount",   label: "Transcriptions", type: "number" ]]

                return [header: header, statsData: statsData]

            case StatsType.transcriptionsByVolunteerAndProject.name():
                statsData = statsService.getTasksGroupByVolunteerAndProject(fromDate, toDate, institution)

                header = [ [ id: "transcribers",   label: "Transcribers", type: "string" ],
                                [ id: "project",   label: "Project", type: "string" ],
                                [ id: "task_count",   label: "Transcriptions", type: "number" ]]

                return [header: header, statsData: statsData]

            case StatsType.transcriptionsByDay.name():
                 statsData = statsService.getTranscriptionsByDay(fromDate, toDate, institution)

                header = [[ id: "date",   label: "Date", type: "string" ],
                               [ id: "tasks_count",   label: "Number of Transcriptions", type: "number" ]]

                return [header: header, statsData: statsData]

            case StatsType.validationsByDay.name():
                statsData = statsService.getValidationsByDay(fromDate, toDate, institution)

                header = [[ id: "date",   label: "Date", type: "string" ],
                               [ id: "tasks_count",   label: "Number of Validations", type: "number" ]]

                return [header: header, statsData: statsData]

            case StatsType.hourlyContributions.name():
                statsData = statsService.getHourlyContributions(fromDate, toDate, institution)

                header = [[ id: "hour",   label: "Hour", type: "string" ],
                               [ id: "contribution",   label: "Contributions", type: "number" ]]

                return [header: header, statsData: statsData]

            case StatsType.historicalHonourBoard.name():
                def institutions = null
                if (!institution && (!userService.isSiteAdmin() && userService.isInstitutionAdmin())) {
                    institutions = userService.getAdminInstitutionList() as List<Institution>
                } else if (institution) {
                    institutions = [institution]
                }
                def ineligibleUsers = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers)
                def maxRows = 20
                def scoreList = leaderBoardService.getTopNForPeriod(fromDate, toDate, maxRows, institutions, ineligibleUsers)

                scoreList.each { kvp ->
                    statsData << [kvp.get("name"), kvp.get("score")]
                }

                header = [[ id: "name",   label: "Name", type: "string" ],
                               [ id: "score",   label: "Score", type: "number" ]]

                return [header: header, statsData: statsData]

            case StatsType.transcriptionsByInstitution.name():
                statsData = statsService.getTranscriptionsByInstitution ()

                header = [[ id: "institution",   label: "Institution", type: "string" ],
                               [ id: "tasks_count",   label: "Number of Transcriptions", type: "number" ]]

                return [header: header, statsData: statsData]

            case StatsType.validationsByInstitution.name():
                statsData = statsService.getValidationsByInstitution ()

                header = [[ id: "institution",   label: "Institution", type: "string" ],
                               [ id: "tasks_count",   label: "Number of Validations", type: "number" ]]

                return [header: header, statsData: statsData]
            case StatsType.transcriptionsByInstitutionByMonth.name():
                return statsService.getTranscriptionsByInstitutionByMonth()
            case StatsType.transcriptionTimeByProjectType:
                statsData = statsService.getTranscriptionTimeByProjectType(fromDate, toDate, institution)
                header =  [
                        [ id: 'label', label: 'Project Type', type: 'string'],
                        [ id: 'avg', label: 'Average Transcription Time', type: 'number' ]
                ]
                return [header: header, statsData: statsData]
            default:
                log.warn("Unknown report type: $reportType")
                return [header: [], statsData: []]
        }
    }

    def institutionStatsDownload() {
        if (!userService.isInstitutionAdmin()) {
            redirect(uri: "/")
            return
        }

        Institution institution = Institution.get(params.long('id'))
        if (!institution) {
            return
        }

        def headers = ["institution_id",
                       "institution_name",
                       "project_id",
                       "project_name",
                       "task_id",
                       "external_url",
                       "validation_status",
                       "transcriber_id",
                       "validator_id",
                       "export_comment",
                       "date_transcribed",
                       "date_validated"]
        response.setHeader("Content-Disposition", "attachment;filename=institution-task-data-${institution.id}.csv")
        response.setContentType("text/csv;charset=utf-8")
        def result = statsService.getInstitutionRawData(institution)

        try {
            new CSVWriter(new OutputStreamWriter(response.outputStream, Charsets.UTF_8)).withCloseable { CSVWriter writer ->
                // write header line (field names)
                writer.writeNext(headers as String[])

                // write all the values
                result.each({
                    i -> writer.writeNext(i as String[])
                })
            }
        } catch (Exception e) {
            log.error("Error while writing CSV data for institution task data.", e)
        }
    }

    def exportCSVReport () {
        if (!userService.isInstitutionAdmin()) {
            render status: 403
            return
        }

        log.debug("Beginning CSV report export")
        def reportType = StatsType.valueOf(params?.reportType ?: "fileName")
        def result = getStatData(reportType)

        log.info("Beginning CSV report export for ${reportType} with ${result.get('statsData')?.size()} records")
        log.info("Parameter names: ${params}")
        response.setHeader("Content-Disposition", "attachment;filename="+ reportType + ".csv")
        response.setContentType("text/csv;charset=utf-8")

        try {
            new CSVWriter(new OutputStreamWriter(response.outputStream, Charsets.UTF_8)).withCloseable { CSVWriter writer ->
                if (result.get('header').size() > 0) {
                    def header = result.get('header')*.get('label')
                    def array = result.get('statsData')

                    // write header line (field names)
                    writer.writeNext(header as String[])

                    // write all the values
                    array.each({
                        i -> writer.writeNext(i as String[])
                    })
                }
            }
            log.info("CSV report export for ${reportType} completed without error")
        } catch (Exception e) {
            log.error("Error while writing CSV data for ${reportType}", e)
        }
    }
}
