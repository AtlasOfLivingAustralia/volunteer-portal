<%@ page import="au.org.ala.volunteer.Picklist" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
    <r:script type="text/javascript">
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

            $("#searchbox").focus();

        }); // end .ready()
    </r:script>

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

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    %{--<cl:ifAdmin>--}%
                        %{--<a href="${createLink(controller: 'picklistItem', action: 'list', id: picklistInstance.id)}"--}%
                           %{--class="btn btn-default pull-left">Manage Picklist Items</a>--}%
                    %{--</cl:ifAdmin>--}%
                    <div class="custom-search-input body">
                        <div class="input-group">
                            <input type="text" id="searchbox" value="${params.q}" name="searchbox" class="form-control input-lg" placeholder="Search by Value" />
                            <span class="input-group-btn">
                                <button class="btn btn-info btn-lg" type="button" onclick="doSearch();">
                                    <i class="glyphicon glyphicon-search"></i>
                                </button>
                            </span>
                        </div>
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
                                <td><g:link controller="picklistItem" action="show"
                                            id="${picklistItemInstance.id}">${picklistItemInstance.id}</g:link></td>
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
