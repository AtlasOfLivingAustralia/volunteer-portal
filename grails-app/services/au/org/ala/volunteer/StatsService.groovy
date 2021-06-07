package au.org.ala.volunteer

import com.google.common.base.Stopwatch
import grails.gorm.transactions.Transactional
import groovy.sql.Sql

import javax.sql.DataSource

@Transactional
class StatsService {

    def grailsApplication
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
            month++;
            if (month > 12) {
                month = 1
                year++
            }

        }

        return results.sort { it.month }.collect { [c : [ [v: it.month], [v: it.count] ] ] }

    }

    def getNewUser(Date startDate, Date endDate) {
        String select ="""
SELECT COUNT(user_id) FROM (
   SELECT v.user_id
   FROM vp_user v
   WHERE v.created >= :startDate
     AND v.created <= :endDate
     AND EXISTS(SELECT 1
                FROM task t
                WHERE t.fully_transcribed_by = v.user_id OR t.fully_validated_by = v.user_id
                LIMIT 1)
   UNION DISTINCT
   SELECT v.user_id
   FROM vp_user v
   WHERE v.created >= :startDate
     AND v.created <= :endDate
     AND EXISTS(SELECT 1
                FROM transcription t
                WHERE t.fully_transcribed_by = v.user_id OR t.fully_validated_by = v.user_id
                LIMIT 1)
) AS new_users;
        """.stripIndent()

        def selectAllUsers = """
SELECT COUNT(user_id) FROM (
   SELECT v.user_id
   FROM vp_user v
   WHERE EXISTS(SELECT 1
                FROM task t
                WHERE t.fully_transcribed_by = v.user_id OR t.fully_validated_by = v.user_id
                LIMIT 1)
   UNION DISTINCT
   SELECT v.user_id
   FROM vp_user v
   WHERE EXISTS(SELECT 1
                FROM transcription t
                WHERE t.fully_transcribed_by = v.user_id OR t.fully_validated_by = v.user_id
                LIMIT 1)
) AS total_users;
""".stripIndent()
        def selectCached = """
SELECT
    SUM(CASE WHEN v.created >= :startDate AND v.created <= :endDate THEN 1 ELSE 0 END) as newVolunteers,
    COUNT(v.id) as totalVolunteers
FROM vp_user v
WHERE v.transcribed_count + v.validated_count > 0;
""".stripIndent()

        Sql sql = new Sql(dataSource)
        def sw = Stopwatch.createStarted()
        def newVolunteers = sql.firstRow(select, [startDate: startDate.toTimestamp(), endDate: endDate.toTimestamp()])
        log.debug("Took {} to count new volunteers for date range {} -> {}", sw, startDate, endDate)
        sw.reset().start()
        def totalVolunteers = sql.firstRow(selectAllUsers)
        log.debug("Took {} to count all volunteers", sw)
        sw.reset().start()
        def volunteerScores = sql.firstRow(selectCached, [startDate: startDate.toTimestamp(), endDate: endDate.toTimestamp()])
        log.debug("Took {} to get cached volunteer counts", sw)

        return [newVolunteers: newVolunteers['count'], totalVolunteers: totalVolunteers['count'], cachedNewVolunteers: volunteerScores['newVolunteers'], cachedTotalVolunteers: volunteerScores['totalVolunteers']]
    }

    def getActiveTasks(Date startDate, Date endDate) {

        String select ="""
            WITH task_count AS (
              SELECT fully_transcribed_by as user_id, count(*) as count
              FROM transcription
              WHERE
                date_fully_transcribed BETWEEN :startDate AND :endDate
               GROUP BY fully_transcribed_by
               )
            SELECT u.user_id, u.first_name || ' ' || u.last_name AS display_name, t.count
            FROM   vp_user u JOIN task_count t ON u.user_id = t.user_id
            ORDER BY count DESC;
        """

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(select, [startDate: startDate.toTimestamp(), endDate: endDate.toTimestamp()]) { row ->
            def transcriberTask = [row.display_name, row.count ]
            results.add(transcriberTask)
        }

        return results
    }

    def getTasksGroupByVolunteerAndProject (Date startDate, Date endDate) {

        String select ="""
            WITH task_count AS (
              SELECT t.fully_transcribed_by as user_id, p.id as project_id, count(*) as count
              FROM transcription t JOIN project p on t.project_id = p.id
              WHERE
                t.date_fully_transcribed BETWEEN :startDate AND :endDate
               GROUP BY t.fully_transcribed_by, p.id
               )
            SELECT u.user_id, u.first_name || ' ' || u.last_name AS display_name, p.name as name, t.count
            FROM   vp_user u JOIN task_count t ON u.user_id = t.user_id JOIN project p ON t.project_id = p.id
            ORDER BY count DESC;
        """

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(select, [startDate: startDate.toTimestamp(), endDate: endDate.toTimestamp()]) { row ->
            def transcriberTask = [row.display_name, row.name, row.count ]
            results.add(transcriberTask)
        }

        return results
    }

    def getTranscriptionsByDay(Date startDate, Date endDate) {

        String select ="""
                        SELECT DISTINCT transcribeDate as day,
                            count(tmp.transcribeDate) as taskCount,
                            MAX(transcribeDay),
                            MAX(transcribeMonth)
            FROM ( SELECT to_char(date_fully_transcribed, 'DD') as transcribeDay,
                          to_char(date_fully_transcribed, 'MM') as transcribeMonth,
                          to_char(date_fully_transcribed, 'DD/MM') as transcribeDate
                   FROM transcription
                   WHERE date_fully_transcribed is not null
                   AND  date_fully_transcribed >= :startDate
                   AND  transcription.date_fully_transcribed <= :endDate ) as tmp
            group by transcribeDate
            ORDER BY MAX(transcribeMonth), MAX(transcribeDay)
        """

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(select, [startDate: startDate.toTimestamp(), endDate: endDate.toTimestamp()]) { row ->
            def taskByDay = [row.day, row.taskCount ]
            results.add(taskByDay)
        }

        return results
    }

    def getValidationsByDay(Date startDate, Date endDate) {

        String select ="""
            SELECT DISTINCT tmp.validateDate as day,
                            count(tmp.validateDate) as taskCount,
                            max(validateDay),
                            max(validateMonth)
            FROM ( SELECT to_char(date_fully_validated, 'DD/MM') as validateDate,
                          to_char(date_fully_validated, 'DD') as validateDay,
                          to_char(date_fully_validated, 'MM') as validateMonth
                   FROM task
                   WHERE date_fully_validated is not null
                   AND  date_fully_validated >= :startDate
                   AND  task.date_fully_validated <= :endDate ) as tmp
            group by validateDate
            order by max(validateMonth), max(validateDay)
        """

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(select, [startDate: startDate.toTimestamp(), endDate: endDate.toTimestamp()]) { row ->
            def taskByDay = [row.day, row.taskCount ]
            results.add(taskByDay)
        }

        return results
    }

    def getTranscriptionsByInstitution() {

        String select ="""
            SELECT project.featured_owner featured_owner, count(transcription.id) as task_count
            FROM transcription JOIN project ON transcription.project_id = project.id
            WHERE transcription.fully_transcribed_by is NOT null
            GROUP BY project.featured_owner
            ORDER BY task_count DESC;
        """

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(select) { row ->
            def taskByInstitution = [row.featured_owner, row.task_count ]
            results.add(taskByInstitution)
        }

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
            ORDER BY 1, 2
""".stripIndent()

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

        return results
    }

    def getHourlyContributions(Date startDate, Date endDate) {

        String select = """
            SELECT  trim(leading ' ' from to_char(date_part('hour', updated)::numeric(4,2), '00D99')) as hour,
                    round(count(*)/MAX(total)::numeric(10,2) * 100, 2) as contribution
            FROM field,
                 (SELECT count (*) as total
                  FROM  field
                  WHERE updated >= :startDate
                  AND   updated <= :endDate) as allContributions
            WHERE  updated >= :startDate
            AND updated <= :endDate
            GROUP BY date_part('hour', updated)
            ORDER BY date_part('hour', updated)
        """

        def results = []

        def sql = new Sql(dataSource)
        sql.eachRow(select, [startDate: startDate.toTimestamp(), endDate: endDate.toTimestamp()]) { row ->
            def validationsByInstitution = [row.hour, row.contribution ]
            results.add(validationsByInstitution)
        }

        return results
    }

    def getTranscriptionTimeByProjectType(Date startDate, Date endDate) {
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
GROUP BY ROLLUP (p.project_type_id);
"""
        def results = []
        def sql = new Sql(dataSource)
        sql.eachRow(select, [startDate: startDate.toTimestamp(), endDate: endDate.toTimestamp()]) { row ->
            def transcriptionTimesByProjectType = [row.label, row.avg]
            results.add(transcriptionTimesByProjectType)
        }

        return results
    }
}
