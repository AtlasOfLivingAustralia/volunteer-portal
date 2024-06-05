<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-reporting"/>
    <title><g:message code="admin.user.report.label" default="User Reporting"/></title>
    <asset:stylesheet src="bootstrap-select.css" />
    <asset:stylesheet src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css" />
    <style>
    .label-button {
        cursor: pointer;
        font-size: 1.2em;
    }

    .today, .active {
        font-weight: bold;
    }

    .prev, .next, .day, .month, .year, .today, .datepicker-switch {
        cursor: pointer;
    }

    .loader {
        border: 4px solid #e0e0e0; /* Light grey */
        border-top: 4px solid #000000;
        border-radius: 50%;
        width: 2.475rem;
        height: 2.475rem;
        animation: spin 1s linear infinite;
        }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    .float-right {
        position: absolute;
        z-index: 2;
        display: block;
        /*line-height: 2.375rem;*/
        text-align: center;
        pointer-events: none;
        color: #aaa;
        right:40px;
        top: 4px;
    }
    </style>
</head>

<body class="admin">

    <content tag="pageTitle"><g:message code="admin.user.report.label" default="User Reporting"/></content>

    <div class="panel panel-default" style="margin-top: 5px;">
        <div class="panel-body">
            <p>This report has two flavours: Filtered by tag and all users.</p>
            <p><b>Filtered by tag:</b> This report collates users who are tagged by the selected tag and who
            transcribed tasks between the provided start and end dates.</p>
            <p><b>All users:</b> Due to the number of users, this report ignores the start and end date parameters and
            provides a summary of user activity on DigiVol.</p>
        </div>
    </div>

    <g:form action="requestUserReport" class="form-horizontal" method="POST">
        <div class="form-group">
            <label for="dateSelect" class="col-md-3 control-label">Date Range*</label>
            <div class="col-md-8 input-daterange input-group" id="datepicker">
                <input type="text" class="input-sm col-sm-3 form-control" value="${defaultStartDate}" name="dateStart" />
                <span class="input-group-addon">to</span>
                <input type="text" class="input-sm col-sm-3 form-control" value="${defaultEndDate}" name="dateEnd" />
            </div>
        </div>
        <div class="form-group">
            <label for="labelFilter" class="col-md-3 control-label">Filter by User Tag</label>
            <div class="col-md-8 input-group">
                <g:select name="labelFilter"
                          from="${userLabelList}"
                          optionKey="id"
                          class="input-sm form-control col-md-9"
                          optionValue="value"
                          noSelection="['':'- Filter by Tag -']"/>
            </div>
        </div>
        <div class="form-group">
            <div class="col-sm-offset-3 col-sm-8 input-group">
                <g:actionSubmit class="save btn btn-primary" action="requestUserReport"
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

<asset:script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js" asset-defer=""/>
<asset:script type="text/javascript" asset-defer="">
$(function () {
    $('.input-daterange').datepicker({
        format: "dd/mm/yyyy",
        autoclose: true,
        todayBtn: true,
        orientation: "bottom auto",
        todayHighlight: true,
        endDate: "${defaultEndDate}"
    });

    function loadReportData() {
        const reportName = 'user';
        const url = "${createLink(controller: 'report', action: 'getReports')}?reportName=" + reportName;
        $.get({
            url: url,
            dataType: 'json'
        }).done(function(data) {
            console.log(data)
            updateReportTable(data);
        });
    }

    function updateReportTable(data) {
        var tableData = [];

        $.each(data, function(idx, report) {
            console.log(report);
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
        console.log("Loading report data");
        loadReportData();
    }, 60000);
});
</asset:script>
</body>
</html>