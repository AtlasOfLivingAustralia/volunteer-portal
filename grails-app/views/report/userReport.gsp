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
    </style>

</style>
</head>

<body class="admin">

    <content tag="pageTitle"><g:message code="admin.user.report.label" default="User Reporting"/></content>

    <g:form action="runUserReport" class="form-horizontal" method="POST">
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
                <g:actionSubmit class="save btn btn-primary" action="runUserReport"
                                value="${message(code: 'admin.report.button.label', default: 'Generate Report')}"/>
            </div>
        </div>
    </g:form>
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
    });
</asset:script>
</body>
</html>