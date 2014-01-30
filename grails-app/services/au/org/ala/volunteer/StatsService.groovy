package au.org.ala.volunteer

import groovy.sql.Sql
import java.nio.channels.CancelledKeyException

class StatsService {

    static transactional = true

    def grailsApplication
    javax.sql.DataSource dataSource

    def transcriptionsByMonth() {

        String query = """
            select distinct tmp.transcribeDate as month, count(tmp.transcribeDate) as taskCount from (
                select to_char(date_fully_transcribed, 'YYYY/MM') as transcribeDate
                from task
                where date_fully_transcribed is not null
            ) as tmp
            group by transcribeDate
            order by transcribeDate
        """

        return prepareByMonthResults(query)
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

        return prepareByMonthResults(query)
    }

    private prepareByMonthResults(String query) {

        def results = []

        def sql = new Sql(dataSource: dataSource)
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

        return results.sort { it.month };

    }
}
