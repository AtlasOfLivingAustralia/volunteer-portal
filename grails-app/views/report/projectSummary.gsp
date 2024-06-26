<%@ page import="au.org.ala.volunteer.ReportRequestService" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-reporting"/>
    <title><g:message code="admin.project.summary.label" default="Project Summary Report"/></title>
    <asset:stylesheet src="bootstrap-select.css" />
    <asset:stylesheet src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css" />
</head>

<body class="admin">

<content tag="pageTitle"><g:message code="admin.project.summary.label" default="Project Summary Report"/></content>

<div class="panel panel-default" style="margin-top: 5px;">
    <div class="panel-body">
        <p>This report provides a summary outlook of all projects you have access to. <br/>
            Includes task counts, transcribe and validation counts, expedition type, percentage complete, date started
            and finished, and average transcription time.</p>
    </div>
</div>

<g:form action="requestProjectSummaryReport" class="form-horizontal" method="POST">
    <div class="form-group">
        <div class="col-sm-offset-3 col-sm-8 input-group">
            <g:actionSubmit class="save btn btn-primary" action="requestProjectSummaryReport"
                            value="${message(code: 'admin.report.button.label', default: 'Generate Report')}"/>
        </div>
    </div>
</g:form>

<div class="row" style="padding-top: 20px;">
    <div class="col-md-12">
        <h4>Your Previous Reports</h4>
    </div>
</div>
<div class="row">
    <div class="col-md-12 table-responsive">
        <table class="table table-striped table-hover" id="report-table">
            <thead>
            <tr>
                <th>Date Requested</th>
                <th>Status</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>
</div>

<asset:script type="text/javascript" asset-defer="">
$(function () {
    function loadReportData() {
        const reportName = '${ReportRequestService.REPORT_NAME_PROJECT_SUMMARY}';
        const url = "${createLink(controller: 'report', action: 'getReports')}?reportName=" + reportName;
        $.get({
            url: url,
            dataType: 'json',
            cache: false
        }).done(function(data) {
            updateReportTable(data);
        });
    }

    function updateReportTable(data) {
        var tableData = [];

        $.each(data, function(idx, report) {

            var tableRow = "<tr>";
            tableRow += "<td><span title='Parameters: " + JSON.stringify(report.params) + "'>" + report.dateCreated + "</span></td>";
            if (report.dateCompleted === null || report.dateCompleted === undefined) {
                tableRow += "<td>Pending</td>";
            } else if (report.filepath !== undefined && report.dateArchived === null) {
                tableRow += "<td><a href='" + report.filepath + "'>Download</a></td>";
            } else {
                tableRow += "<td>Archived</td>";
            }

            tableRow += "</tr>";
            tableData.push(tableRow);
        });

        if (data === null || data.length === 0) {
            tableData.push("<tr><td colspan='2'>No reports found.</td></tr>");
        }

        $('#report-table').find('tbody').html(tableData.join(""));
    }

    loadReportData();
    var intervalId = window.setInterval(function(){
        loadReportData();
    }, 60000);
});
</asset:script>
</body>
</html>