package au.org.ala.volunteer

import groovy.sql.Sql
import java.nio.channels.CancelledKeyException

class StatsService {

    static transactional = true

    def grailsApplication
    javax.sql.DataSource dataSource

    def transcriptionsByMonth() {
        String select = """
            select distinct foo.updateDate as month, count(foo.task_id) as transcribedTasks from (
                select task_id, to_char(max(updated), 'YYYY/MM') as updateDate, t.project_id as projectId from field f JOIN task t on f.task_id = t.id
                where t.fully_transcribed_by is not null
                group by task_id, t.project_id
            ) as foo join project p on foo.projectId = p.id
            group by foo.updateDate
            order by foo.updateDate
        """

        def results = []

        def sql = new Sql(dataSource: dataSource)
        sql.eachRow(select) { row ->
            def taskRow = [month: row.month, count: row.transcribedTasks ]
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

        return results.sort { it.month };

    }
}
