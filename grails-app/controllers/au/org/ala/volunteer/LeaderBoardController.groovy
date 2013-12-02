package au.org.ala.volunteer

import grails.converters.JSON

class LeaderBoardController {

    def userService

    def leaderBoardFragment() {
        def leaderBoardSections = [
            [category: LeaderBoardCategory.daily, label:'Day Tripper', link: createLink(action:'ajaxLeaderBoardCategoryWinner', params:[category:LeaderBoardCategory.daily])],
            [category: LeaderBoardCategory.weekly, label:'Weekly Winner', link: createLink(action:'ajaxLeaderBoardCategoryWinner', params:[category:LeaderBoardCategory.weekly])],
            [category: LeaderBoardCategory.monthly, label:'Monthly Maestro', link:createLink(action:'ajaxLeaderBoardCategoryWinner', params:[category:LeaderBoardCategory.monthly])],
            [category: LeaderBoardCategory.alltime, label:'BVP Legend', link: createLink(action:'ajaxBVPLegend')]
        ]
        [leaderBoardSections : leaderBoardSections ]
    }

    def ajaxLeaderBoardCategoryWinner() {
        def category = params.category as LeaderBoardCategory
        def today = new Date().clearTime()

        def result = [name: '', score: 0]
        switch (category) {
            case LeaderBoardCategory.daily:
                result = getLeaderboardWinner(today, today)
                break;
            case LeaderBoardCategory.weekly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_WEEK) != 1) {
                    startDate--;
                }
                result = getLeaderboardWinner(startDate, today)
                break;
            case LeaderBoardCategory.monthly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_MONTH) != 1) {
                    startDate--;
                }
                result = getLeaderboardWinner(startDate, today)
                break;
            case LeaderBoardCategory.alltime:
                def userScores = userService.getUserCounts();
                if (userScores) {
                    result = [name: userScores[0][0], score: userScores[0][1]]
                }
                break;
            default:
                break;
        }

        render(result as JSON)
    }

    def topList() {
        def category = params.category as LeaderBoardCategory
        def today = new Date().clearTime()
        def headingPrefix = "Top 20 volunteers for "
        def heading =  headingPrefix + category?.toString()?.toTitleCase()
        def maxRows = 20
        def results = []
        switch (category) {
            case LeaderBoardCategory.daily:
                heading = "${headingPrefix} ${today.format('d MMMM YYYY')}"
                results = getTopNForPeriod(today, today, maxRows)
                break;
            case LeaderBoardCategory.weekly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_WEEK) != 1) {
                    startDate--;
                }
                heading = "${headingPrefix} week starting ${startDate.format('dd MMMM YYY')}"
                results = getTopNForPeriod(startDate, today, maxRows)
                break;
            case LeaderBoardCategory.monthly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_MONTH) != 1) {
                    startDate--;
                }
                heading = "${headingPrefix} ${startDate.format('MMMM YYY')}"
                results = getTopNForPeriod(startDate, today, maxRows)
                break;
            case LeaderBoardCategory.alltime:
                def userScores = userService.getUserCounts();
                heading = "${headingPrefix} All Time"
                for (int i = 0; i < userScores.size(); ++i) {
                    if (i >= maxRows) {
                        break;
                    }
                    results << [name: userScores[i][0], score: userScores[i][1], userId: userScores[i][2]]
                }
                break;
            default:
                break;
        }

        [category: category, results: results, heading: heading]
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
            def user = User.findByUserId(kvp.key)
            list << [name: user.displayName, score: kvp.value, userId: user.id]
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

