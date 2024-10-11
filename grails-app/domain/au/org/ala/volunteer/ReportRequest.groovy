package au.org.ala.volunteer

import net.kaleidos.hibernate.usertype.JsonbMapType

class ReportRequest {

    long id
    Date dateCreated
    String reportName
    Date dateCompleted
    Date dateArchived
    Map reportParams

    static belongsTo = [requestUser: User]

    static mapping = {
        requestUser index: 'report_queue_id_fk'
        reportParams type: JsonbMapType
    }

    static constraints = {
        dateCreated nullable: false
        dateCompleted nullable: true
        dateArchived nullable: true
        reportParams nullable: true
    }

    /**
     * Returns the current status of the report.
     * @return One of three values depending on the status: Archived, Download or Pending.
     */
    def getStatus() {
        if (this.dateArchived != null) return "Archived"
        if (this.dateCompleted != null) return "Download"
        return "Pending"
    }

    @Override
    String toString() {
        final output = """\
            ReportRequest: {
                id: [${id}],
                dateCreated: [${dateCreated}],
                requestUser: [${requestUser.displayName}],
                reportName: [${reportName}],
                dateCompleted: [${dateCompleted}],
                dateArchived: [${dateArchived}]
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
                dateArchived: [${dateArchived}],
                reportParams: ${reportParams}
            }
        """.stripIndent()
        return output
    }
}
