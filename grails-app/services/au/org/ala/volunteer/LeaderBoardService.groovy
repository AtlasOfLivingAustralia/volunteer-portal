package au.org.ala.volunteer

import groovy.sql.Sql
import org.jooq.DSLContext
import org.springframework.beans.factory.annotation.Autowired
import static au.org.ala.volunteer.jooq.tables.VpUser.VP_USER
import static org.jooq.impl.DSL.and as jAnd
import static org.jooq.impl.DSL.select
import static org.jooq.impl.DSL.rank
import static org.jooq.impl.DSL.orderBy
import static org.jooq.impl.DSL.table
import static org.jooq.impl.DSL.name
import static org.jooq.impl.DSL.field

import javax.sql.DataSource

class LeaderBoardService {

    @Autowired
    Closure<DSLContext> jooqContextFactory

    final static EMPTY_LEADERBOARD_WINNER = [userId: 0, name:'', email:'', score:0]

    private static Date getTodaysDate() {
        // def today = Date.parse("yyyy-MM-dd", "2014-03-01") // for testing
        def today = new Date().clearTime()
        return today.clearTime()
    }

    DataSource dataSource
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
                } else if (pt) { //(pt?.size() >= 0) {
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
        log.debug("LeaderBoardService ineligible users: ${ineligibleUsers}")

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

        return mergeScores(validatedMap, scoreMap, count, ineligibleUsers)
    }

    List getTopNForProjectType(int count, def projectsInLabels = null, List<String> ineligibleUsers = []) {

        def scoreMap = (projectsInLabels?.size() > 0)? getUserCountsForProjectType(projectsInLabels, ActivityType.Transcribed, ineligibleUsers) : [:]
        def validatedMap = (projectsInLabels?.size() > 0)? getUserCountsForProjectType(projectsInLabels, ActivityType.Validated, ineligibleUsers) : [:]
        return mergeScores(validatedMap, scoreMap, count, ineligibleUsers)
    }

    List getTopNForPeriod(Date startDate, Date endDate, int count, Institution institution, List<String> ineligibleUsers = [], def pt = null) {
        return getTopNForPeriod(startDate, endDate, count, [institution], ineligibleUsers, pt)
    }

    List getTopNForPeriod(Date startDate, Date endDate, int count, List<Institution> institutionList, List<String> ineligibleUsers = [], def pt = null) {
        log.debug("getTopNForPeriod: ${[startDate: startDate, endDate: endDate, count: count, institutionList: institutionList, ineligibleUsers: ineligibleUsers, pt: pt]}")
        // Get a map of users who transcribed tasks during this period, along with the count
        def scoreMap = getUserMapForPeriod(startDate, endDate, ActivityType.Transcribed, institutionList, ineligibleUsers, pt)
        log.debug("Score Map: ${scoreMap}")
        // Get a map of user who validated tasks during this periodn, along with the count
        def validatedMap = getUserMapForPeriod(startDate, endDate, ActivityType.Validated, institutionList, ineligibleUsers, pt)
        log.debug("Validate Map: ${validatedMap}")

        return mergeScores(validatedMap, scoreMap, count, ineligibleUsers)
    }

    /**
     * Merge the validated score map into the transcribed score map, forming a total activity score for the superset of users.
     * Will omit ineligible users (saved in Admin/Inelgible Users).
     * @param validatedMap Map of users validation scores
     * @param scoreMap Map of users transcribe scores
     * @param count the total number of combined users to list
     * @param ineligibleUsers List of users to be omitted from the leaderboard
     * @return the complete combined list with user details.
     */
    private List mergeScores(LinkedHashMap validatedMap, LinkedHashMap scoreMap, int count, def ineligibleUsers) {
        log.debug("Ineligible users: ${ineligibleUsers}")

        // combine the transcribed count with the validated count for that user.
        validatedMap.each { kvp ->
            if (!scoreMap[kvp.key]) {
                scoreMap[kvp.key] = 0
            }
            scoreMap[kvp.key] += kvp.value
        }

        // Parse the combined scoremap for ineligible users
        scoreMap.each {kvp ->
            // If the user is excluded, set their score to -1.
            if (ineligibleUsers?.size() > 0 && ineligibleUsers?.contains(kvp.key)) {
                scoreMap[kvp.key] = -1
                log.debug("Ineligbile user [${kvp.key}] score: ${scoreMap[kvp.key]}")
            }
        }

        // Sort and clip the top n volunteers
        scoreMap = scoreMap.sort { a, b -> b.value <=> a.value }
        if (scoreMap.size() > count) {
            scoreMap = scoreMap.take(count)
        }
        log.debug("Final Score Map: ${scoreMap}")

        // Flatten the map into a list with user details
        def list = []
        def userDetails = userService.detailsForUserIds(scoreMap.keySet() as List<String>).collectEntries { [(it.userId): it] }
        scoreMap.each { kvp ->
            // Only include if they have a positive score (ineligible users will have -1)
            if (kvp.value > 0) {
                def user = User.findByUserId(kvp.key)
                def details = userDetails[kvp.key]
                if (user) {
                    list << [name: details?.displayName, email: details?.email, score: kvp?.value ?: 0, userId: user?.id]
                    log.debug("Adding user details for ${[name: details?.displayName, email: details?.email, score: kvp?.value ?: 0, userId: user?.id]}")
                } else {
                    log.warn("Failed to find user with key: ${kvp.key}")
                }
            } else {
                log.debug("Omitting ${kvp.key} from leaderboard list")
            }
        }

        return list
    }

    Map getUserMapForPeriod(Date startDate, Date endDate, ActivityType activityType, List<Institution> institutionList,
                            List<String> ineligibleUserIds, def projectsInLabels = null) {
        def map = [:]
        def sql = new Sql(dataSource)

        String select = "select fully_${activityType}_by, count(fully_${activityType}_by) as count "
        String groupByClause = " group by fully_${activityType}_by "
        def filter = " date_fully_${activityType} >= :startDate and date_fully_${activityType} < :endDate "

        def ineligibleUserClause = ""
        if (ineligibleUserIds) {
            ineligibleUserClause = " and fully_${activityType}_by not in (${ineligibleUserIds.join(",").tr(/"/, /'/)})"
        }

        if (ActivityType.Transcribed == activityType) {

            def institutionJoin = ""
            if (institutionList) {
                String institutionIdList = institutionList.collect{ it.id }.join(',').tr(/"/, /'/)
                institutionJoin = " join project on (project.id = transcription.project_id " +
                        " and project.institution_id in (${institutionIdList})) "
            }

            def projectJoin = ""
            if (projectsInLabels) {
                projectJoin = " join ${projectsInLabels} on (${projectsInLabels}.project_id = transcription.project_id)"
            }

            def query = """\
                ${select}
                from transcription
                ${institutionJoin}
                ${projectJoin}
                where ${filter} 
                ${groupByClause} """.stripIndent()

            sql.eachRow(query, [startDate: startDate.toTimestamp(), endDate: (endDate + 1).toTimestamp()]) { row ->
                map[row[0]] = row[1]
            }

        } else {
            def institutionJoin = ""
            if (institutionList) {
                institutionJoin = " join project on (project.id = task.project_id " +
                        " and project.institution_id in (${institutionList.collect{ it.id }.join(',')})) "
            }

            def projectJoin = ""
            if (projectsInLabels) {
                projectJoin = " join ${projectsInLabels} on (${projectsInLabels}.project_id = task.project_id)"
            }

            def query = """\
                ${select}
                from task
                ${institutionJoin}
                ${projectJoin}
                where ${filter} 
                ${groupByClause} """.stripIndent()

            sql.eachRow(query, [startDate: startDate.toTimestamp(), endDate: (endDate + 1).toTimestamp()]) { row ->
                map[row[0]] = row[1]
            }

        }

        sql.close()

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
        def map = [:]
        def sql = new Sql(dataSource)

        String select = "select fully_${activityType}_by, count(fully_${activityType}_by) as count "
        String groupByClause = " group by fully_${activityType}_by "

        def ineligibleUserClause = ""
        if (exceptUsers) {
            ineligibleUserClause = " where fully_${activityType}_by not in (${exceptUsers.join(",").tr(/"/, /'/)})"
        }

        if (ActivityType.Transcribed == activityType) {
            def projectJoin = ""
            if (projectsInLabels) {
                projectJoin = " join ${projectsInLabels} on (${projectsInLabels}.project_id = transcription.project_id)"
            }

            def query = """\
                ${select}
                from transcription
                ${projectJoin}
                ${groupByClause} """.stripIndent()

            sql.eachRow(query) { row ->
                map[row[0]] = row[1]
            }

        } else {
            def projectJoin = ""
            if (projectsInLabels) {
                projectJoin = " join ${projectsInLabels} on (${projectsInLabels}.project_id = task.project_id)"
            }

            def query = """\
                ${select}
                from task
                ${projectJoin}
                ${groupByClause} """.stripIndent()

            sql.eachRow(query) { row ->
                map[row[0]] = row[1]
            }

        }

        sql.close()

        return map
    }

    /**
     * Calculates a users rank on contribution score. Ignores users with no contribution.
     * @param userId the user to rank
     * @return the users rank.
     */
    def getUserRank(String userId) {
        def conditions = []
        def ineligibleUsers = settingsService.getSetting(SettingDefinition.IneligibleLeaderBoardUsers)

        if (ineligibleUsers.size() > 0) {
            log.debug("Adding user clause")
            conditions.add(VP_USER.USER_ID.notIn(ineligibleUsers))
        }

        conditions.add((VP_USER.TRANSCRIBED_COUNT + VP_USER.VALIDATED_COUNT).greaterOrEqual(0))

        DSLContext context = jooqContextFactory()
        def rankRow = context.with("ranks")
                .as(select(VP_USER.ID,
                        VP_USER.USER_ID.as("ref_user_id"),
                        VP_USER.LAST_NAME,
                        VP_USER.FIRST_NAME,
                        (VP_USER.TRANSCRIBED_COUNT + VP_USER.VALIDATED_COUNT).as("score"),
                        rank().over(orderBy((VP_USER.TRANSCRIBED_COUNT + VP_USER.VALIDATED_COUNT).desc())).as("rank")
                ).from(VP_USER)
                .where(jAnd(conditions)))
            .select()
            .from(table(name("ranks")))
            .where(field(name("ranks", "ref_user_id")).eq(userId))
            .fetchOne()

        if (rankRow) {
            def rank = rankRow.value6() as int
            return rank
        } else {
            return 0
        }
    }
}
