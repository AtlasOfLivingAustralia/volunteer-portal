package au.org.ala.volunteer

import grails.converters.JSON
import java.text.SimpleDateFormat

class StatsController {

    static int defaultDayDiff = 7;
    static SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

    def statsService
    def settingsService
    def leaderBoardService

    def index = {}

    def volunteerStats() {

        def fromDate = (params?.startDate == null)? sdf.format(new Date() - defaultDayDiff) : params.startDate
        def toDate = (params?.endDate == null)? sdf.format(new Date()) : params.endDate

        def userList = statsService.getNewUser(fromDate, toDate)

        def result = [newVolunteers: userList[0][0], totalVolunteers: userList[0][1]]

        render result as JSON
    }

    def activeTranscribers() {

        def fromDate = (params?.startDate == null)? sdf.format(new Date() - defaultDayDiff) : params.startDate
        def toDate = (params?.endDate == null)? sdf.format(new Date()) : params.endDate

        def transcribersTask = statsService.getActiveTasks(fromDate, toDate)

        def headers = [[ id: "activetranscribers",   label: "Active Transcribers", type: "string" ],
                       [ id: "transcriptioncount",   label: "Transcriptions", type: "number" ]]

        def values = transcribersTask.collect { pair -> [ c: pair.collect { item -> [ v: item ] } ] }

        def result = [cols: headers, rows: values]

        render result as JSON
    }

    def transcriptionsByVolunteerAndProject() {

        def fromDate = (params?.startDate == null)? sdf.format(new Date() - defaultDayDiff) : params.startDate
        def toDate = (params?.endDate == null)? sdf.format(new Date()) : params.endDate

        def transcriptions = statsService.getTasksGroupByVolunteerAndProject (fromDate, toDate);

        def headers = [ [ id: "transcribers",   label: "Transcribers", type: "string" ],
                        [ id: "project",   label: "Project", type: "string" ],
                        [ id: "task_count",   label: "Transcriptions", type: "number" ]]
        def values = transcriptions.collect { arr -> [ c: arr.collect { item -> [ v: item ] } ] }

        def result = [cols: headers, rows: values]

        render result as JSON
    }

    def transcriptionsByDay() {

        def fromDate = (params?.startDate == null)? sdf.format(new Date() - defaultDayDiff) : params.startDate
        def toDate = (params?.endDate == null)? sdf.format(new Date()) : params.endDate

        def transcriptions = statsService.getTranscriptionsByDay (fromDate, toDate);

        def headers = [[ id: "date",   label: "Date", type: "string" ],
                       [ id: "tasks_count",   label: "Number of Transcriptions", type: "number" ]]
        def values = transcriptions.collect { arr -> [ c: arr.collect { item -> [ v: item ] } ] }

        def result = [cols: headers, rows: values]

        render result as JSON
    }

    def validationsByDay() {

        def fromDate = (params?.startDate == null)? sdf.format(new Date() - defaultDayDiff) : params.startDate
        def toDate = (params?.endDate == null)? sdf.format(new Date()) : params.endDate

        def validatedTasks = statsService.getValidationsByDay (fromDate, toDate);

        def headers = [[ id: "date",   label: "Date", type: "string" ],
                       [ id: "tasks_count",   label: "Number of Validations", type: "number" ]]
        def values = validatedTasks.collect { arr -> [ c: arr.collect { item -> [ v: item ] } ] }

        def result = [cols: headers, rows: values]

        render result as JSON
    }

    def hourlyContributions() {

        def fromDate = (params?.startDate == null)? sdf.format(new Date() - defaultDayDiff) : params.startDate
        def toDate = (params?.endDate == null)? sdf.format(new Date()) : params.endDate

        def validatedTasks = statsService.getHourlyContributions (fromDate, toDate);

        def headers = [[ id: "hour",   label: "Hour", type: "string" ],
                       [ id: "contribution",   label: "Contributions", type: "number" ]]
        def values = validatedTasks.collect { arr -> [ c: arr.collect { item -> [ v: item ] } ] }

        def result = [cols: headers, rows: values]

        render result as JSON
    }

    def historicalHonourBoard() {

        def fromDate = (params?.startDate == null)? sdf.format(new Date() - defaultDayDiff) : params.startDate
        def toDate = (params?.endDate == null)? sdf.format(new Date()) : params.endDate

        def ineligibleUsers = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers)

        def maxRows = 20

        def scoreList = leaderBoardService.getTopNForPeriod(sdf.parse(fromDate), sdf.parse(toDate), maxRows, null, ineligibleUsers)

        def list = []
        scoreList.each { kvp ->
            list << [kvp.get("name"), kvp.get("score")]
        }

        def headers = [[ id: "name",   label: "Name", type: "string" ],
                       [ id: "score",   label: "Score", type: "number" ]]
        def values = list.collect { arr -> [ c: arr.collect { item -> [ v: item ] } ] }

        def result = [cols: headers, rows: values]

        render result as JSON
    }

    def transcriptionsByInstitution() {

        def transcriptions = statsService.getTranscriptionsByInstitution ();

        def headers = [[ id: "institution",   label: "Institution", type: "string" ],
                       [ id: "tasks_count",   label: "Number of Transcriptions", type: "number" ]]
        def values = transcriptions.collect { arr -> [ c: arr.collect { item -> [ v: item ] } ] }

        def result = [cols: headers, rows: values]

        render result as JSON
    }

    def validationsByInstitution() {

        def validatedTasks = statsService.getValidationsByInstitution ();

        def headers = [[ id: "institution",   label: "Institution", type: "string" ],
                       [ id: "tasks_count",   label: "Number of Validations", type: "number" ]]
        def values = validatedTasks.collect { arr -> [ c: arr.collect { item -> [ v: item ] } ] }

        def result = [cols: headers, rows: values]

        render result as JSON
    }

}
