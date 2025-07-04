package au.org.ala.volunteer

import au.org.ala.web.UserDetails
import com.google.common.base.Stopwatch
import grails.plugin.cache.CacheEvict
import grails.plugin.cache.Cacheable
import grails.gorm.transactions.NotTransactional
import grails.gorm.transactions.Transactional
import groovy.sql.Sql
import org.imgscalr.Scalr
import org.jooq.DSLContext
import org.jooq.SortOrder
import org.jooq.impl.DSL
import org.springframework.core.io.FileSystemResource
import org.springframework.core.io.Resource

import javax.imageio.ImageIO
import javax.sql.DataSource
import java.awt.image.BufferedImage
import java.sql.Connection
import java.text.SimpleDateFormat
import java.time.LocalDateTime
import java.time.ZoneId

import static au.org.ala.volunteer.jooq.tables.Field.FIELD
import static au.org.ala.volunteer.jooq.tables.Project.PROJECT
import static au.org.ala.volunteer.jooq.tables.Transcription.TRANSCRIPTION
import static au.org.ala.volunteer.jooq.tables.Task.TASK
import static org.jooq.impl.DSL.max
import static org.jooq.impl.DSL.name
import static org.jooq.impl.DSL.select
import static org.jooq.impl.DSL.table
import static org.jooq.impl.DSL.when
import static org.jooq.impl.DSL.or as jOr
import static org.jooq.impl.DSL.field

@Transactional
class TaskService {

    DataSource dataSource
    def grailsApplication
    def multimediaService
    def grailsLinkGenerator
    def fieldService
    def fieldSyncService
    def i18nService
    def userService
    def projectService
    Closure<DSLContext> jooqContext

    private static final int NUMBER_OF_RECENT_DAYS = 90


    int countInactiveProjects() {
        return Project.countByInactive(true)
    }

    /**
     * Returns the number of transcriptions a user has made for a project.
     */
    Integer countUserTranscriptionsForProject(String userId, Project project) {
        List userTranscriptionCount = Task.executeQuery(
                "select count(distinct t.id) from Task t join t.transcriptions trans with trans.fullyTranscribedBy = :userId where t.project = :project",
                [userId:userId, project:project])
        userTranscriptionCount.get(0)
    }

    /**
     * Returns the number of validated transcriptions a user has made for a project.
     */
    Integer countValidUserTranscriptionsForProject(String userId, Project project) {
        String hql = "select count(distinct t.id) from Task t join t.transcriptions trans with trans.fullyTranscribedBy = :userId where t.isValid = :valid"
        def params = [userId: userId, valid:true]
        if (project) {
            hql += " and t.project = :project"
            params.project = project
        }
        List userTranscriptionCount = Task.executeQuery(hql, params)
        userTranscriptionCount.get(0)
    }

    /**
     *
     * @return Map of project id -> count
     */
    Map getProjectTaskTranscribedCounts(boolean activeOnly = false) {
        def querySelect = """
            select t.project.id as projectId, count(t) as taskCount
            from Task t 
            where exists (from Field as f where f.task = t) """.stripIndent()
        def activeClause = "and t.project.inactive != true"
        def query = querySelect + (activeOnly ? activeClause : "") + " group by t.project.id"

        def projectTaskCounts = Task.executeQuery(query)
        projectTaskCounts.toMap()
    }

    /**
     * @return Map of project id -> count
     */
    Map getProjectTaskFullyTranscribedCounts(boolean activeOnly = false) {
        def querySelect = """select t.project.id as projectId, count(t) as taskCount
               from Transcription t """.stripIndent()
        def activeClause = "where t.project.inactive != true"
        def query = querySelect + (activeOnly ? activeClause : "") + " group by t.project.id"

        def projectTaskCounts = Task.executeQuery(query)
        projectTaskCounts.toMap()
    }

    Map getProjectDates() {
        def dates = Task.executeQuery(
            """select t.project.id as projectId, min(trans.dateFullyTranscribed), max(trans.dateFullyTranscribed), min(t.dateFullyValidated), max(t.dateFullyValidated)
               from Task t join t.transcriptions trans with trans.dateFullyTranscribed is not null group by t.project.id order by t.project.id"""
        )

        def map =[:]

        dates.each {
            map[it[0]] = [transcribeStartDate: it[1], transcribeEndDate: it[2], validateStartDate: it[3], validateEndDate: it[4]]
        }
        map
    }

    /**
     *
     * @param project
     * @return List of user id
     */
    List getUserIdsForProject(Project project) {
        def userIds = Task.executeQuery(
            """select distinct tn.fullyTranscribedBy
               from Transcription tn
               join tn.task t 
               where tn.fullyTranscribedBy is not null and
               t.project = :project 
               order by tn.fullyTranscribedBy""", [project: project])
        userIds.toList()
    }

    /**
     *
     * @param project
     * @return List of user id
     */
    List getUserIdsAndCountsForProject(Project project, Map params) {
        def userIds = Task.executeQuery(
            """select tn.fullyTranscribedBy, count(t)
               from Transcription tn 
               join tn.task t 
               where tn.fullyTranscribedBy is not null and
               t.project = :project 
               group by tn.fullyTranscribedBy order by count(t) desc""", [project: project], params)
        userIds.toList()
    }


    int getNumberOfFullyTranscribedTasks(Project project) {
        Task.countByProjectAndIsFullyTranscribed(project, true)
    }

    List getFullyTranscribedTasks(Project project, Map params) {
        Task.findAllByProjectAndIsFullyTranscribed(project, true, params)
    }

    /**
     * Retrieves a list of tasks for a given project. Params provided can include a statusFilter from the options
     * 'transcribed', 'validated', 'not-transcribed' to filter the list on that given status. Also provides a secondary
     * sort on isValid, to prevent random order changes when paginating results.
     * @param project the project to query
     * @param params the query parameters
     * @return a Map containing the task list (taskList) and the taskCount
     */
    Map getTaskListForProject(Project project, def params) {
        if (!project) return null

        def query = """\
            select distinct task.id, 
                task.is_valid, 
                COALESCE(task.number_of_matching_transcriptions, 0),
                task.external_identifier,
                task.fully_validated_by,
                concat(vu.last_name, ' ', vu.first_name) as validator,
                CASE WHEN (task.is_valid = true) THEN 3 
                    WHEN (task.is_valid = false) THEN 2 
                    WHEN (task.is_valid IS NULL AND task.is_fully_transcribed = TRUE) THEN 1 
                    ELSE 0 END AS task_status
            from task
            join project on (project.id = task.project_id)
            left join vp_user vu on (vu.user_id = task.fully_validated_by)
            where project_id = :projectId """.stripIndent()

        def queryParams = [:]
        queryParams.projectId = project.id
        def statusFilterClause = " and task.is_fully_transcribed = :transcribed " +
            " and task.fully_validated_by :validated "

        switch (params.statusFilter) {
            case 'transcribed':
                queryParams.transcribed = true
                statusFilterClause = statusFilterClause.replace(':validated', 'is null')
                break
            case 'validated':
                queryParams.transcribed = true
                statusFilterClause = statusFilterClause.replace(':validated', 'is not null')
                break
            case 'not-transcribed':
                queryParams.transcribed = false
                statusFilterClause = statusFilterClause.replace(':validated', 'is null')
                break
            default:
                statusFilterClause = ""
                break
        }

        def sortClause = " order by "
        switch (params.sort) {
            case 'isValid':
//                sortClause += " task.is_valid " + (params.order ?: 'asc') + ", task.id asc "
                sortClause += " CASE WHEN (task.is_valid = true) THEN 3 " +
                        "WHEN (task.is_valid = false) THEN 2 " +
                        "WHEN (task.is_valid IS NULL AND task.is_fully_transcribed = TRUE) THEN 1 ELSE 0 END " + (params.order ?: 'asc') + ", task.id ASC "
                break
            case 'numberOfMatchingTranscriptions':
                sortClause += " COALESCE(task.number_of_matching_transcriptions, 0) " + (params.order ?: 'asc') + ", task.id asc "
                break
            case 'fullyValidatedBy':
                //sortClause += " task.fully_validated_by " + (params.order ?: 'asc')
                sortClause += " concat(vu.last_name, ' ', vu.first_name) " + (params.order ?: 'asc')
                break
            case 'externalIdentifier':
                sortClause += " task.external_identifier " + (params.order ?: 'asc')
                break
            default:
                sortClause += " task." + (params.sort ?: 'id') + " " + (params.order ?: 'asc')
                break
        }

        def selectQuery = query + statusFilterClause + sortClause + (params.max ? " limit ${params.max} " : "") +
                (params.offset ? " offset ${params.offset} " : "")
        def countQuery = "select count(*) as taskCount from (" + query + statusFilterClause + ") taskList"

        def sql = new Sql(dataSource)
        def taskList = []
        sql.eachRow(selectQuery, queryParams) { row->
            Task task = Task.get(row.id as long)
            if (task) taskList.add(task)
        }

        def rowCount = sql.firstRow(countQuery, queryParams)?.taskCount as Integer
        sql.close()

        [taskList: taskList, taskCount: (rowCount ?: 0)]
    }

    /***
     * Obtain Fully Transcribed tasks and the corresponding transcriptions for the project (eager fetching)
     * Note: if there are 2000 fully transcribed tasks and 4000 transcriptions (2 transcriptions per task), this should return 2000 rows of tasks.
     */
    List getFullyTranscribedTasksAndTranscriptions(Project projectInstance, Map params) {
        Task.executeQuery("""
                        select t from Task t
                        left outer join fetch t.transcriptions
                        where t.project = :projectInstance
                        and t.isFullyTranscribed = true
                        order by t.id
                    """, [projectInstance: projectInstance], params)
    }

    /***
     * Obtain Fully Validated tasks and the corresponding transcriptions for the project (eager fetching)
     * Note: if there are 2000 validated tasks and 4000 transcriptions (2 transcriptions per task), this should return 2000 rows of tasks.
     */
    List getValidTranscribedTasks(Project projectInstance, Map params) {
        Task.executeQuery("""
                        select t from Task t
                        left outer join fetch t.transcriptions
                        where t.project = :projectInstance
                        and t.isValid = true
                        order by t.id
                    """, [projectInstance: projectInstance], params)
    }

    /***
     * Obtain all tasks and the corresponding transcriptions for the project (eager fetching)
     * Note: if there are 2000 tasks and 4000 transcriptions (2 transcriptions per task), this should return 2000 rows of tasks.
     */
    List getAllTasksAndTranscriptionsIfExists(Project projectInstance, Map params) {
        Task.executeQuery("""
                        select t from Task t
                        left outer join fetch t.transcriptions
                        where t.project = :projectInstance
                        order by t.id
                    """, [projectInstance: projectInstance], params)
    }

    // The results above select all Tasks have have less than the required number of transcriptions that the
    // user hasn't yet viewed.  We now have to check the views to see if there are any views of that Task
    // that didn't result in a Transcription and occurred before our timeout window (ie. 2 hours ago)
    private Task processResults(List results, long timeoutWindow, String userId = null, int jump = 1, long lastId = -1) {
        Task transcribableTask = null
        int matches = 0

        log.debug("Processing results for user_id: [${userId}], jump: [${jump}], lastId: [${lastId}]")
        results?.find { result ->
            //Task task = Task.get(result[0] as long)
            Task task = Task.get(result.id as long)
            //log.debug("Checking task ${result}")
            //log.debug("Task: ${task}")

            // If locked or skipped, move onto next task.
            if (!task.isLockedForTranscription(userId, timeoutWindow) && !task.wasSkippedByUser(userId)) {
                // We can allocate this Task as all recent views have resulted in a completed transcription
                // (i.e. views that didn't end up completing the transcription have timed out).
                //log.debug("Not locked and available;")
                //log.debug("task.wasSkippedByUser(userId): ${task.wasSkippedByUser(userId)}")
                transcribableTask = task
                matches++
                if (matches >= jump) {
                    log.debug("Allocating task [${task.id}] to user_id [${userId}].")
                    return true
                }
            }
        }
        transcribableTask
    }

    /**
     * Returns a Task that the user has never viewed where the number of distinct user views is < the total
     * required number of transcriptions. Tasks with more distinct views will be returned first if jump is not
     * required.
     * @param userId The user to allocate a Task to
     * @param project The Project the Task is for.
     * @param transcriptionsPerTask the number of times each Task must be transcribed before it can be validated.
     * @param lastId the last id the user viewed/transcribed.  This is used when tasks need to be skipped,
     * predominently in camera trap projects where the user is shown images they aren't transcribing for context.
     * The jump means they will be allocated a new image they haven't seen before.
    */
    private Task findUnviewedTask(String userId, Project project, Long transcriptionsPerTask = 1, Long lastId = -1, int jump = 1) {
        Task task = null

        Map queryParams = [userId: userId, projectId: project.id, transcriptionsPerTask: transcriptionsPerTask]
        def jumpClause = ""
        def orderBy = "count(distinct vt.user_id) ASC, task.id asc"
        if (jump > 1 && lastId >= 0) {
            queryParams.lastId = lastId
            jumpClause += "AND task.id > :lastId"
            orderBy = "task.id asc"
        }

        String query = """
            WITH vt_list AS 
                (SELECT id, task_id FROM viewed_task where user_id = :userId and task_id in (SELECT id FROM task WHERE project_id = :projectId))
            SELECT task.id, count(distinct vt.user_id)
            FROM task
            LEFT OUTER JOIN viewed_task vt on task.id = vt.task_id
            WHERE task.project_id = :projectId
              AND task.is_fully_transcribed = false
              AND task.id not in (SELECT vt_list.task_id FROM vt_list)
            $jumpClause
            GROUP BY task.id
            HAVING count(distinct vt.user_id) < :transcriptionsPerTask
            ORDER BY $orderBy 
            LIMIT $jump
        """.stripIndent()

        // log.debug("Query: ${query}")

        def sw = Stopwatch.createStarted()
        def sql = new Sql(dataSource)
        def result = sql.rows(query, queryParams)

        if (result) {
            def row = result.last()
            log.debug("Result: ${result}")
            log.debug("Row: ${row}")

            task = Task.get(row?.id as long)
        }
        sql.close()
        log.debug("findUnviewedTask: Got task in ${sw.stop()}")

        task
    }

    /**
     * Find tasks that have not been fully transcribed and have not been viewed by the supplied user.
     * Views that have not resulted in a transcription and occurred within the timeout window will exclude a
     * Task from being returned, as the Transcription is likely in progress.
     * @param userId The user to allocate a Task to
     * @param project The Project the Task is for.
     * @param transcriptionsPerTask the number of times each Task must be transcribed before it can be validated.
     * @param timeoutWindow the time (milliseconds since 1970) after which we consider a Transcription to still
     * be in progress.
     */
    private Task findUnfinishedTaskNotViewedByUser(String userId, Project project, int transcriptionsPerTask, long timeoutWindow, long lastId = -1, int jump = 1) {
        Map params = [userId: userId, projectId: project.id, transcriptionsPerTask: (long) transcriptionsPerTask, lastId: (long) -1]

        if (jump > 1 && lastId >= 0) {
            params.lastId = lastId
        }

        String query = """
            WITH vt_list AS 
                (select id, task_id FROM viewed_task WHERE user_id = :userId and task_id in (select id from task where project_id = :projectId))
            SELECT task.id, count(transcription.id) 
            FROM task
            LEFT JOIN transcription ON (task.id = transcription.task_id AND transcription.fully_transcribed_by IS NOT NULL)
            WHERE task.project_id = :projectId
              AND task.is_fully_transcribed = false
              AND task.id not in (select vt_list.task_id from vt_list)
              AND task.id > :taskId
            GROUP BY task.id
            HAVING count(transcription.id) < :transcriptionsPerTask
            ORDER BY count(transcription.id) DESC, task.id            
        """.stripIndent()

        def sw = Stopwatch.createStarted()
        def sql = new Sql(dataSource)
        def results = sql.rows(query, params)
        sql.close()
        log.debug("findUnfinishedTaskNotViewedByUser: Got task list in ${sw.stop()}")
        log.debug("Searching for unfinished tasks for user_id [${userId}] returned ${results.size()} tasks.")

        // The query above could likely be improved to make this unnecessary, but the result set shouldn't be
        // too large.
        processResults(results, timeoutWindow, userId, jump)
    }

    private Task findViewedButNotTranscribedTask(String userId, Project project, int transcriptionsPerTask, long timeoutWindow, long lastId = -1, int jump = 1) {
        // Finally, the only Tasks left are ones that the user has viewed but not transcribed
        String query = """
            WITH t_list AS 
                (select id, task_id from transcription where fully_transcribed_by = :userId and task_id in (select id from task where project_id = :projectId))
            SELECT task.id, count(transcription.id)
            FROM task
            LEFT JOIN transcription ON task.id = transcription.task_id AND transcription.fully_transcribed_by IS NOT NULL
            WHERE task.project_id = :projectId
              AND task.is_fully_transcribed = false
              AND task.id NOT IN (SELECT t_list.task_id from t_list)
              AND task.id > :taskId
            group by task.id
            having count(transcription.id) < :transcriptionsPerTask
            order by count(transcription.id) desc, task.id
        """.stripIndent()
        def params = [userId: userId, projectId: project.id, taskId: lastId, transcriptionsPerTask: (long) transcriptionsPerTask]

        def sw = Stopwatch.createStarted()
        def sql = new Sql(dataSource)
        def results = sql.rows(query, params)
        log.debug("findViewedButNotTranscribedTask: Got task list in ${sw.stop()}")
        log.debug("Searching for viewed but not transcribed tasks for user_id [${userId}] resulted in ${results.size()} tasks.")

        // The query above could likely be improved to make this unnecessary, but the result set shouldn't be
        // too large.
        processResults(results, timeoutWindow, userId, jump, lastId)
    }

    /**
     * Get the next task for this user
     *
     * @param userId
     * @return
     */
    Task getNextTask(String userId, Project project, Long lastId = -1) {
        log.debug("----------------")
        log.debug("Get next task for user_id: [${userId}], project: [${project.id}], lastId: [${lastId}]")
        if (!project || !userId) {
            return null
        }

        int jump = (project?.template?.viewParams?.jumpNTasks ?: 1) as int
        int transcriptionsPerTask = project.transcriptionsPerTask ?: 1 //(project?.template?.viewParams?.transcriptionsPerTask ?: 1) as int
        log.debug("Transcriptions per task: [${transcriptionsPerTask}], task jump: [${jump}]")

        // This is the length of time for which a Task remains locked after a user views it
        long timeout = grailsApplication.config.getProperty('viewedTask.timeout', Long).longValue()

        //def sw = new Stopwatch()

        // First find a task that hasn't been viewed by the user and has been viewed by fewer users than are
        // required to transcribe the Task.
        Task task = findUnviewedTask(userId, project, transcriptionsPerTask, lastId, jump)
        if (task) {
            log.debug("Unviewed task selected to jump to: [${task.id}]")
            return task
        }

        // If there are no Tasks found above the only Tasks left have been either viewed by the user
        // or viewed by enough distinct users to have theoretically fully transcribed the Task if all views had
        // resulted in a transcription.
        // At this point, either the remaining transcriptions are in progress or some transcriptions have been abandoned.
        task = findUnfinishedTaskNotViewedByUser(userId, project, transcriptionsPerTask, timeout, lastId, jump)
        if (task) {
            //log.debug("getNextTask(project ${project.id}, lastId $lastId) found an unfinished task not viewed by user to jump to: ${task.id}")
            log.debug("Unfinished task assigned to user: [${task.id}]")
            return task
        }

        task = findViewedButNotTranscribedTask(userId, project, transcriptionsPerTask, timeout, lastId, jump)
        if (task) {
            //log.debug("getNextTask(project ${project.id}, lastId $lastId) found a viewed but not transcribed task to jump to: ${task.id}")
            log.debug("Viewed non-transcribed task assigned to user: [${task.id}]")
            return task
        }

        // If we have been unable to find a Task while jumping over Tasks, see if we can get any Task.
        if (lastId >= 0 && jump > 1) {
            // Try it all again, but without the jump
            log.debug("Unable to find a task with jump [${jump}] specified. Re-searching with no jump.")
            task = getNextTask(userId, project)
        }

        return task
    }

    /**
     * Get the next task for this user (with checking for concurrent access)
     *
     * @param userId
     * @param project
     * @return
     */
    Task getNextTaskForValidationForProject(String userId, Project project) {

        if (!project || !userId) {
            return null
        }

        // We have to look for tasks whose last view was before the lock period AND hasn't already been viewed by this user
        def timeoutWindow = System.currentTimeMillis() - (grailsApplication.config.getProperty('viewedTask.timeout', Long).longValue())
        def tasks

        tasks = Task.createCriteria().list([max:1]) {
            eq("project", project)
            eq("isFullyTranscribed", true)
            isNull("fullyValidatedBy")
            and {
                ne("lastViewedBy", userId)
                le("lastViewed", timeoutWindow)
            }
            order("lastViewed", "asc")
        }

        if (tasks) {
            def task = tasks.last()
            log.debug("getNextTaskForValidationForProject(project ${project.id}) found a task: ${task.id}")
            return task
        }

        // Finally, we'll have to serve up a task that this user has seen before
        tasks = Task.createCriteria().list([max:1]) {
            eq("project", project)
            eq("isFullyTranscribed", true)
            isNull("fullyValidatedBy")
            or {
                le("lastViewed", timeoutWindow)
                eq("lastViewedBy", userId)
            }
            order("lastViewed", "asc")
        }

        if (tasks) {
            def task = tasks.last()
            log.debug("getNextTaskForValidationForProject(project ${project.id}) found a task: ${task.id}")
            return task
        }

        return null
    }

  /**
   * Get tasks transcribed by this user. Includes partial edits and complete edits.
   *
   * @param userId
   * @return list of tasks
   */
    List<Task> getRecentlyTranscribedTasks(String userId, Map params) {
        def c = Task.createCriteria()

        c.list(params) {
            eq("fullyTranscribedBy", userId)
            isNotNull("dateFullyTranscribed")
        } as List<Task>
    }

    /**
     * Resets the current views for a task. Utilised when skipping a task, so that it doesn't remain locked for someone
     * else to transcribe the task.
     * @param taskId the skipped task ID
     * @param userId the user who skipped the task.
     * @param isValidating true/false. If false, sets the skipped flag on the ViewedTask record to true as well.
     */
    def resetTaskView(Long taskId, String userId, boolean isValidating = false) {
        def skippedTask = Task.get(taskId)
        log.debug("Skipped Task: ${skippedTask}")
        if (skippedTask != null) {
            skippedTask.lastViewedBy = null
            skippedTask.lastViewed = null
            skippedTask.save(flush: true, failOnError: true)

            // Reset viewed task record
            if (!isValidating) {
                def currentViews = skippedTask.viewedTasks.findAll { view ->
                    return (view.userId == userId)
                }
                log.debug("Current Views: ${currentViews}")
                currentViews.each { view ->
                    view.skipped = true
                    view.save(flush: true, failOnError: true)
                }
            }
        }

        log.debug("Task last viewed: ${skippedTask.lastViewed}, by ${skippedTask.lastViewedBy}")
    }


    private final static List<String> getNotificationWithClauses(projectQuery, boolean unseenOnly = true) { [
"""transcribed_and_validated_tasks AS (
SELECT *
FROM task t
WHERE
  t.fully_transcribed_by = :userId
  AND t.fully_validated_by is not null
  AND t.fully_validated_by != :userId
  AND t.is_valid is not null
  AND t.date_fully_transcribed >= (CURRENT_DATE - $NUMBER_OF_RECENT_DAYS)
  ${unseenOnly ? "AND t.date_fully_validated > (SELECT max(vt.last_updated) FROM viewed_task vt WHERE vt.task_id = t.id and vt.user_id = :userId)" : ""}
  $projectQuery
)""",
"""transcribed_fields AS (
  SELECT *
  FROM field
  WHERE
    superceded = TRUE
    AND transcribed_by_user_id = :userId
    AND task_id IN (SELECT id FROM transcribed_and_validated_tasks)
)""", //--AND updated >= (CURRENT_DATE - $NUMBER_OF_RECENT_DAYS)
"""validated_fields AS (
  SELECT *
  FROM field
  WHERE
    superceded = FALSE
    AND transcribed_by_user_id <> :userId

    AND task_id IN (SELECT id FROM transcribed_and_validated_tasks)
)""", //--AND updated >= (CURRENT_DATE - $NUMBER_OF_RECENT_DAYS)
"""updated_task_ids AS (
  SELECT DISTINCT f.task_id
    FROM transcribed_fields f
      JOIN validated_fields f2 ON f.task_id = f2.task_id AND f.name = f2.name AND f.record_idx = f2.record_idx
    WHERE
      CASE
      WHEN char_length(f.value) <= 255 AND char_length(f2.value) <= 255
        THEN levenshtein_less_equal(f.value, f2.value, 2) >= 3
      ELSE TRUE
      END
)""",
"""validator_notes_task_ids AS (
    SELECT DISTINCT f.task_id
    FROM field f
    WHERE
      f.name = 'validatorNotes'
      AND f.value IS NOT NULL
      AND f.value <> ''
      AND f.transcribed_by_user_id <> :userId
      AND task_id IN (SELECT id FROM transcribed_and_validated_tasks)
)"""//--AND f.updated >= (CURRENT_DATE - $NUMBER_OF_RECENT_DAYS)
    ]}

    /**
     * Get tasks transcribed by this user which has recently been validated but have not yet been viewed by the transcriber.
     *
     * @param project (can be null in which case this returns tasks transcribed by the user
     * @param userId of the user that transcribed the tasks
     * @param taskIds optional list of task ids to check
     * @return list of tasks
     */
    def getUnreadValidatedTasks (Project project, String userId) {

        def sw = Stopwatch.createStarted()

        log.debug("Getting recently validated tasks.")

        String limitClause = 'LIMIT 50'

        String projectQuery = ""
        if (project?.id && project?.id > 0) {
            projectQuery = "AND project_id = :projectId"
        }

        String select = """
            WITH
            ${getNotificationWithClauses(projectQuery).join(',\n')}
            (SELECT * FROM updated_task_ids) UNION (SELECT * FROM validator_notes_task_ids)
            """.stripIndent()

        def sql = new Sql(dataSource)

        def lists = sql.rows(select, [userId: userId, projectId: project?.id]).collect { row ->  row.task_id }

        log.debug("Returning validated tasks: " + sw.stop())
        sql.close()

        return lists
    }

    def getLastViewedBeforeValidation(Project project, String userId, List<Integer> taskIds) {
        if (project) {
            Task.executeQuery("""
    SELECT t.id
    FROM Task t
    WHERE
        t.id IN :taskIds
        AND project = :project
        AND t.dateFullyValidated > (SELECT max(vt.lastUpdated) FROM ViewedTask vt WHERE vt.task.id = t.id and vt.userId = :userId)
    """, [taskIds: taskIds, userId: userId, project: project])
        } else {
            Task.executeQuery("""
    SELECT t.id
    FROM Task t
    WHERE
        t.id IN :taskIds
        AND t.dateFullyValidated > (SELECT max(vt.lastUpdated) FROM ViewedTask vt WHERE vt.task.id = t.id and vt.userId = :userId)
    """, [taskIds: taskIds, userId: userId])
        }
    }

    private static String toPgArrayText(List<?> l) {
        '{' + l.join(',') + '}'
    }

    def countUnreadValidatedTasks (Project project, String userId) {
        if (!userId) {
            return 0
        }
        def sw = Stopwatch.createStarted()
        log.debug("Getting recently validated task count.")

        String projectQuery = ""
        if (project?.id && project?.id > 0) {
            projectQuery = "AND t.project_id = :projectId"
        }

        String select = """
WITH
${getNotificationWithClauses(projectQuery).join(',\n')}
SELECT COUNT(*) FROM (SELECT * FROM updated_task_ids UNION SELECT * FROM validator_notes_task_ids) AS ids
  """

        def sql = new Sql(dataSource)

        log.debug("countUnreadValidatedTasks query:\n$select")

        def count = sql.firstRow(select, [userId: userId, projectId: project?.id]).values()[0]

        log.debug("Returning validated task count: " + sw.stop())
        sql.close()

        return count
    }

    List<Task> getRecentValidatedTasks (Project project, String transcriber) {

        def sw = Stopwatch.createUnstarted()

        if (log.isInfoEnabled()) {
            sw.start()
            log.debug("Getting recently validated tasks. ")
        }

        def SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd")
        def recentDate = sdf.parse(sdf.format(new Date() - NUMBER_OF_RECENT_DAYS))

        def tasks = Task.createCriteria().list() {
            eq("fullyTranscribedBy", transcriber)
            isNotNull("fullyValidatedBy")
            isNotNull("dateFullyValidated")
            isNotNull("isValid")
            gt("dateFullyTranscribed", recentDate)
            order('dateLastUpdated','desc')
        } as List<Task>

         if (log.isInfoEnabled()) {
            sw.stop()
            log.debug("Returning validated tasks: " + sw.toString())
        }

        return tasks as List<Task>
    }

    /**
     * Get the changes which the validator made.
     *
     * @task the task that is being selected
     * @return list of changes. This is a hashmap of field name as key and list of old and new values
     */
    def getChangedFields (Task task) {

        def sw = Stopwatch.createStarted()
        log.debug("Getting recently validated task field.")

        String transcribedByUserId = task.fullyTranscribedBy
        String validatedByUserId = task.fullyValidatedBy
        String validatorDisplayName = userService.detailsForUserId(validatedByUserId)?.displayName
        Template template = task.project.template

        String select = """
WITH superceded_fields AS (
  SELECT "name", record_idx, "value" AS transcriber_value, updated AS transcriber_updated
  FROM field
  WHERE
    task_id = :taskId
    AND superceded = true
    AND transcribed_by_user_id <> 'system'
    --AND transcribed_by_user_id = :userId
    AND ("name", "record_idx", "updated") IN (
      SELECT "name", "record_idx", max(updated)
      FROM field
      WHERE
        task_id = :taskId
        AND superceded = true
        AND transcribed_by_user_id <> 'system'
        --AND transcribed_by_user_id = :userId
      GROUP BY "name", record_idx
    )
),
validated_fields AS (
    SELECT "name", record_idx, "value" as validator_value, updated AS validator_updated
    FROM field
    WHERE
      task_id = :taskId
      AND superceded = false
      AND field.transcribed_by_user_id = :validatorId
      AND ("name", "record_idx", "updated") IN (
        SELECT "name", "record_idx", max(updated)
        FROM field
        WHERE
          task_id = :taskId
          AND superceded = false
          AND transcribed_by_user_id = :validatorId
        GROUP BY "name", record_idx
      )
)
SELECT *
FROM superceded_fields o NATURAL JOIN validated_fields
ORDER BY record_idx, name;
          """

        def sql = new Sql(dataSource)

        log.debug("Running SQL to find differences: $select")
        final recordValues = sql.rows(select, [taskId: task.id, userId: transcribedByUserId, validatorId: validatedByUserId]).collect { row ->
            final String fieldName = row["name"]
            def dwcField
            try { dwcField = fieldName as DarwinCoreField } catch (e) { dwcField = null }
            final label = TemplateField.findByTemplateAndFieldType(template, dwcField)?.uiLabel ?: dwcField?.label ?: fieldName
            [name: row["name"], label: label, recordIdx: row['record_idx'], oldValue: row['transcriber_value'] ?: '', newValue: row['validator_value'] ?: '', lastModified: row["validator_updated"]]
        }.groupBy { it.recordIdx }

        def validatorNotes = Field.findByTaskAndNameAndSuperceded(task, 'validatorNotes', false)?.value

        log.debug("Returning validated task fields: ${sw.stop()}")
        sql.close()

        return [recordValues: recordValues, validatorDisplayName: validatorDisplayName, validatorNotes: validatorNotes]
    }

    static class FileMap {

        String dir
        String raw
        String localPath
        String localUrlPrefix
        String contentType
        String thumb
        String small
        String medium
        String large
    }

    /**
     * GET the image via its URL and save various forms to local disk
     *
     * @param imageUrl
     * @return fileMap
     */
    def copyImageToStore = { String imageUrl, projectId, taskId, multimediaId ->
        def url = new URL(imageUrl)
        def filename = url.path.replaceAll(/\/.*\//, "") // get the filename portion of url
        if (!filename.trim()) {
            filename = "image_" + taskId
        }
        filename = URLDecoder.decode(filename, "utf-8")
        def conn = url.openConnection()
        def fileMap = new FileMap()

        String urlPrefix = grailsApplication.config.getProperty('images.urlPrefix', String)
        if (!urlPrefix.endsWith('/')) {
            urlPrefix += '/'
        }

        try {
            def dir = new File("${grailsApplication.config.getProperty('images.home', String)}/${projectId}/${taskId}/${multimediaId}")
            if (!dir.exists()) {
                log.debug "Creating dir ${dir.absolutePath}"
                dir.mkdirs()
            }
            fileMap.dir = dir.absolutePath
            def file = new File(dir, filename)
            file << conn.inputStream

            File processedFile = new File(dir, filename)
            boolean result = ImageUtils.reorientImage(file, processedFile)

            fileMap.raw = processedFile.name
            fileMap.localPath = processedFile.getAbsolutePath()
            fileMap.localUrlPrefix = urlPrefix + "${projectId}/${taskId}/${multimediaId}/"
            fileMap.contentType = conn.contentType
            return fileMap
            //file.close()
        } catch (Exception e) {
            log.error("Failed to load URL: ${imageUrl}", e)
        }
    }

    /**
     * Create cropped/scaled versions of the raw image
     *
     * @param fieMap
     * @return fileMap
     */
    def createImageThumbs = { FileMap fileMap ->
        BufferedImage srcImage = ImageIO.read(new FileInputStream(fileMap.dir + "/" +fileMap.raw))
        // Scale the image using the imgscalr library
        def sizes = ['thumb': 300, 'small': 600, 'medium': 1280, 'large': 2000]
        sizes.each{
            fileMap[it.key] = fileMap.raw.replaceFirst(/\.(.{3,4})$/,'_' + it.key +'.$1') // add _small to filename
            BufferedImage scaledImage = srcImage
            if (srcImage.width > it.value /* || srcImage.height > it.value */) {
                scaledImage = Scalr.resize(srcImage, it.value)
            }
            ImageIO.write(ensureOpaque(scaledImage), "jpg", new File(fileMap.dir + "/" + fileMap[it.key]))
        }

        return fileMap
    }

    static BufferedImage ensureOpaque(BufferedImage bi) {
        if (bi.getTransparency() == BufferedImage.OPAQUE)
            return bi
        int w = bi.getWidth()
        int h = bi.getHeight()
        int[] pixels = new int[w * h]
        bi.getRGB(0, 0, w, h, pixels, 0, w)
        BufferedImage bi2 = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
        bi2.setRGB(0, 0, w, h, pixels, 0, w)
        return bi2
    }

    /** Attempt to rollback any changes made during @link copyImageToStore or @link createImageThumbs */
    def rollbackMultimediaTransaction(String imageUrl, long projectId, long taskId, long multimediaId) {
        // Just delete the whole MM directory.
        if (projectId && taskId && multimediaId) {
            def dir = new File((grailsApplication.config.getProperty('images.home', String) as String) + '/' + projectId + '/' + taskId + "/" + multimediaId)
            if (dir.exists() && !dir.deleteDir()) throw new IOException("Couldn't delete $dir")
        }
    }

    List<Map> transcribedDatesByUserAndProject(String userid, long projectId, String labelTextFilter) {
        def select = """
            SELECT t.id as id, t.is_valid as isValid, field2.lastEdit as lastEdit, p.name as project
            FROM Project p 
            JOIN Task t on p.id = t.project_id
            JOIN Transcription trans on trans.task_id = t.id
            LEFT OUTER JOIN (SELECT task_id, max(updated) as lastEdit from field f where f.transcribed_by_user_id = :userid group by f.task_id) as field2 on field2.task_id = t.id
            WHERE trans.fully_transcribed_by = :userid and p.id = :projectId
            ORDER BY lastEdit ASC
        """

        if (labelTextFilter) {
            select = """
                SELECT t.id as id, t.is_valid as isValid, field2.lastEdit as lastEdit, p.name as project
                FROM Project p 
                JOIN Task t ON p.id = t.project_id
                JOIN Transcription trans on trans.task_id = t.id
                INNER JOIN (select f.task_id, f.value from Field f where f.name = 'occurrenceRemarks' and f.superceded = false and f.value ilike :labelTextFilter) as field on field.task_id = t.id
                INNER JOIN (SELECT task_id, max(updated) as lastEdit from field f where f.transcribed_by_user_id = :userid group by f.task_id) as field2 on field2.task_id = t.id
                WHERE trans.fully_transcribed_by = :userid and p.id = :projectId
            """
        }

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(select, [userid: userid, projectId: projectId, labelTextFilter: '%' + labelTextFilter + '%']) { row ->
            def taskRow = [id: row.id, lastEdit: row.lastEdit, isValid: row.isValid, project: row.project ]
            results.add(taskRow)
        }
        sql.close()

        return results
    }


    /**
     * Find all task ids in a project with the given field name equal to one of a set of field values.  This
     * is currently only used for sequence numbers and will require updating to support record_idx, etc.
     * @param projectId The project id the tasks will belong to
     * @param fieldName The field name to search for
     * @param fieldValues The field values to search for
     * @return A map of field value to task id
     */
    Map<String, Long> findByProjectAndFieldValues(Long projectId, String fieldName, Collection<String> fieldValues) {
        if (fieldValues) {
            DSLContext create = jooqContext()

            def taskIds = name("task_ids").as(select(TASK.ID).from(TASK).where(TASK.PROJECT_ID.eq(projectId)))

            def results =
                    create.with(taskIds)
                            .select(FIELD.TASK_ID, FIELD.VALUE)
                            .from(FIELD)
                            .where(FIELD.TASK_ID.in(select(taskIds.field('id')).from(taskIds)))
                            .and(FIELD.SUPERCEDED.eq(false))
                            .and(FIELD.NAME.eq(fieldName))
                            .and(FIELD.VALUE.in(fieldValues))
                            .fetchMaps()
            return results.collectEntries { row ->
                [(row.value): row.task_id]
            }
        } else {
            return [:]
        }
    }

    /**
     * Currently only used for sequence numbers.  Requires updating for fields with a record_idx
     * @param project The project the task belongs to
     * @param fieldName The field name
     * @param fieldValue The field value
     * @return The task the corresponding field belongs to
     */
    Task findByProjectAndFieldValue(Project project, String fieldName, String fieldValue) {
        def select = """
            WITH task_ids AS (SELECT id from task where project_id = :projectId)
            SELECT f.task_id as id from field f WHERE f.task_id in (SELECT id FROM task_ids) and f.superceded = false and f.name = :fieldName and value = :fieldValue
        """

        def sql = new Sql(dataSource: dataSource)
        int taskId = -1
        def row = sql.firstRow(select, [projectId: project.id, fieldName: fieldName, fieldValue: fieldValue])
        if (row) {
            taskId = row[0] as int
        }
        sql.close()
        return Task.findById(taskId)
    }

    Map getImageMetaData(Task taskInstance) {
        def imageMetaData = [:]

        taskInstance.multimedia.each { multimedia ->
            try {
                imageMetaData[multimedia.id] = getImageMetaData(multimedia)
            } catch(Exception e) {
                log.error("Unable to get image metadata for resource: ${multimedia?.filePath}, skipping.")
            }
        }

        return imageMetaData
    }

    @Cacheable(value='getAudioMetaData', key={ "${(multimedia ? multimedia.id : 0)}" })
    String getAudioMetaData(Multimedia multimedia) {
        def path = multimedia?.filePath
        if (path) {
            return multimediaService.getImageUrl(multimedia)
        } else {
            throw new IOException("Could not read multimedia file: ${multimedia?.filePath}")
        }
    }

    /**
     * Returns Image meta data for a task image. If the rotate parameter is provided, the image is rotated by that
     * number of degrees.<br/>
     * Cached.
     * @param multimedia The image multimedia object
     * @param rotate the number of degrees to rotate the image (0 is do not rotate)
     * @return the image metadata.
     */
    @Cacheable(value = 'getImageMetaData', key = { "${(multimedia ? multimedia.id : 0)}-${rotate}" })
    ImageMetaData getImageMetaData(Multimedia multimedia, int rotate) {
        log.debug("Image metadata, rotate: ${rotate}")
        def path = multimedia?.filePath
        if (path) {
            def imageUrl = multimediaService.getImageUrl(multimedia)

            if ([90,180,270].contains(rotate)) {
                imageUrl = grailsLinkGenerator.link(controller: 'task', action:'imageDownload', id: multimedia.id, params:[rotate: rotate])
            }

            String urlPrefix = grailsApplication.config.getProperty('images.urlPrefix', String)
            String imagesHome = grailsApplication.config.getProperty('images.home', String)
            path = imagesHome + '/' + path.substring(urlPrefix?.length())
            //path = URLDecoder.decode(imagesHome + '/' + path.substring(urlPrefix?.length()), "utf-8")  // have to reverse engineer the files location on disk, this info should be part of the Multimedia structure!

            return getImageMetaDataFromFile(new FileSystemResource(path), imageUrl, rotate)
        }

        throw new IOException("Could not read multimedia file: ${multimedia?.filePath}")
    }

    @Cacheable(value='getImageMetaDataFromFile', key = { "${(resource ? (resource.URI ? resource.URI.toString() : (resource.filename ?: '')) : '')}-${(imageUrl ?: '')}-${rotate}"})
    ImageMetaData getImageMetaDataFromFile(Resource resource, String imageUrl, int rotate) {

        BufferedImage image
        try {
            image = ImageIO.read(resource.inputStream)
        } catch (Exception ex) {
            log.error("Exception trying to read image path: ${resource}, ${ex.message}")  // don't print whole stack trace
        }

        if (image) {
            def width = image.width
            def height = image.height
            if (rotate == 90 || rotate == 270) {
                width = image.height
                height = image.width
            }
            return new ImageMetaData(width: width, height: height, url: imageUrl)
        } else {
            log.error("Could not read image file: $resource - could not get image metadata")
            throw new IOException("Could not read image file: $resource - could not get image metadata")
        }
    }


    private Date findMostRecentDate(String dateField, Task task) {
        def c = Field.createCriteria()
        def list = c.list {
            eq("task", task)
            projections {
                max(dateField)
            }

        }
        return list?.get(0)
    }

    /**
     * This method clears the transcriber and date transcribed fields. It also decrements the transcribers score
     * @param task
     */
    def resetTranscribedStatus(Task task) {
        if (!task) {
            return
        }

        if (!task.isFullyTranscribed || task.project.requiredNumberOfTranscriptions > 1) {
            return
        }

        task.isFullyTranscribed = false
        def tr = task.transcriptions
        tr.each {
            def transcriber = User.findByUserId(it.fullyTranscribedBy)
            if (transcriber) {
                //transcriber.transcribedCount--
                fieldSyncService.decrementTranscriptionCount(transcriber.id)
            }

            it.fullyTranscribedBy = null
            it.dateFullyTranscribed = null
        }

        // Also reset the validation status!
        resetValidationStatus(task)
    }

    /**
     * This method takes a task and clears it's validated by and date fully validated fields. It also decrements the score of the user
     * @param task
     */
    def resetValidationStatus(Task task) {
        if (!task) {
            return
        }

        if (!task.fullyValidatedBy && !task.dateFullyValidated) {
            return
        }

        def validator = User.findByUserId(task.fullyValidatedBy)
        if (validator) {
            //validator.validatedCount--
            fieldSyncService.decrementValidationCount(validator.id)
        }
        task.isValid = null
        task.fullyValidatedBy = null
        task.dateFullyValidated = null
    }

    @CacheEvict(value = 'findMaxSequenceNumber', key = { projectId })
    void clearMaxSequenceNumber(long projectId) {
        log.debug('max sequence number cleared for project ${projectId}')
    }

    @Cacheable(value = 'findMaxSequenceNumber', key = { (project ? project.id : -1) })
    Integer findMaxSequenceNumber(Project project) {
        def select ="""
            WITH task_ids AS (SELECT id FROM task WHERE project_id = ${project.id})
            SELECT MAX(CASE WHEN f.value~E'^\\\\d+\$' THEN f.value::integer ELSE 0 END) 
            FROM FIELD f 
            WHERE f.task_id IN (SELECT id FROM task_ids) 
            AND f.name = 'sequenceNumber'; """

        def sql = new Sql(dataSource)
        def row = sql.firstRow(select)
        sql.close()
        row && row[0] != null ? row[0] as Integer : 0
    }

    Map getAdjacentTasksBySequence(Task task) {
        def results = [:]
        if (!task) {
            return results
        }


        def field = fieldService.getFieldForTask(task, "sequenceNumber")

        if (field?.value && field.value.isInteger()) {
            def sequenceNumber = Integer.parseInt(field.value)
            def padSize = 0
            if (field.value.startsWith("0")) {
                // remember to left pad the resulting sequence numbers with 0
                padSize = field.value.length()
            }

            def formatSequence = { int sequence ->
                def result = sequence.toString()
                if (padSize) {
                    result = result.padLeft(padSize, "0")
                }
                return result
            }

            // prev task
            results.sequenceNumber = sequenceNumber
            results.prev = findByProjectAndFieldValue(task.project, "sequenceNumber", formatSequence(sequenceNumber - 1))
            results.next = findByProjectAndFieldValue(task.project, "sequenceNumber", formatSequence(sequenceNumber + 1))
        }

        return results
    }

    Map<String, UserDetails> getUserMapFromTaskList(List<Task> tasks) {
        if (tasks && tasks.size() > 0) {
            def transcribers = Transcription.createCriteria().list {
                inList('task', tasks)
                projections {
                    property 'fullyTranscribedBy'
                }
            }.unique()

            def userIds = (tasks.fullyValidatedBy?.grep{it && it != 'system'} + transcribers).unique()

            return userService.detailsForUserIds(userIds).collectEntries { [ (it.userId): it ]}
        }

        return [:]
    }

    /**
     *
     * @param filter
     * @param user
     * @param project
     * @param offset
     * @param max
     * @param sort
     * @param order
     * @return
     */
    Map getNotebookTaskList(String filter, User user, Project project, Integer offset, Integer max, String sort, String order) {
        log.debug("Retrieving task list for notebook for user ${user}")
        DSLContext create = jooqContext()
        final String FILTER_TRANSCRIBED = 'transcribed'
        final String FILTER_VALIDATED = 'validated'
        final String FILTER_SAVED = 'saved'

        if (!offset) offset = 0
        max = Math.max(Math.min(max ?: 0, 100), 1)

        final projectFilter = PROJECT.ID.eq(project?.id)
        def withWhereClauseList = []
        if (FILTER_TRANSCRIBED.equalsIgnoreCase(filter) || !filter) {
            withWhereClauseList.add(TRANSCRIPTION.FULLY_TRANSCRIBED_BY.eq(user.userId))
        }
        if (FILTER_VALIDATED.equalsIgnoreCase(filter) || !filter) {
            withWhereClauseList.add(TASK.FULLY_VALIDATED_BY.eq(user.userId))
        }

        def mainWhereClauseList = []
        if (project) mainWhereClauseList.add(projectFilter)

        final withClause =
                select(TRANSCRIPTION.ID.as("transcription_id"),
                       TRANSCRIPTION.TASK_ID.as("task_id"),
                       TRANSCRIPTION.FULLY_TRANSCRIBED_BY.as("fully_transcribed_by"),
                        TASK.FULLY_VALIDATED_BY.as("fully_validated_by"),
                        TRANSCRIPTION.DATE_FULLY_TRANSCRIBED.as("date_fully_transcribed"),
                        TASK.DATE_FULLY_VALIDATED.as("date_fully_validated"),
                        TASK.IS_VALID.as("is_valid"),
                        TASK.IS_FULLY_TRANSCRIBED.as("is_fully_transcribed"),
                        TASK.PROJECT_ID.as("project_id"))
                .from(TRANSCRIPTION)
                .join(TASK).on(TASK.ID.eq(TRANSCRIPTION.TASK_ID))
                .where(jOr(withWhereClauseList))

        // SORTING
        final validSorts = [
                'id': 'task_id',
                'projectName': 'project_name',
                'dateTranscribed': 'date_transcribed',
                'status': 'status'
        ].withDefault { 'date_transcribed' }
        def sortColumn = validSorts[sort]
        if (!'asc'.equalsIgnoreCase(order)) order = 'desc'

        // Status Column
        def statusColumn = getTaskStatus()

        // Main select query
        def taskQuery
        if (FILTER_SAVED.equalsIgnoreCase(filter)) {
            taskQuery = getSavedTaskQuery(create, user, project)
        } else {
            taskQuery = create.with("user_transcription").as(withClause)
                    .select(
                            field(name("user_transcription", "transcription_id")),
                            field(name("user_transcription", "task_id")),
                            field(name("user_transcription", "fully_transcribed_by")),
                            field(name("user_transcription", "fully_validated_by")),
                            field(name("user_transcription", "is_valid")),
                            PROJECT.ID.as("project_project_id"),
                            PROJECT.NAME.as("project_name"),
                            field(name("user_transcription", "is_fully_transcribed")),
                            when(field(name("user_transcription", "fully_validated_by")).eq(user.userId), field(name("user_transcription", "date_fully_validated")))
                                    .otherwise(field(name("user_transcription", "date_fully_transcribed")))
                                    .as("date_transcribed"),
                            when(field(name("user_transcription", "is_valid")).eq(true), statusColumn.validatedStatus as String)
                                    .when(field(name("user_transcription", "is_valid")).eq(false), statusColumn.invalidatedStatus as String)
                                    .when(field(name("user_transcription", "fully_transcribed_by")).isNotNull(), statusColumn.transcribedStatus as String)
                                    .otherwise(statusColumn.savedStatus as String)
                                    .as("status")
                    ).distinctOn(field(name("user_transcription", "task_id")))
                    .from(table(name("user_transcription")))
                    .join(PROJECT).on(field(name("user_transcription", "project_id")).eq(PROJECT.ID))
                    .where(mainWhereClauseList)
                    .orderBy(field(name("user_transcription", "task_id")).desc())
        }

        // Wrapper query with column sort
        def query = select(taskQuery.fields())
            .from(taskQuery)
            .orderBy(taskQuery.field(sortColumn).sort('asc'.equalsIgnoreCase(order) ? SortOrder.ASC : SortOrder.DESC))

        // Get the total rows
        Stopwatch sw = Stopwatch.createStarted()
        def result = [:]
        def totalCount = create.fetchCount(query)
        result.totalMatchingTasks = totalCount
        sw.stop()
        log.debug("TaskService.getNotebookTaskList()#CountTasks ${sw.toString()}")

        // Get the rows for the page
        query = query
                .offset(offset)
                .limit(max)

        sw.reset().start()
        result.viewList = create.fetch(query).collect {row ->
            // Find out if the user is a validator for any of the projects/institutions of the tasks in the list
            def taskProject = Project.get(row.project_project_id as long)
            def isValidatorForTaskProject = userService.isValidatorForProjectId(row.project_project_id as long, taskProject.institution.id)
            log.debug("TaskService.getNotebookTaskList()#taskList.isValidator: ${isValidatorForTaskProject} for project ${taskProject.name} (${taskProject.id})")

            [
                    id: row.transcription_id,
                    task_id: row.task_id,
                    fullyTranscribedBy: row.fully_transcribed_by,
                    fullyValidatedBy: row.fully_validated_by,
                    isValid: row.is_valid,
                    projectId: row.project_project_id,
                    projectName: row.project_name,
                    isFullyTranscribed: row.is_fully_transcribed,
                    dateTranscribed: row.date_transcribed,
                    status: row.status,
                    isValidator: isValidatorForTaskProject
            ]
        }
        sw.stop()
        log.debug("TaskService.getNotebookTaskList()#getTasks ${sw.toString()}")

        result
    }

    /**
     * Constructs a jooq query to select tasks that are saved by the user.
     * @param context the DSLContext object
     * @param user the user to query
     * @param project the proejct to query for saved tasks.
     * @return the constructed query
     */
    def getSavedTaskQuery(DSLContext context, User user, Project project) {
        def statusColumn = getTaskStatus()

        def whereClause = []
        whereClause.add(TASK.IS_FULLY_TRANSCRIBED.eq(false))
        whereClause.add(TRANSCRIPTION.FULLY_TRANSCRIBED_BY.isNull())
        if (project) whereClause.add(PROJECT.ID.eq(project.id))

        def taskQuery = context.select(TRANSCRIPTION.ID.as("transcription_id"),
                TRANSCRIPTION.TASK_ID,
                TRANSCRIPTION.FULLY_TRANSCRIBED_BY,
                TASK.FULLY_VALIDATED_BY,
                TASK.IS_FULLY_TRANSCRIBED,
                TASK.IS_VALID,
                PROJECT.ID.as("project_project_id"),
                PROJECT.NAME.as("project_name"),
                when(TASK.FULLY_VALIDATED_BY.eq(user.userId), TASK.DATE_FULLY_VALIDATED)
                    .when(TRANSCRIPTION.DATE_FULLY_TRANSCRIBED.isNotNull(), TRANSCRIPTION.DATE_FULLY_TRANSCRIBED)
                    .otherwise(field(name("field_entries", "date_last_updated")))
                    .as("date_transcribed"),
                when(TASK.IS_VALID.eq(true), statusColumn.validatedStatus as String)
                    .when(TASK.IS_VALID.eq(false), statusColumn.invalidatedStatus as String)
                    .when(TRANSCRIPTION.FULLY_TRANSCRIBED_BY.isNotNull(), statusColumn.transcribedStatus as String)
                    .otherwise(statusColumn.savedStatus as String)
                    .as("status"))
            .distinctOn(TASK.ID)
            .from(TRANSCRIPTION)
            .join(TASK).on(TASK.ID.eq(TRANSCRIPTION.TASK_ID))
            .join(PROJECT).on(PROJECT.ID.eq(TASK.PROJECT_ID))
            .join((select(FIELD.TASK_ID, FIELD.TRANSCRIBED_BY_USER_ID, max(FIELD.UPDATED).as("date_last_updated"))
                    .from(FIELD)
                    .where(FIELD.SUPERCEDED.eq(false)) & FIELD.TRANSCRIBED_BY_USER_ID.eq(user.userId))
                    .groupBy(FIELD.TASK_ID, FIELD.TRANSCRIBED_BY_USER_ID).asTable("field_entries"))
                .on(field(name("field_entries", "task_id")).eq(TASK.ID))
            .where(whereClause)

        return taskQuery
    }

    /**
     * Returns a map containing task statuses for use in a query.
     * @return a Map of task statuses
     */
    Map getTaskStatus() {
        final validatedStatus = i18nService.message(code: 'status.validated', default: 'Validated')
        final invalidatedStatus = i18nService.message(code: 'status.invalidated', default: 'In progress')
        final transcribedStatus = i18nService.message(code: 'status.transcribed', default: 'Transcribed')
        final savedStatus = i18nService.message(code: 'status.saved', default: 'Saved')

        [validatedStatus: validatedStatus, invalidatedStatus: invalidatedStatus, transcribedStatus: transcribedStatus, savedStatus: savedStatus]
    }

    @NotTransactional // handle the read only transaction at the sql level
    // TODO Use Gradle, Flyway, JOOQ instead of plain SQL
    // Or upgrade Elastic Search, add additional fields to the index for user display names and the like
    // and use it to search.
    /**
     * Gets a view list of tasks for the user notebook feature.
     * This method uses plain SQL because to use array aggregations, joins on derived tables and joins
     * on non foreign key fields.  It attempts to build a query to load the data for 1 of 4 tabs using
     * essentially the same query with different filter criteria.  The tabs are:
     *
     *  0 - "My notifications"
     *  1 - "Transcribed tasks"
     *  2 - "Saved tasks"
     *  3 - "Validated tasks"
     *
     *  Additionally, it provides paging, so it runs 2 queries, one that selects the total count and
     *  another to select just the records for the current page.  Sorting is also supported using
     *  a strict set of columns.
     *
     * @param selectedTab - the index of the tab to load data for: 0 for notifications
     * @param user - the user to get the data for
     * @param project - the project to get the data for or null for no project
     * @param query - The search query that will exact match some fields
     * @params offset - The offset to fetch
     * @params max - The number of documents to return (1-100)
     * @params sort - The sort column
     * @params order - 'asc'ending or 'desc'ending
     */
    Map getTaskViewList(int selectedTab, User user, Project project, String query, Integer offset, Integer max, String sort, String order) {
        Stopwatch sw = Stopwatch.createStarted()
        log.debug("Generating task view list for project [${project?.id}]")
        // DEFAULTS FOR MAX, OFFSET
        if (!offset) offset = 0
        max = Math.max(Math.min(max ?: 0, 100), 1)

        // SELECTED TAB
        final projectFilter = ' AND project_id = :project '
        String filter
        String additionalJoins = ''
        String dateTranscribed = 'tr.date_fully_transcribed'
        List<String> withClauses = []

        // Query for transcribed and saved tasks needs to select distinct tasks
        boolean distinctTasks = false

        switch (selectedTab) {
            case 0:
                // transcribed tasks that are recently validated
                withClauses += getNotificationWithClauses(project ? projectFilter : '', false)
                additionalJoins = 'JOIN (SELECT * FROM updated_task_ids UNION SELECT * FROM validator_notes_task_ids) AS ids ON t.id = ids.task_id'
                filter = 'TRUE' // filter occurs by joining with the updated and validator notes task ids.
                break
            case 1:
                filter = 'tr.fully_transcribed_by = :userId'
                distinctTasks = true
                break
            case 2:
                filter = 't.is_fully_transcribed = false'
                additionalJoins = """JOIN (SELECT f.task_id, MAX(f.updated) as date_last_updated
                                      FROM field f
                                      WHERE f.superceded = false
                                      AND f.transcribed_by_user_id = :userId
                                      GROUP BY f.task_id) as s ON s.task_id = t.id """.stripIndent()
                dateTranscribed = "COALESCE($dateTranscribed, s.date_last_updated)"
                distinctTasks = true
                break
            case 3:
                filter = 't.fully_validated_by = :userId'
                distinctTasks = true
                break
            case 4:
                filter = 'tr.fully_transcribed_by = :userId OR t.is_fully_transcribed = false'
                distinctTasks = true
                break
            default:
                throw new IllegalArgumentException("selectedTab must be between 0 and 3")
        }
        if (project) {
            filter += ' AND t.project_id = :project '
        }

        // SORTING
        final validSorts = [
                'id': 'id',
                'externalIdentfier': 'external_identfier',
                //'catalogNumber': 'catalog_number',
                'projectName': 'project_name',
                'dateTranscribed': 'date_transcribed',
                'dateValidated': 'date_fully_validated',
                //'validator': 'validator',
                'status': 'status'
        ].withDefault { 'date_transcribed' }
        def sortColumn = validSorts[sort]
        if (!'asc'.equalsIgnoreCase(order)) order = 'desc'

        final validatedStatus = i18nService.message(code: 'status.validated', default: 'Validated')
        final invalidatedStatus = i18nService.message(code: 'status.invalidated', default: 'In progress')
        final transcribedStatus = i18nService.message(code: 'status.transcribed', default: 'Transcribed')
        final savedStatus = i18nService.message(code: 'status.saved', default: 'Saved')

        log.debug("invalidated status: ${invalidatedStatus}")

        final statusSnippet = """
            CASE WHEN t.is_valid = true THEN '$validatedStatus'
                 WHEN t.is_valid = false THEN '$invalidatedStatus'
                WHEN t.is_fully_transcribed = true THEN '$transcribedStatus'
                ELSE '$savedStatus'
            END""".stripIndent()

        final querySnippet
        if (query) {
            querySnippet = """AND (
                p.name ilike '%' || :query || '%'
                OR t.id::VARCHAR = :query
                OR t.external_identifier ilike '%' || :query || '%'
                OR ($statusSnippet) = :query
                )""".stripIndent()
            // OR c.catalog_number @> ARRAY[ :query ]::text[]
            // OR (tu.first_name || ' ' || tu.last_name) ilike '%' || :query || '%'
            // OR (vu.first_name || ' ' || vu.last_name) ilike '%' || :query || '%'
        } else {
            querySnippet = ''
        }

        def distinctTaskClause = ""
        if (distinctTasks)  {
            distinctTaskClause = " DISTINCT ON (t.id) "
        }

        def withClause = "WITH \n${withClauses.join(',\n')}"
        def selectClause = """SELECT $distinctTaskClause
            t.id,
            t.created,
            t.external_identifier,
            t.external_url,
            t.fully_validated_by,
            t.project_id,
            p.institution_id,
            t.viewed,
            t.is_valid,
            t.date_fully_validated,
            t.date_last_updated,
            t.last_viewed,
            t.last_viewed_by,
            t.validateduuid,
            t.time_to_validate,
            t.number_of_matching_transcriptions,
            t.is_fully_transcribed,
            tr.fully_transcribed_by,
            tr.date_fully_transcribed,
            tr.fully_transcribed_ip_address,
            tr.transcribeduuid,
            tr.time_to_transcribe,
            p.name AS "project_name",
            $statusSnippet AS "status",
            $dateTranscribed AS "date_transcribed" """.stripIndent()
        // removed
        // c.catalog_number[1] AS "catalog_number",
        // (tu.first_name || ' ' || tu.last_name) AS "transcriber_display_name",
        // (vu.first_name || ' ' || vu.last_name) AS "validator_display_name",

        def countClause = "SELECT count(DISTINCT t.id)"

        def queryClause = """FROM transcription tr
            JOIN task t ON (t.id = tr.task_id)
            JOIN project p ON t.project_id = p.id
            $additionalJoins
            WHERE
            $filter
            $querySnippet
            """.stripIndent()

//        def pagingClause = """
//            ORDER BY $sortColumn $order;
//        """.stripIndent()
        def pagingClause = "ORDER BY "
        if (distinctTasks) {
            pagingClause += " t.id "
        } else {
            pagingClause += " ${sortColumn} ${order} "
        }

        def results = [:]
        final params = [userId: user.userId, project: project?.id, query: query]

        // remove $withClause
        def countQuery = """$countClause
            $queryClause
            """.stripIndent()

        log.debug("Count query:\n$countQuery")

        def rowsQuery = """
            $selectClause
            $queryClause
            $pagingClause
            """.stripIndent()
        // removed $withClause

        if (distinctTasks) {
            rowsQuery = """
                SELECT * 
                FROM (
                $rowsQuery
                ) pv
                ORDER BY $sortColumn $order
            """.stripIndent()
        }

        //log.debug("View list query:\n$rowsQuery")
        //log.debug("Params: $params")
        log.debug("Took ${sw.stop()} to generate queries")
        sw.reset().start()

        final sql = new Sql(dataSource)
        sql.withTransaction { Connection connection ->
            countQuery = countQuery.replaceAll(/\s+/, ' ')
            log.debug("Minified count query: $countQuery")
            results.totalMatchingTasks = sql.firstRow(params, countQuery).values()[0]
            log.debug("Took ${sw.stop()} to generate total count")

            sw.reset().start()
            rowsQuery = rowsQuery.replaceAll(/\s+/, ' ')
            log.debug("Minified view list query: $rowsQuery")
            log.debug("Max: $max, offset: $offset")

            // groovy sql requires offset to be different to SQL offset.
            results.viewList = sql.rows(rowsQuery, params, (offset ?: 0) + 1, max).collect { row ->
                [ id: row.id,
                  externalIdentifier: row.external_identifier,
                  isFullyTranscribed: row.is_fully_transcribed,
                  fullyTranscribedBy: row.fully_transcribed_by,
                  //fullyValidatedBy: row.validator_display_name,
                  projectId: row.project_id,
                  institutionId: row.institution_id,
                  projectName: row.project_name,
                  dateTranscribed: row.date_transcribed,
                  dateValidated: row.date_fully_validated,
                  //catalogNumber: row.catalog_number,
                  status: row.status
                ]
            }

            log.debug("Took ${sw.stop()} to generate view list")

            // add additional info for notifications tab
            if (selectedTab == 0 && results.viewList) {
                def ids = results.viewList.collect { it.id } as List<Integer>
                def unreadIds = getLastViewedBeforeValidation(project, user.userId, ids)

                results.viewList.each { it.unread = unreadIds.contains(it.id) }
            }
        }

        sql.close()

        return results
    }

    /**
     * Updates the properties of this Task that marks it as validated.
     * @param task The task being validated
     * @param userId the user who validated the task.
     * @param isValid true if the Task is considered valid.
     * @param validationDate the Date the task was validated (defaults to now)
     */
    void validate(Task task, String userId, boolean isValid, Date validationDate = new Date()) {
        if (!task || !userId) return
        if (!task.fullyValidatedBy) {
            task.fullyValidatedBy = userId
        }
        if (!task.dateFullyValidated) {
            task.dateFullyValidated = validationDate
        }
        if (!task.validatedUUID) {
            task.validatedUUID = UUID.randomUUID()
        }
        if (isValid) {
            task.isValid = true
        }
    }

    /**
     * Updates the last view timestamp of a task view (e.g. for Background saving a task).
     * @param viewedTask the task view to update
     * @param lastView the timestamp the task was last viewed.
     */
    void updateLastView(ViewedTask viewedTask, Long lastView) {
        if (!viewedTask) return
        viewedTask.lastView = lastView
        viewedTask.lastUpdated = new Date()
        viewedTask.save(flush: true, failOnError: true)
    }

    /**
     * Returns a map of user activity (views).
     * @return a Map of user activity grouped by User.
     */
    def getUserActivity() {
        def lastActivities = ViewedTask.executeQuery("select vt.userId, to_timestamp(max(vt.lastView)/1000) from ViewedTask vt group by vt.userId").collectEntries { [(it[0]): it[1]] }
        lastActivities
    }

    /**
     * Returns a map of user activity between two given dates.
     * @param startDate the start date
     * @param endDate the end date
     * @return a Map of user activity for a given date range.
     */
    def getUserActivityBetweenDates(Date startDate, Date endDate) {
        String query = """\
            select vt.userId, to_timestamp(min(vt.lastView)/1000), to_timestamp(max(vt.lastView)/1000)
            from ViewedTask vt
            where vt.lastView/1000 >= cast(extract(epoch FROM :startDate::timestamp) AS bigint)
              and vt.lastView/1000 <= cast(extract(epoch FROM :endDate::timestamp) AS bigint)
            group by vt.userId
        """.stripIndent()
        def userActivity = ViewedTask.executeQuery(query, [startDate: startDate, endDate: endDate])
                .collectEntries { [(it[0]): it[1]] }
        userActivity
    }

    /**
     * Returns a Map of transcription counts grouped by user (Transcription.fullyTranscribedBy).
     * @return a Map of transcription counts grouped by user
     */
    def getProjectTranscriptionCounts() {
        def projectCounts = Transcription.executeQuery("select t.fullyTranscribedBy, count(distinct t.project) from Transcription t where t.fullyTranscribedBy is not null group by t.fullyTranscribedBy").collectEntries { [(it[0]): it[1]] }
        projectCounts
    }

    /**
     * Returns true if all of the required number of Transcriptions have been completed for this Task.
     * The default is one Transcription per Task, but this can be overridden in the project template.
     * @param task the task that is being checked
     * @return true if all transcriptions are completed, false if not.
     */
    boolean allTranscriptionsComplete(Task task) {
        if (!task) return false
        if (task.isFullyTranscribed) {
            return true
        }

        // Check if project/template supports multiple transcriptions. If not and somehow got past above, return true
        // If true, check transcription thresholds.
        def supportsMultiTx = projectService.doesTemplateSupportMultiTranscriptions(task.project)
        if (supportsMultiTx) {
            int requiredTranscriptionCount = task.project.requiredNumberOfTranscriptions
            int transcriptionCount = (int) (task.transcriptions?.count { it.fullyTranscribedBy } ?: 0)
            log.debug("Transcription count: ${transcriptionCount}, required transcription count: ${requiredTranscriptionCount}")
            log.debug("transcriptionCount >= requiredTranscriptionCount: ${transcriptionCount >= requiredTranscriptionCount}")
            return transcriptionCount >= requiredTranscriptionCount
        } else {
            return true
        }
    }

    /**
     * This method is called by the Quartz scheduler to process finished tasks.
     * It checks if all transcriptions are complete and updates the task status accordingly.
     */
    def processFinishedTasks() {
        def timeBufferInMinutes = 15
        def timeBuffer = Date.from(LocalDateTime.now().minusMinutes(timeBufferInMinutes).atZone(ZoneId.systemDefault()).toInstant())
        def updatedTaskIds = Transcription.createCriteria().list {
            gt('dateFullyTranscribed', timeBuffer)
            projections {
                distinct('task.id')
            }
        }

        log.debug("Processing finished tasks, found [${updatedTaskIds.size()}] tasks with recently updated transcriptions")
        updatedTaskIds.each { id ->
            log.debug("Processing task id: ${id}")
            def task = Task.get(id as long)
            if (task && !task.isFullyTranscribed && allTranscriptionsComplete(task)) {
                log.debug("Task ${task.id} set to fully transcribed")
                task.isFullyTranscribed = true
                task.save(failOnError: true, flush: true)
            }
        }
    }
}
