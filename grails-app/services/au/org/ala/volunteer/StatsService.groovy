package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.gorm.transactions.Transactional
import grails.plugin.cache.Cacheable
import groovy.sql.Sql

import javax.sql.DataSource

@Transactional
class StatsService {

    def userService
    DataSource dataSource

    def transcriptionsByMonth() {

        String query = """
            select distinct tmp.transcribeDate as month, count(tmp.transcribeDate) as taskCount from (
                select to_char(date_fully_transcribed, 'YYYY/MM') as transcribeDate
                from transcription
                where date_fully_transcribed is not null
            ) as tmp
            group by transcribeDate
            order by transcribeDate
        """

        return [
                cols: [
                        [id: 'transcriptions', label: 'Transcriptions', type: 'string' ],
                        [id: 'count', label: 'Count', type: 'number' ]
                ],
                rows: prepareByMonthResults(query)
        ]
    }

    def validationsByMonth() {

        String query = """
            select distinct tmp.validateDate as month, count(tmp.validateDate) as taskCount from (
                select to_char(date_fully_validated, 'YYYY/MM') as validateDate
                from task
                where date_fully_validated is not null
            ) as tmp
            group by validateDate
            order by validateDate
        """

        return [
                cols: [
                        [id: 'validations', label: 'Validations', type: 'string' ],
                        [id: 'count', label: 'Count', type: 'number' ]
                ],
                rows: prepareByMonthResults(query)
        ]
    }

    private prepareByMonthResults(String query) {

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(query) { row ->
            def taskRow = [month: row.month, count: row.taskCount ]
            results.add(taskRow)
        }

        int month = 7
        int year = 2010

        def now = Calendar.instance

        while (year < now.get(Calendar.YEAR) || (year == now.get(Calendar.YEAR) && month <= now.get(Calendar.MONTH) + 1)) {
            def key = "${year}/" + String.format("%02d", month)
            def x = results.find {
                it.month == key
            }
            if (!x) {
                results.add([month:key, count: 0])
            }
            month++
            if (month > 12) {
                month = 1
                year++
            }

        }

        sql.close()
        return results.sort { it.month }.collect { [c : [ [v: it.month], [v: it.count] ] ] }
    }

    def getNewUser(Date startDate, Date endDate, Institution institution) {
        def institutionClause = ""
        def projectJoin = ""
        def params = [:]

        if (institution) {
            projectJoin = "JOIN project p ON (p.id = t.project_id) "
            institutionClause = "AND p.institution_id = :institutionId "
            params.institutionId = institution?.id
        } else {
            // If Institution Admin, select from all institutions they admin for.
            if (!userService.isSiteAdmin() && userService.isInstitutionAdmin()) {
                projectJoin = "JOIN project p ON (p.id = t.project_id) "
                institutionClause = "AND p.institution_id in (:institutionList)"
                def institutionParams = userService.getAdminInstitutionList()*.id
                institutionClause = institutionClause.replace(':institutionList', institutionParams.join(","))
            }
        }

        String newUsersQuery = """
            SELECT COUNT(user_id) FROM (
               SELECT v.user_id
               FROM vp_user v
               WHERE v.created >= :startDate
                 AND v.created <= :endDate
                 AND EXISTS(SELECT 1
                            FROM task t
                            ${projectJoin}
                            WHERE (t.fully_transcribed_by = v.user_id OR t.fully_validated_by = v.user_id)
                            ${institutionClause}
                            LIMIT 1)
               UNION DISTINCT
               SELECT v.user_id
               FROM vp_user v
               WHERE v.created >= :startDate
                 AND v.created <= :endDate
                 AND EXISTS(SELECT 1
                            FROM transcription t
                            ${projectJoin}
                            WHERE (t.fully_transcribed_by = v.user_id OR t.fully_validated_by = v.user_id)
                            ${institutionClause}
                            LIMIT 1)
            ) AS new_users; """.stripIndent()

        def selectAllUsers = """
            SELECT COUNT(user_id) FROM (
               SELECT v.user_id
               FROM vp_user v
               WHERE EXISTS(SELECT 1
                            FROM task t
                            ${projectJoin}
                            WHERE (t.fully_transcribed_by = v.user_id OR t.fully_validated_by = v.user_id)
                            ${institutionClause}
                            LIMIT 1)
               UNION DISTINCT
               SELECT v.user_id
               FROM vp_user v
               WHERE EXISTS(SELECT 1
                            FROM transcription t
                            ${projectJoin}
                            WHERE (t.fully_transcribed_by = v.user_id OR t.fully_validated_by = v.user_id)
                            ${institutionClause}
                            LIMIT 1)
            ) AS total_users; """.stripIndent()

        def selectCached = """
            SELECT
                SUM(CASE WHEN v.created >= :startDate AND v.created <= :endDate THEN 1 ELSE 0 END) as newVolunteers,
                COUNT(v.id) as totalVolunteers
            FROM vp_user v
            WHERE v.transcribed_count + v.validated_count > 0; """.stripIndent()

        Sql sql = new Sql(dataSource)
        def sw = Stopwatch.createStarted()

        params.startDate = startDate.toTimestamp()
        params.endDate = endDate.toTimestamp()

        def newVolunteers = sql.firstRow(newUsersQuery, params)
        log.debug("Took ${sw} to count new volunteers for date range ${startDate} -> ${endDate}")
        sw.reset().start()

        def totalVolunteers = [:]
        if (institution) {
            totalVolunteers = sql.firstRow(selectAllUsers, params)
            log.debug("Took ${sw} to count all volunteers")
            sw.reset().start()
        } else if (!institution && !userService.isSiteAdmin()) {
            // All institutions
            totalVolunteers = sql.firstRow(selectAllUsers)
            log.debug("Took ${sw} to count all volunteers")
            sw.reset().start()
        }

        def volunteerScores = sql.firstRow(selectCached, params)
        log.debug("Took ${sw} to get cached volunteer counts")

        sql.close()
        return [newVolunteers: newVolunteers['count'],
                totalVolunteers: totalVolunteers['count'],
                cachedNewVolunteers: volunteerScores['newVolunteers'],
                cachedTotalVolunteers: volunteerScores['totalVolunteers']]
    }

    def getInstitutionRawData(Institution institution) {
        String query = """
            SELECT
                institution.id                                                           AS institution_id,
                institution.name                                                         AS institution_name,
                project.id                                                               AS project_id,
                project.name                                                             AS project_name,
                task.id                                                                  AS task_id,
                concat('https://volunteer.ala.org.au/task/showDetails/', task.id)        AS external_url,
                CASE
                    WHEN task.is_valid = true     THEN 'valid'
                    WHEN task.is_valid = false    THEN 'invalid'
                    WHEN task.is_valid IS NULL THEN ''
                END                                                                      AS validation_status,
                concat(u1.first_name, ' ', u1.last_name)                                 AS transcriber_id,
                concat(u2.first_name, ' ', u2.last_name)                                 AS validator_id,
                task.external_identifier,
                concat(
                    CASE
                        WHEN task.fully_validated_by IS NOT NULL
                             AND transcription.fully_transcribed_by IS NOT NULL THEN
                            CASE WHEN task.fully_validated_by = 'system' THEN
                                concat('Auto-validated by DigiVol. ')
                             ELSE 
                                concat('Validated by ', u2.first_name, ' ', u2.last_name, '. ')
                             END
                        WHEN task.fully_validated_by IS NULL
                             AND transcription.fully_transcribed_by IS NOT NULL THEN
                            concat('Fully Transcribed by ', u1.first_name, ' ', u1.last_name, '. ')
                    END,
                    'Exported on ',
                    to_char(current_timestamp, 'DD Mon YYYY HH24:MI:SS TZ'),
                    ' from DigiVol.')                                                 AS export_comment,
                transcription.date_fully_transcribed                                     AS date_transcribed,
                task.date_fully_validated                                                AS date_validated
            FROM
                task
                JOIN project ON ( project.id = task.project_id )
                JOIN institution ON ( institution.id = project.institution_id )
                LEFT JOIN transcription ON ( transcription.task_id = task.id )
                LEFT JOIN vp_user  u1 ON ( u1.user_id = transcription.fully_transcribed_by )
                LEFT JOIN vp_user  u2 ON ( u2.user_id = task.fully_validated_by )
            WHERE
                project.institution_id IN (
                    SELECT id
                    FROM institution
                    WHERE id = :institutionId) """.stripIndent()

        if (!institution) return []
        def params = [institutionId: institution.id]
        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(query, params) { row ->
            def taskRow = [row.institution_id,
                           row.institution_name,
                           row.project_id,
                           row.project_name,
                           row.task_id,
                           row.external_url,
                           row.validation_status,
                           row.transcriber_id,
                           row.validator_id,
                           row.export_comment,
                           row.date_transcribed,
                           row.date_validated]
            results.add(taskRow)
        }

        sql.close()
        return results
    }

    def getActiveTasks(Date startDate, Date endDate, Institution institution) {
        def institutionClause = ""
        def projectClause = ""
        def params = [:]

        if (institution) {
            projectClause = "JOIN project p ON (p.id = transcription.project_id) "
            institutionClause = "AND p.institution_id = :institutionId "
            params.institutionId = institution?.id
        } else {
            // If Institution Admin, select from all institutions they admin for.
            if (!userService.isSiteAdmin() && userService.isInstitutionAdmin()) {
                projectClause = "JOIN project p ON (p.id = transcription.project_id) "
                institutionClause = "AND p.institution_id in (:institutionList)"
                def institutionParams = userService.getAdminInstitutionList()*.id
                institutionClause = institutionClause.replace(':institutionList', institutionParams.join(","))
            }
        }

        String select = """
            WITH task_count AS (
                SELECT fully_transcribed_by as user_id, count(*) as count
                FROM transcription
                ${projectClause}
                WHERE date_fully_transcribed BETWEEN :startDate AND :endDate
                ${institutionClause}
                GROUP BY fully_transcribed_by)
            SELECT u.user_id, u.first_name || ' ' || u.last_name AS display_name, t.count
            FROM   vp_user u 
            JOIN task_count t ON u.user_id = t.user_id
            ORDER BY count DESC; """.stripIndent()

        def results = []
        params.startDate = startDate.toTimestamp()
        params.endDate = endDate.toTimestamp()

        def sql = new Sql(dataSource)
        sql.eachRow(select, params) { row ->
            def transcriberTask = [row.display_name, row.count]
            results.add(transcriberTask)
        }
        sql.close()

        return results
    }

    def getTasksGroupByVolunteerAndProject (Date startDate, Date endDate, Institution institution) {
//        def institutionClause = ""
//        def institutionParams
//        if (!userService.isSiteAdmin() && userService.isInstitutionAdmin()) {
//            institutionClause = "AND p.institution_id in (:institutionList)"
//            institutionParams = userService.getAdminInstitutionList()*.id
//            institutionClause = institutionClause.replace(':institutionList', institutionParams.join(","))
//            log.debug("Loading institution clause parameters: ${institutionParams}")
//        }
        def institutionClause = ""
        def params = [:]

        if (institution) {
            institutionClause = "AND p.institution_id = :institutionId "
            params.institutionId = institution?.id
        } else {
            // If Institution Admin, select from all institutions they admin for.
            if (!userService.isSiteAdmin() && userService.isInstitutionAdmin()) {
                institutionClause = "AND p.institution_id in (:institutionList)"
                def institutionParams = userService.getAdminInstitutionList()*.id
                institutionClause = institutionClause.replace(':institutionList', institutionParams.join(","))
            }
        }

        String select = """
            WITH task_count AS (
              SELECT t.fully_transcribed_by as user_id, p.id as project_id, count(*) as count
              FROM transcription t JOIN project p on t.project_id = p.id
              WHERE
                t.date_fully_transcribed BETWEEN :startDate AND :endDate
                ${institutionClause}
               GROUP BY t.fully_transcribed_by, p.id
               )
            SELECT u.user_id, u.first_name || ' ' || u.last_name AS display_name, p.name as name, t.count
            FROM   vp_user u JOIN task_count t ON u.user_id = t.user_id JOIN project p ON t.project_id = p.id
            ORDER BY count DESC; """.stripIndent()

        def results = []
        params.startDate = startDate.toTimestamp()
        params.endDate = endDate.toTimestamp()

        def sql = new Sql(dataSource)
        sql.eachRow(select, params) { row ->
            def transcriberTask = [row.display_name, row.name, row.count ]
            results.add(transcriberTask)
        }
        sql.close()

        return results
    }

    def getTranscriptionsByDay(Date startDate, Date endDate, Institution institution) {
        def institutionClause = ""
        def projectClause = ""
        def params = [:]

        if (institution) {
            projectClause = "JOIN project p ON (p.id = transcription.project_id) "
            institutionClause = "AND p.institution_id = :institutionId "
            params.institutionId = institution?.id
        } else {
            // If Institution Admin, select from all institutions they admin for.
            if (!userService.isSiteAdmin() && userService.isInstitutionAdmin()) {
                projectClause = "JOIN project p ON (p.id = transcription.project_id) "
                institutionClause = "AND p.institution_id in (:institutionList)"
                def institutionParams = userService.getAdminInstitutionList()*.id
                institutionClause = institutionClause.replace(':institutionList', institutionParams.join(","))
            }
        }

        String select = """
            SELECT DISTINCT transcribeDate as day,
                count(tmp.transcribeDate) as taskCount,
                MAX(transcribeDay),
                MAX(transcribeMonth),
                MAX(transcribeYear)
            FROM ( SELECT to_char(date_fully_transcribed, 'DD') as transcribeDay,
                          to_char(date_fully_transcribed, 'MM') as transcribeMonth,
                          to_char(date_fully_transcribed, 'DD/MM') as transcribeDate,
                          to_char(date_fully_transcribed, 'YYYY') as transcribeYear
                   FROM transcription
                   ${projectClause}
                   WHERE date_fully_transcribed is not null
                   ${institutionClause}
                   AND  date_fully_transcribed >= :startDate
                   AND  transcription.date_fully_transcribed <= :endDate ) as tmp
            group by transcribeDate
            ORDER BY MAX(transcribeYear), MAX(transcribeMonth), MAX(transcribeDay) """.stripIndent()

        def results = []
        params.startDate = startDate.toTimestamp()
        params.endDate = endDate.toTimestamp()

        def sql = new Sql(dataSource)
        sql.eachRow(select, params) { row ->
            def taskByDay = [row.day, row.taskCount ]
            results.add(taskByDay)
        }
        sql.close()

        return results
    }

    def getValidationsByDay(Date startDate, Date endDate, Institution institution) {
        def institutionClause = ""
        def projectClause = ""
        def params = [:]

        if (institution) {
            projectClause = "join project p on p.id = task.project_id "
            institutionClause = "AND p.institution_id = :institutionId "
            params.institutionId = institution?.id
        } else {
            // If Institution Admin, select from all institutions they admin for.
            if (!userService.isSiteAdmin() && userService.isInstitutionAdmin()) {
                projectClause = "join project p on p.id = task.project_id "
                institutionClause = "AND p.institution_id in (:institutionList)"
                def institutionParams = userService.getAdminInstitutionList()*.id
                institutionClause = institutionClause.replace(':institutionList', institutionParams.join(","))
            }
        }

        String select = """
            SELECT DISTINCT tmp.validateDate as day,
                            count(tmp.validateDate) as taskCount,
                            max(validateDay),
                            max(validateMonth),
                            MAX(validateYear)
            FROM ( SELECT to_char(date_fully_validated, 'DD/MM') as validateDate,
                          to_char(date_fully_validated, 'DD') as validateDay,
                          to_char(date_fully_validated, 'MM') as validateMonth,
                          to_char(date_fully_validated, 'YYYY') as validateYear
                   FROM task
                   ${projectClause}
                   WHERE date_fully_validated is not null
                   ${institutionClause}
                   AND  date_fully_validated >= :startDate
                   AND  task.date_fully_validated <= :endDate ) as tmp
            group by validateDate
            order by MAX(validateYear), max(validateMonth), max(validateDay) """.stripIndent()

        def results = []
        params.startDate = startDate.toTimestamp()
        params.endDate = endDate.toTimestamp()

        def sql = new Sql(dataSource)
        sql.eachRow(select, params) { row ->
            def taskByDay = [row.day, row.taskCount ]
            results.add(taskByDay)
        }
        sql.close()

        return results
    }

    def getTranscriptionsByInstitution() {

        String select = """
            SELECT project.featured_owner featured_owner, count(transcription.id) as task_count
            FROM transcription JOIN project ON transcription.project_id = project.id
            WHERE transcription.fully_transcribed_by is NOT null
            GROUP BY project.featured_owner
            ORDER BY task_count DESC; """.stripIndent()

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(select) { row ->
            def taskByInstitution = [row.featured_owner, row.task_count ]
            results.add(taskByInstitution)
        }
        sql.close()

        return results
    }

    def getTranscriptionsByInstitutionByMonth() {
        String select = """
            SELECT
                p.featured_owner featured_owner,
                extract(year from date_fully_transcribed::timestamptz AT TIME ZONE 'UTC') || '-' || LPAD(extract(month from date_fully_transcribed::timestamptz AT TIME ZONE 'UTC')::text, 2, '0') as month,
                count(t.id) as task_count
            FROM transcription t JOIN project p on t.project_id = p.id
            WHERE t.fully_transcribed_by is NOT NULL
            GROUP BY month, p.featured_owner
            ORDER BY 1, 2 """.stripIndent()

        Set<String> columnSet = new HashSet<String>()

        def sql = new Sql(dataSource)
        def rows = sql.rows(select)
        rows.forEach { row ->
            columnSet.add(row.month)
        }
        def columns = columnSet.sort().reverse()
        def data = rows
                .groupBy { it.featured_owner }
                .collectEntries { [ (it.key) : it.value.collectEntries { [ (it.month): it.task_count ] } ] }
                .collect { row ->
                    [row.key] + columns.collect { row.value[it] ?: 0 }
                }

        def header = [[ id: 'institution', label: 'Institution', type: 'string' ]] + columns.collect { [ id: it, label: it, type: 'number']}
        sql.close()

        return [header: header, statsData: data]
    }

    def getValidationsByInstitution() {

        String select ="""
            SELECT project.featured_owner featured_owner, count(task.id) as task_count
            FROM task JOIN project ON task.project_id = project.id
            WHERE task.fully_validated_by is NOT null
            GROUP BY project.featured_owner
            ORDER BY task_count DESC;
        """

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(select) { row ->
            def validationsByInstitution = [row.featured_owner, row.task_count ]
            results.add(validationsByInstitution)
        }
        sql.close()

        return results
    }

    @Cacheable(value = 'StatsHourlyContribution', key = { "${institution?.id?.toString() ?: '-1'}-${startDate?.getTime() ?: '-1'}-${endDate?.getTime() ?: '-1'}" })
    def getHourlyContributions(Date startDate, Date endDate, Institution institution) {
        def taskView = ""
        def taskJoin = ""
        def taskViewName = ""
        def taskViewClause = ""
        def institutionParams
        def params = [:]

        if (institution) {
            taskView = """
                    WITH task_count AS (
                        select t.id as task_id
                        from task t
                        join project p on t.project_id = p.id
                        where p.institution_id = :institutionId
                    ) """.stripIndent()
            taskJoin = "join task_count on (field.task_id = task_count.task_id) "
            taskViewName = ", task_count "
            taskViewClause = "and field.task_id = task_count.task_id "
            params.institutionId = institution?.id
        } else {
            // If Institution Admin, select from all institutions they admin for.
            if (!userService.isSiteAdmin() && userService.isInstitutionAdmin()) {
                taskView = """
                    WITH task_count AS (
                        select t.id as task_id
                        from task t
                        join project p on t.project_id = p.id
                        where p.institution_id in (:institutionList)
                    ) """.stripIndent()
                taskJoin = "join task_count on (field.task_id = task_count.task_id) "
                taskViewName = ", task_count "
                taskViewClause = "and field.task_id = task_count.task_id "
                institutionParams = userService.getAdminInstitutionList()*.id
                taskView = taskView.replace(':institutionList', institutionParams.join(","))
                log.debug("Loading institution clause parameters: ${institutionParams}")
            }
        }

        String select = """
            ${taskView}
            SELECT trim(leading ' ' from to_char(date_part('hour', updated)::numeric(4,2), '00D99')) as hour,
                   round(count(*)/MAX(total)::numeric(10,2) * 100, 2) as contribution
            FROM field,
                 (SELECT count (*) as total
                  FROM  field
                  ${taskJoin}
                  WHERE updated >= :startDate
                  AND   updated <= :endDate) as allContributions
                  ${taskViewName}
            WHERE  updated >= :startDate
            AND updated <= :endDate
            ${taskViewClause}
            GROUP BY date_part('hour', updated)
            ORDER BY date_part('hour', updated) """.stripIndent()

        def results = []
        params.startDate = startDate.toTimestamp()
        params.endDate = endDate.toTimestamp()

        def sql = new Sql(dataSource)
        sql.eachRow(select, params) { row ->
            def validationsByInstitution = [row.hour, row.contribution ]
            results.add(validationsByInstitution)
        }
        sql.close()

        return results
    }

    @Cacheable(value = 'StatsTranscriptionTime', key = { "${institution?.id?.toString() ?: '-1'}-${startDate?.getTime() ?: '-1'}-${endDate?.getTime() ?: '-1'}" })
    def getTranscriptionTimeByProjectType(Date startDate, Date endDate, Institution institution) {
        def institutionClause = ""
        def params = [:]

        if (institution) {
            institutionClause = "AND p.institution_id = :institutionId "
            params.institutionId = institution?.id
        } else {
            // If Institution Admin, select from all institutions they admin for.
            if (!userService.isSiteAdmin() && userService.isInstitutionAdmin()) {
                institutionClause = "AND p.institution_id in (:institutionList)"
                def institutionParams = userService.getAdminInstitutionList()*.id
                institutionClause = institutionClause.replace(':institutionList', institutionParams.join(","))
            }
        }

        String select = """
            SELECT
                CASE
                    WHEN p.project_type_id is null THEN 'Total'
                    ELSE (SELECT pt.label FROM project_type pt WHERE pt.id = p.project_type_id)
                END AS label,
                p.project_type_id,
                AVG(t.time_to_transcribe)
            FROM
                transcription t
                JOIN project p on t.project_id = p.id
            WHERE
              t.time_to_transcribe IS NOT null
              AND t.date_fully_transcribed BETWEEN :startDate AND :endDate
              ${institutionClause}
            GROUP BY ROLLUP (p.project_type_id); """.stripIndent()

        def results = []
        params.startDate = startDate.toTimestamp()
        params.endDate = endDate.toTimestamp()

        def sql = new Sql(dataSource)
        sql.eachRow(select, params) { row ->
            def transcriptionTimesByProjectType = [row.label, row.avg]
            results.add(transcriptionTimesByProjectType)
        }
        sql.close()

        return results
    }
}
