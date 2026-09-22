<%@ page import="au.org.ala.volunteer.Picklist" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
    <asset:script type="text/javascript">
        function doSearch() {
            var query = $("#searchbox").val();
            location.href = "?q=" + query;
        }

        $(document).ready(function () {

            $("#searchbox").keypress(function (e) {
                if (e.keyCode == 13) {
                    e.preventDefault();
                    doSearch();
                }
            });

            $("#btnSearch").click(function (e) {
                e.preventDefault();
                doSearch();
            });

            $("#searchbox").focus();

        }); // end .ready()
    </asset:script>

</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: "default.show.label", args: [entityName])} - ${picklistInstance.uiLabel}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'picklist', action: 'manage'), label: message(code: 'manage.picklists.label', default: 'Manage picklists')],
                    [link: createLink(controller: 'picklist', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
            ]
        %>
    </cl:headerContent>

    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-12">
                    <label class="visually-hidden" for="searchbox">Search picklists</label>
                    <div class="input-group">
                        <input type="search" id="searchbox" class="form-control" value="${params.q}" placeholder="Search picklists..."/>
                        <button id="btnSearch" class="btn btn-sm btn-primary" type="button">
                            <i class="fa fa-search" aria-hidden="true"></i>
                            <span class="visually-hidden">Search</span>
                        </button>
                    </div>

                    <table class="table table-condensed table-striped">
                        <thead>
                        <tr>
                            <g:sortableColumn property="id" title="${message(code: 'picklistItem.id.label', default: 'Id')}"/>
                            <g:sortableColumn property="key" title="${message(code: 'picklistItem.key.label', default: 'Key')}"/>
                            <g:sortableColumn property="value"
                                              title="${message(code: 'picklistItem.value.label', default: 'Value')}"/>
                            <g:sortableColumn property="institutionCode"
                                              title="${message(code: 'picklistItem.institutionCode.label', default: 'Institution Code')}"/>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${picklistItemInstanceList}" status="i" var="picklistItemInstance">
                            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                                <td>${picklistItemInstance.id}</td>
                                <td>${picklistItemInstance.key}</td>
                                <td>${picklistItemInstance.value}</td>
                                <td>${picklistItemInstance.institutionCode}</td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${picklistItemInstanceTotal}" id="${picklistInstance.id}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
