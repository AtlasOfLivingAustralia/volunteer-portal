package au.org.ala.volunteer

import grails.converters.JSON

class LeaderBoardController {

    def userService
    def settingsService

    def leaderBoardFragment() {
        def institutionInstance = Institution.get(params.int("institutionId"))

        def legendName = institutionInstance ? institutionInstance.acronym : message(code:'default.application.name')
        def leaderBoardSections = [
            [category: LeaderBoardCategory.daily, label:'Day Tripper'],
            [category: LeaderBoardCategory.weekly, label:'Weekly Wonder'],
            [category: LeaderBoardCategory.monthly, label:'Monthly Maestro'],
            [category: LeaderBoardCategory.alltime, label:"${legendName} Legend"]
        ]

        [leaderBoardSections : leaderBoardSections, institutionInstance: institutionInstance ]
    }

    private static Date getTodaysDate() {
        // def today = Date.parse("yyyy-MM-dd", "2014-03-01") // for testing
        def today = new Date().clearTime()
        return today.clearTime()
    }

    def ajaxLeaderBoardCategoryWinner() {
        def category = params.category as LeaderBoardCategory
        def institution = Institution.get(params.int("institutionId"))

        def today = todaysDate
        
        def ineligibleUsers = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers)

        def result = [name: '', score: 0]
        switch (category) {
            case LeaderBoardCategory.daily:
                result = getLeaderboardWinner(today, today, institution, ineligibleUsers)
                break;
            case LeaderBoardCategory.weekly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_WEEK) != 1) {
                    startDate--;
                }
                result = getLeaderboardWinner(startDate, today, institution, ineligibleUsers)
                break;
            case LeaderBoardCategory.monthly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_MONTH) != 1) {
                    startDate--;
                }

                result = getLeaderboardWinner(startDate, today, institution, ineligibleUsers)
                break;
            case LeaderBoardCategory.alltime:

                if (institution) {
                    def tmp = getTopNForInstitution(1, institution, ineligibleUsers)
                    if (tmp) {
                        result = tmp[0]
                    }
                } else {
                    def userScores = userService.getUserCounts(ineligibleUsers);
                    if (userScores) {
                        result = [name: userScores[0][0], score: userScores[0][1]]
                    }
                }

                break;
            default:
                break;
        }

        render(result as JSON)
    }

    def topList() {

        def category = params.category as LeaderBoardCategory

        def institution = Institution.get(params.int("institutionId"))

        def today = todaysDate

        def ineligibleUsers = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers)
        
        def headingPrefix = "Top 20 volunteers for "
        def heading =  headingPrefix + category?.toString()?.toTitleCase()
        def maxRows = 20
        def results = []
        switch (category) {
            case LeaderBoardCategory.daily:
                heading = "${headingPrefix} ${today.format('d MMMM yyyy')}"
                results = getTopNForPeriod(today, today, maxRows, institution, ineligibleUsers)
                break;
            case LeaderBoardCategory.weekly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_WEEK) != 1) {
                    startDate--;
                }
                heading = "${headingPrefix} week starting ${startDate.format('dd MMMM yyy')}"
                results = getTopNForPeriod(startDate, today, maxRows, institution, ineligibleUsers)
                break;
            case LeaderBoardCategory.monthly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_MONTH) != 1) {
                    startDate--;
                }
                heading = "${headingPrefix} ${startDate.format('MMMM yyyy')}"
                results = getTopNForPeriod(startDate, today, maxRows, institution, ineligibleUsers)
                break;
            case LeaderBoardCategory.alltime:
                if (institution) {
                    results = getTopNForInstitution(maxRows, institution, ineligibleUsers)
                } else {
                    def userScores = userService.getUserCounts(ineligibleUsers);
                    heading = "${headingPrefix} All Time"
                    for (int i = 0; i < userScores.size(); ++i) {
                        if (i >= maxRows) {
                            break;
                        }
                        results << [name: userScores[i][0], score: userScores[i][1], userId: userScores[i][2]]
                    }
                }
                break;
            default:
                break;
        }

        [category: category, results: results, heading: heading]
    }

    private Map getLeaderboardWinner(Date startDate, Date endDate, Institution institution, List<String> ineligbleUsers = []) {
        def results = getTopNForPeriod(startDate, endDate, 5, institution, ineligbleUsers)
        if (results) {
            return results[0]
        }

        return [name:'', score:0]
    }

    private List getTopNForInstitution(int count, Institution institution, List<String> ineligibleUsers = []) {

        def scoreMap = getUserCountsForInstitution(institution, ActivityType.Transcribed)
        def validatedMap = getUserCountsForInstitution(institution, ActivityType.Validated)

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
            if (kvp.key) {
                def user = User.findByUserId(kvp.key)
                def details = userService.detailsForUserId(user?.userId)
                if (user) {
                    list << [name: details?.displayName, score: kvp?.value ?: 0, userId: user?.id]
                } else {
                    println "Failed to find user with key: ${kvp.key}"
                }
            }
        }

        // Sort in descending order...
        list?.sort { a, b -> b.score <=> a.score }
        // and just return the top N items
        return list.subList(0, Math.min(list.size(), count))

    }

    private List getTopNForPeriod(Date startDate, Date endDate, int count, Institution institution, List<String> ineligibleUsers = []) {
        
        // Get a map of users who transcribed tasks during this period, along with the count
        def scoreMap = getUserMapForPeriod(startDate, endDate, ActivityType.Transcribed, institution, ineligibleUsers)
        // Get a map of user who validated tasks during this periodn, along with the count
        def validatedMap = getUserMapForPeriod(startDate, endDate, ActivityType.Validated, institution, ineligibleUsers)

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
            def details = userService.detailsForUserId(user?.userId)
            if (user) {
                list << [name: details?.displayName, score: kvp?.value ?: 0, userId: user?.id]
            } else {
                println "Failed to find user with key: ${kvp.key}"
            }
        }

        // Sort in descending order...
        list?.sort { a, b -> b.score <=> a.score }
        // and just return the top N items
        return list.subList(0, Math.min(list.size(), count))
    }

    private Map getUserMapForPeriod(Date startDate, Date endDate, ActivityType activityType, Institution institution, List<String> ineligibleUserIds) {
        def c = Task.createCriteria()

        def results = c {
            ge("dateFully${activityType}", startDate)
            lt("dateFully${activityType}", endDate + 1)
            if (institution) {
                project {
                    eq("institution", institution)
                }
            }
            if (ineligibleUserIds) {
                not {
                    inList "fully${activityType}By", ineligibleUserIds
                }
            }

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

    private getUserCountsForInstitution(Institution institution, ActivityType activityType) {
        def c = Task.createCriteria()

        def results = c {
            if (institution) {
                project {
                    eq("institution", institution)
                }
            }

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

