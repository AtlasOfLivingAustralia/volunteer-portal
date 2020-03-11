package au.org.ala.volunteer

import grails.transaction.NotTransactional

class LeaderBoardService {

    static transactional = false

    final static EMPTY_LEADERBOARD_WINNER = [userId: 0, name:'', email:'', score:0]
    
    private static Date getTodaysDate() {
        // def today = Date.parse("yyyy-MM-dd", "2014-03-01") // for testing
        def today = new Date().clearTime()
        return today.clearTime()
    }

    def settingsService
    def userService

    def winner(LeaderBoardCategory category, Institution institution, def pt = null) {
        def today = todaysDate

        def ineligibleUsers = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers)

        def result = [name: '', score: 0]
        switch (category) {
            case LeaderBoardCategory.daily:
                result = getLeaderboardWinner(today, today, institution, ineligibleUsers, pt)
                break;
            case LeaderBoardCategory.weekly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_WEEK) != 1) {
                    startDate--;
                }
                result = getLeaderboardWinner(startDate, today, institution, ineligibleUsers, pt)
                break;
            case LeaderBoardCategory.monthly:
                def startDate = (Date) today.clone()
                while (startDate.getAt(Calendar.DAY_OF_MONTH) != 1) {
                    startDate--;
                }

                result = getLeaderboardWinner(startDate, today, institution, ineligibleUsers, pt)
                break;
            case LeaderBoardCategory.alltime:

                if (institution) {
                    def tmp = getTopNForInstitution(1, institution, ineligibleUsers)
                    if (tmp) {
                        result = tmp[0]
                    } else {
                        result = EMPTY_LEADERBOARD_WINNER
                    }
                } else if (pt?.size() >= 0) {
                    def tmp = getTopNForProjectType(1, pt, ineligibleUsers)
                    if (tmp) {
                        result = tmp[0]
                    } else {
                        result = EMPTY_LEADERBOARD_WINNER
                    }
                } else {
                    def userScores = userService.getUserCounts(ineligibleUsers, 1)
                    if (userScores) {
                        result = [userId: userScores[0]['id'], name: userScores[0]['displayName'], email: userScores[0]['email'], score: userScores[0]['total']]
                    } else {
                        result = EMPTY_LEADERBOARD_WINNER
                    }
                }

                break;
            default:
                break;
        }
        result
    }

    def topList(LeaderBoardCategory category, Institution institution, ProjectType projectType = null) {
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
                    def userScores = userService.getUserCounts(ineligibleUsers, maxRows)
                    heading = "${headingPrefix} All Time"
                    for (int i = 0; i < userScores.size(); ++i) {
                        if (i >= maxRows) {
                            break;
                        }
                        results << [name: userScores[i]['displayName'], score: userScores[i]['total'], userId: userScores[i]['id']]
                    }
                }
                break;
            default:
                break;
        }

        [category: category, results: results, heading: heading]
    }

    private Map getLeaderboardWinner(Date startDate, Date endDate, Institution institution, List<String> ineligbleUsers = [], def pt = null) {
        def results = getTopNForPeriod(startDate, endDate, 1, institution, ineligbleUsers, pt)
        if (results) {
            return results[0]
        }

        return EMPTY_LEADERBOARD_WINNER
    }

    List getTopNForInstitution(int count, Institution institution, List<String> ineligibleUsers = []) {

        def scoreMap = getUserCountsForInstitution(institution, ActivityType.Transcribed, ineligibleUsers)
        def validatedMap = getUserCountsForInstitution(institution, ActivityType.Validated, ineligibleUsers)

        return mergeScores(validatedMap, scoreMap, count)
    }

    List getTopNForProjectType(int count, def projectsInLabels = null, List<String> ineligibleUsers = []) {

        def scoreMap = (projectsInLabels?.size() > 0)? getUserCountsForProjectType(projectsInLabels, ActivityType.Transcribed, ineligibleUsers) : [:]
        def validatedMap = (projectsInLabels?.size() > 0)? getUserCountsForProjectType(projectsInLabels, ActivityType.Validated, ineligibleUsers) : [:]
        return mergeScores(validatedMap, scoreMap, count)
    }

    List getTopNForPeriod(Date startDate, Date endDate, int count, Institution institution, List<String> ineligibleUsers = [], def pt = null) {

        // Get a map of users who transcribed tasks during this period, along with the count
        def scoreMap = getUserMapForPeriod(startDate, endDate, ActivityType.Transcribed, institution, ineligibleUsers, pt)
        // Get a map of user who validated tasks during this periodn, along with the count
        def validatedMap = getUserMapForPeriod(startDate, endDate, ActivityType.Validated, institution, ineligibleUsers, pt)


        return mergeScores(validatedMap, scoreMap, count)
    }

    private List mergeScores(LinkedHashMap validatedMap, LinkedHashMap scoreMap, int count) {
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
            def details = userService.detailsForUserId(kvp.key)
            if (user) {
                list << [name: details?.displayName, email: details?.email, score: kvp?.value ?: 0, userId: user?.id]
            } else {
                println "Failed to find user with key: ${kvp.key}"
            }
        }

        // Sort in descending order...
        list?.sort { a, b -> b.score <=> a.score }
        // and just return the top N items
        return list.subList(0, Math.min(list.size(), count))
    }

    Map getUserMapForPeriod(Date startDate, Date endDate, ActivityType activityType, Institution institution, List<String> ineligibleUserIds, def projectsInLabels = null) {
        def results
        if (ActivityType.Transcribed == activityType) {
            results = Transcription.withCriteria {
                ge("dateFully${activityType}", startDate)
                lt("dateFully${activityType}", endDate + 1)

                if (ineligibleUserIds) {
                    not {
                        inList "fully${activityType}By", ineligibleUserIds
                    }
                }
                if (institution) {
                    project {
                        eq("institution", institution)
                    }
                }

                if (projectsInLabels) {
                    project {
                        'in' 'id', projectsInLabels
                    }
                }
                projections {
                    groupProperty("fully${activityType}By")
                    count("fully${activityType}By", 'count')
                }

            }
        } else {
            results = Task.withCriteria {
                ge("dateFully${activityType}", startDate)
                lt("dateFully${activityType}", endDate + 1)

                if (ineligibleUserIds) {
                    not {
                        inList "fully${activityType}By", ineligibleUserIds
                    }
                }
                if (institution) {
                    project {
                        eq("institution", institution)
                    }
                }
                if (projectsInLabels) {
                    project {
                        'in' 'id', projectsInLabels
                    }
                }
                projections {
                    groupProperty("fully${activityType}By")
                    count("fully${activityType}By", 'count')
                }
            }
        }
        def map = [:]
        results.each { row ->
            map[row[0]] = row[1]
        }

        return map
    }

    private getUserCountsForInstitution(Institution institution, ActivityType activityType, List<String> exceptUsers = []) {

        def results
        if (ActivityType.Transcribed == activityType) {
            results = Transcription.withCriteria {
                if (institution) {
                    project {
                        eq("institution", institution)
                    }
                }

                if (exceptUsers) {
                    not {
                        inList "fully${activityType}By", exceptUsers
                    }
                }
                projections {
                    groupProperty("fully${activityType}By")
                    count("fully${activityType}By", 'count')
                }
            }
        } else {
            results = Task.withCriteria {

                if (institution) {
                    project {
                        eq("institution", institution)
                    }
                }

                if (exceptUsers) {
                    not {
                        inList "fully${activityType}By", exceptUsers
                    }
                }
                projections {
                    groupProperty("fully${activityType}By")
                    count("fully${activityType}By", 'count')
                }
            }
        }

        def map = [:]
        results.each { row ->
            map[row[0]] = row[1]
        }

        return map
    }

    private getUserCountsForProjectType(def projectsInLabels = null, ActivityType activityType, List<String> exceptUsers = []) {
        def results
        if (ActivityType.Transcribed == activityType) {
            results = Transcription.withCriteria {
                if (projectsInLabels) {
                    project {
                        'in' 'id', projectsInLabels
                    }
                }

                if (exceptUsers) {
                    not {
                        inList "fully${activityType}By", exceptUsers
                    }
                }
                projections {
                    groupProperty("fully${activityType}By")
                    count("fully${activityType}By", 'count')
                }
            }
        } else {
            results = Task.withCriteria {
                if (projectsInLabels) {
                    project {
                        'in' 'id', projectsInLabels
                    }
                }

                if (exceptUsers) {
                    not {
                        inList "fully${activityType}By", exceptUsers
                    }
                }
                projections {
                    groupProperty("fully${activityType}By")
                    count("fully${activityType}By", 'count')
                }
            }
        }

        def map = [:]
        results.each { row ->
            map[row[0]] = row[1]
        }

        return map
    }
}
