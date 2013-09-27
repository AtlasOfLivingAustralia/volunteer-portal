package au.org.ala.volunteer

import grails.converters.JSON

class LeaderBoardController {

    def leaderBoardFragment() {
        def leaderBoardSections = [
                'Day Tripper' : createLink(action:'ajaxDayTripper'),
                'Weekly Winner' : createLink(action:'ajaxWeeklyWinner'),
                'Monthly Maestro' : createLink(action:'ajaxMonthlyMaestro'),
                'BVP Legend' : createLink(action:'ajaxBVPLegend')
        ]
        [leaderBoardSections : leaderBoardSections ]
    }

    def ajaxDayTripper() {
        def today = new Date().clearTime()
        def results = getLeaderboardWinner(today, today)
        render(results as JSON)
    }

    def ajaxWeeklyWinner() {

        def today = new Date().clearTime()
        def firstDayOfWeek = (Date) today.clone()
        while (firstDayOfWeek.getAt(Calendar.DAY_OF_WEEK) != 1) {
            firstDayOfWeek--;
        }
        def results = getLeaderboardWinner(firstDayOfWeek, today)
        render(results as JSON)
    }

    def ajaxMonthlyMaestro() {
        def today = new Date().clearTime()
        def firstDayOfMonth = (Date) today.clone()
        while (firstDayOfMonth.getAt(Calendar.DAY_OF_MONTH) != 1) {
            firstDayOfMonth--;
        }
        def results = getLeaderboardWinner(firstDayOfMonth, today)
        render(results as JSON)
    }

    def ajaxBVPLegend() {

        // TODO, there has to be a better way!

        def today = new Date().clearTime()
        def start = new Date(2010 - 1900,0,0)
        def results = getLeaderboardWinner(start, today)

        render(results as JSON)
    }

    private Map getLeaderboardWinner(Date startDate, Date endDate) {
        def results = getTopNForPeriod(startDate, endDate, 5)
        if (results) {
            return results[0]
        }

        return [name:'', score:0]
    }

    private List getTopNForPeriod(Date startDate, Date endDate, int count) {

        // Get a map of users who transcribed tasks during this period, along with the count
        def scoreMap = getUserMapForPeriod(startDate, endDate, ActivityType.Transcribed)
        // Get a map of user who validated tasks during this periodn, along with the count
        def validatedMap = getUserMapForPeriod(startDate, endDate, ActivityType.Validated)

        // merge the validated map into the transcribed map, forming a total activity score for the superset of users
        validatedMap.each { kvp ->
            // if there exists a validator who is not a transcriber, set the transcription count to 0
            if (!scoreMap[kvp.key]) {
                scoreMap[kvp.key] = 0
            }
            // combine the transcribed count with the validated count for that user.
            scoreMap[kvp.key] += kvp.value
        }

        // Flatten the map into a list for easy sorting, so we can slice off the top N
        def list = []
        scoreMap.each { kvp ->
            list << [name: kvp.key, score: kvp.value]
        }

        // Sort in descending order...
        list?.sort { a, b -> b.score <=> a.score }
        // and just return the top N items
        return list.subList(0, Math.min(list.size(), count))
    }

    private Map getUserMapForPeriod(Date startDate, Date endDate, ActivityType activityType) {
        println "Getting counts of tasks ${activityType} between ${startDate} and ${endDate}"

        def c = Task.createCriteria()

        def results = c {
            ge("dateFully${activityType}", startDate)
            lt("dateFully${activityType}", endDate + 1)

            projections {
                groupProperty("fully${activityType}By")
                count("fully${activityType}By", 'count')
            }
        }

        def map = [:]
        results.each { row ->
            map[row[0]] = row[1]
        }

        return map
    }
}

enum ActivityType {
    Transcribed, Validated
}
