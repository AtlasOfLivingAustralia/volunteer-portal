<%@ page import="au.org.ala.volunteer.DateConstants" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-reporting"/>
    <title><g:message code="admin.user.report.label" default="User Reporting"/></title>
    <asset:stylesheet src="bootstrap-select.css" />

</head>

<body class="admin">
    <content tag="pageTitle"><g:message code="admin.report.history.label" default="Report History"/></content>

    <div class="row">
    <cl:ifSiteAdmin>
        <div class="col-md-3">
            <g:select class=" form-control statusFilter" name="statusFilter" from="${[[key: 'all', value: 'All Reports'], [key: 'active', value: 'Available Reports'], [key: 'archived', value: 'Archived Reports']]}"
                      optionKey="key"
                      optionValue="value"
                      value="${params?.statusFilter}"
                      noSelection="['':'- Filter by Status -']" />
        </div>
    </cl:ifSiteAdmin>
        <div class="col-md-3">
            <g:select class="form-control reportFilter" name="reportFilter" from="${reportFilterList}"
                      value="${params?.reportFilter}"
                      noSelection="['':'- Filter by Report -']" />
        </div>
        <div class="col-md-3">
            <a class="btn btn-default bs3"
               href="${createLink(controller: 'report', action: 'reportHistory')}">Reset</a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
            <small>${reportCount ?: 0} Reports found.</small>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12 table-responsive">
            <table class="table table-striped table-hover">
                <thead>
                <tr>
                    <g:sortableColumn property="dateCreated"
                                      title="${message(code: 'report.date.created.label', default: 'Date/Time Requested')}"
                                      params="${params}"/>
                    <g:sortableColumn property="reportName"
                                      title="${message(code: 'report.report.name.label', default: 'Report Name')}"
                                      params="${params}"/>
                    <g:sortableColumn property="requestUser"
                                      title="${message(code: 'report.request.user.label', default: 'Requested By')}"
                                      params="${params}"/>
                    <g:sortableColumn property="dateCompleted"
                                      title="${message(code: 'report.date.completed.label', default: 'Date/Time Completed')}"
                                      params="${params}"/>
                    <th>
                        Status
                    </th>
                </tr>
                </thead>
                <tbody>
                    <g:each in="${reportList}" status="i" var="reportInstance">
                    <tr>
                        <td>${formatDate(date: reportInstance.report.dateCreated, format: DateConstants.DATE_TIME_FORMAT)}</td>
                        <td>${reportInstance.report.reportName}</td>
                        <td>${reportInstance.report.requestUser.displayName}</td>
                        <td>${formatDate(date: reportInstance.report.dateCompleted, format: DateConstants.DATE_TIME_FORMAT)}</td>
                        <g:set var="reportStatus" value="${reportInstance.report.getStatus()}"/>
                        <g:if test="${reportStatus == 'Download'}">
                        <td><a href="${reportInstance.filepath}">${reportInstance.report.getStatus()}</a></td>
                        </g:if>
                        <g:else>
                        <td>${reportInstance.report.getStatus()}</td>
                        </g:else>
                    </tr>
                    </g:each>
                </tbody>
            </table>
            <g:if test="${reportCount > 25}">
            <div class="pagination">
                <g:paginate total="${institutionInstanceCount ?: 0}" params="${params}"/>
            </div>
            </g:if>
        </div>
    </div>
<asset:script type="text/javascript">

    jQuery(function($) {
        $('.statusFilter').change(function() {
            let filter = $(this).val();
            let url = "${createLink(controller: 'report', action: 'reportHistory').encodeAsJavaScript()}";
            const p = new URLSearchParams(window.location.search);

            let reportFilter = p.get('reportFilter');

            if (reportFilter !== "" && reportFilter !== null && reportFilter !== undefined) {
                url += "?reportFilter=" + reportFilter + "&statusFilter=" + filter;
            } else {
                url += "?statusFilter=" + filter;
            }

            window.location = url;
        });

        $('.reportFilter').change(function() {
            let filter = $(this).val();
            let url = "${createLink(controller: 'report', action: 'reportHistory').encodeAsJavaScript()}";
            const p = new URLSearchParams(window.location.search);

            let statusFilter = p.get('statusFilter');

            if (statusFilter !== "" && statusFilter !== undefined) {
                url += "?statusFilter=" + statusFilter  + "&reportFilter=" + filter;
            } else {
                url += "?reportFilter=" + filter;
            }

            window.location = url;
        });
    });

</asset:script>
</body>
</html>