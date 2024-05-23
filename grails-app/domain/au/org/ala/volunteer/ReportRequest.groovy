package au.org.ala.volunteer

import net.kaleidos.hibernate.usertype.JsonbMapType

class ReportRequest {

    long id
    Date dateCreated
    String reportName
    Date dateCompleted
    Map reportParams

    static belongsTo = [requestUser: User]

    static mapping = {
        requestUser index: 'report_queue_id_fk'
        reportParams type: JsonbMapType
    }

    static constraints = {
        dateCreated nullable: false
        dateCompleted nullable: true
        reportParams nullable: true
    }

    @Override
    String toString() {
        final output = """\
            ReportRequest: {
                id: [${id}],
                dateCreated: [${dateCreated}],
                requestUser: [${requestUser.displayName}],
                reportName: [${reportName}],
                dateCompleted: [${dateCompleted}]
            }
        """.stripIndent()
        return output
    }

    String printReportParams() {
        final output = """\
            ReportRequest: {
                id: [${id}],
                reportName: [${reportName}],
                dateCreated: [${dateCreated}],
                reportParams: ${reportParams}
            }
        """.stripIndent()
        return output
    }
}
