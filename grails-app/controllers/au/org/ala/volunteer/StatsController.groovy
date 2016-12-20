package au.org.ala.volunteer

import au.com.bytecode.opencsv.CSVWriter
import grails.converters.JSON
import java.text.SimpleDateFormat

class StatsController {

    static int defaultDayDiff = 7;
    static dateFormats = ["yyyy-MM-dd'T'hh:mm:ss.SSSXXX", "dd/MM/yyyy"]

    def statsService
    def settingsService
    def leaderBoardService

    def index = {}

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

    def validationsByInstitution() {
        def reportType =  StatsType.validationsByInstitution
        def result = prepareJsonData (reportType)
        render result as JSON
    }

    def prepareJsonData (def reportType) {
        def statResult = getStatData(reportType)
        def header = statResult.get('header')
        def array = statResult.get('statsData')
        def values = array.collect { arr -> [ c: arr.collect { item -> [ v: item ] } ] }
        def result = [cols: header, rows: values]
        return result
    }

    def getStatData (def reportType) {
        def fromDate = params?.date('startDate', dateFormats) ?: new Date() - defaultDayDiff
        def toDate = (params?.date('endDate', dateFormats) ?: new Date()) + 1

        def header = []
        def statsData = []
        switch (reportType) {
            case StatsType.activeTranscribers.name():
                statsData = statsService.getActiveTasks(fromDate, toDate)

                header = [[ id: "activetranscribers",   label: "Active Transcribers", type: "string" ],
                          [ id: "transcriptioncount",   label: "Transcriptions", type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.transcriptionsByVolunteerAndProject.name():
                statsData = statsService.getTasksGroupByVolunteerAndProject(fromDate, toDate)

                header = [ [ id: "transcribers",   label: "Transcribers", type: "string" ],
                                [ id: "project",   label: "Project", type: "string" ],
                                [ id: "task_count",   label: "Transcriptions", type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.transcriptionsByDay.name():
                 statsData = statsService.getTranscriptionsByDay(fromDate, toDate)

                header = [[ id: "date",   label: "Date", type: "string" ],
                               [ id: "tasks_count",   label: "Number of Transcriptions", type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.validationsByDay.name():
                statsData = statsService.getValidationsByDay(fromDate, toDate)

                header = [[ id: "date",   label: "Date", type: "string" ],
                               [ id: "tasks_count",   label: "Number of Validations", type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.hourlyContributions.name():
                statsData = statsService.getHourlyContributions(fromDate, toDate)

                header = [[ id: "hour",   label: "Hour", type: "string" ],
                               [ id: "contribution",   label: "Contributions", type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.historicalHonourBoard.name():
                def ineligibleUsers = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers)

                def maxRows = 20

                def scoreList = leaderBoardService.getTopNForPeriod(fromDate, toDate, maxRows, null, ineligibleUsers)

                scoreList.each { kvp ->
                    statsData << [kvp.get("name"), kvp.get("score")]
                }

                header = [[ id: "name",   label: "Name", type: "string" ],
                               [ id: "score",   label: "Score", type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.transcriptionsByInstitution.name():
                statsData = statsService.getTranscriptionsByInstitution ();

                header = [[ id: "institution",   label: "Institution", type: "string" ],
                               [ id: "tasks_count",   label: "Number of Transcriptions", type: "number" ]]

                return [header: header, statsData: statsData];

            case StatsType.validationsByInstitution.name():
                statsData = statsService.getValidationsByInstitution ();

                header = [[ id: "institution",   label: "Institution", type: "string" ],
                               [ id: "tasks_count",   label: "Number of Validations", type: "number" ]]

                return [header: header, statsData: statsData];

            default: return [header: [], statsData: []];
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
