package au.org.ala.volunteer

import au.com.bytecode.opencsv.CSVWriter
import grails.converters.JSON

class StatsController {

    static int defaultDayDiff = 7;
    static dateFormats = ['yyyy-MM-dd', "yyyy-MM-dd'T'hh:mm:ss.SSSXXX", "dd/MM/yyyy"]

    def statsService
    def settingsService
    def leaderBoardService

    def index() {}

    def volunteerStats() {
        def fromDate = params?.date('startDate', dateFormats) ?: new Date() - defaultDayDiff
        def toDate = params?.date('endDate', dateFormats) ?: new Date()
        def userList = statsService.getNewUser(fromDate, toDate)
        def result = [newVolunteers: userList[0][0], totalVolunteers: userList[0][1]]
        render result as JSON
    }

    def activeTranscribers() {
        def reportType =  StatsType.activeTranscribers;
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionsByVolunteerAndProject() {
        def reportType =  StatsType.transcriptionsByVolunteerAndProject
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionsByDay() {
        def reportType =  StatsType.transcriptionsByDay
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def validationsByDay() {
        def reportType =  StatsType.validationsByDay
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def hourlyContributions() {
        def reportType =  StatsType.hourlyContributions
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def historicalHonourBoard() {
        def reportType =  StatsType.historicalHonourBoard
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionsByInstitution() {
        def reportType =  StatsType.transcriptionsByInstitution
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionsByInstitutionByMonth() {
        def reportType = StatsType.transcriptionsByInstitutionByMonth
        def result = prepareJsonData(reportType)
        render result as JSON
    }

    def validationsByInstitution() {
        def reportType =  StatsType.validationsByInstitution
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def transcriptionTimeByProjectType() {
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

    private def getStatData (StatsType reportType) {
        def fromDate = params?.date('startDate', dateFormats) ?: new Date() - defaultDayDiff
        def toDate = (params?.date('endDate', dateFormats) ?: new Date()) + 1

        def header = []
        def statsData = []
        switch (reportType) {
            case StatsType.activeTranscribers.name():
                statsData = statsService.getActiveTasks(fromDate, toDate)

                header = [[ id: "activetranscribers",   label: message(code: 'stats.active_transcribers'), type: "string" ],
                          [ id: "transcriptioncount",   label: message(code: 'stats.transcriptions'), type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.transcriptionsByVolunteerAndProject.name():
                statsData = statsService.getTasksGroupByVolunteerAndProject(fromDate, toDate)

                header = [ [ id: "transcribers",   label: message(code: 'stats.transcribers'), type: "string" ],
                                [ id: "project",   label: message(code: 'stats.project'), type: "string" ],
                                [ id: "task_count",   label: message(code: 'stats.transcriptions'), type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.transcriptionsByDay.name():
                 statsData = statsService.getTranscriptionsByDay(fromDate, toDate)

                header = [[ id: "date",   label: message(code: 'stats.date'), type: "string" ],
                               [ id: "tasks_count",   label: message(code: 'stats.number_of_transcriptions'), type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.validationsByDay.name():
                statsData = statsService.getValidationsByDay(fromDate, toDate)

                header = [[ id: "date",   label: message(code: 'stats.date'), type: "string" ],
                               [ id: "tasks_count",   label: message(code: 'stats.number_of_validations'), type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.hourlyContributions.name():
                statsData = statsService.getHourlyContributions(fromDate, toDate)

                header = [[ id: "hour",   label: message(code: 'stats.hour'), type: "string" ],
                               [ id: "contribution",   label: message(code: 'stats.contributions'), type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.historicalHonourBoard.name():
                def ineligibleUsers = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers)

                def maxRows = 20

                def scoreList = leaderBoardService.getTopNForPeriod(fromDate, toDate, maxRows, null, ineligibleUsers)

                scoreList.each { kvp ->
                    statsData << [kvp.get("name"), kvp.get("score")]
                }

                header = [[ id: "name",   label: message(code: 'stats.name'), type: "string" ],
                               [ id: "score",   label: message(code: 'stats.score'), type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.transcriptionsByInstitution.name():
                statsData = statsService.getTranscriptionsByInstitution ();

                header = [[ id: "institution",   label: message(code: 'stats.institution'), type: "string" ],
                               [ id: "tasks_count",   label: message(code: 'stats.number_of_transcriptions'), type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.validationsByInstitution.name():
                statsData = statsService.getValidationsByInstitution ();

                header = [[ id: "institution",   label: message(code: 'stats.institution'), type: "string" ],
                               [ id: "tasks_count",   label: message(code: 'stats.number_of_validations'), type: "number" ]]

                return [header: header, statsData: statsData];
            case StatsType.transcriptionsByInstitutionByMonth.name():
                return statsService.getTranscriptionsByInstitutionByMonth()
            case StatsType.transcriptionTimeByProjectType:
                statsData = statsService.getTranscriptionTimeByProjectType(fromDate, toDate)
                header =  [
                        [ id: 'label', label: message(code: 'stats.project_type'), type: 'string'],
                        [ id: 'avg', label: message(code: 'stats.average_transcription_time'), type: 'number' ]
                ]
                return [header: header, statsData: statsData]
            default:
                log.warn("Unknown report type: $reportType")
                return [header: [], statsData: []];
        }

    }

    def exportCSVReport () {

        def reportType = (params?.reportType != null)? params?.reportType : "fileName"

        response.setHeader("Content-Disposition", "attachment;filename="+ reportType + ".csv");
        response.setContentType("text/csv;charset=utf-8");
        OutputStream fout = response.getOutputStream();
        OutputStream bos = new BufferedOutputStream(fout);
        OutputStreamWriter outputwriter = new OutputStreamWriter(bos);

        CSVWriter writer = new CSVWriter(outputwriter);

        def result = getStatData(reportType);

        if (result.get('header').size() > 0) {
            def header = [result.get('header')[0].get('label'), result.get('header')[1].get('label')]

            def array = result.get('statsData')

            // write header line (field names)
            writer.writeNext(header as String[])

            // write all the values
            array.each({
                i -> writer.writeNext(i as String[])
            })
        }

        writer.close()
    }

}
