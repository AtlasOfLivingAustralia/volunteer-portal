<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.admin.label', default: 'User')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="admin">

<cl:headerContent title="${message(code: 'default.users.admin.label', default: 'Manage Users')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]

    %>


</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">

            %{--                    TODO Convert to user search --}%
%{--            <div class="row">--}%
%{--                <div class="col-md-3">--}%

%{--                    <g:select class="form-control statusFilter" name="statusFilter" from="${[[key: 'active', value: 'Active Institutions'], [key: 'inactive', value: 'Inactive Institutions']]}"--}%
%{--                              optionKey="key"--}%
%{--                              optionValue="value"--}%
%{--                              value="${params?.statusFilter}"--}%
%{--                              noSelection="['':'- Filter by Status -']" />--}%

%{--                </div>--}%
%{--                <div class="col-md-3">--}%
%{--                    <input type="text" id="searchbox" class="form-control" value="${params.q}" placeholder="Filter by Institution..."/>--}%
%{--                </div>--}%
%{--                <div class="col-md-3">--}%
%{--                    <a class="btn btn-default bs3"--}%
%{--                        href="${createLink(controller: 'institutionAdmin', action: 'index')}">Reset</a>--}%
%{--                </div>--}%
%{--            </div>--}%

            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="id"
                                              title="${message(code: 'user.id.label', default: 'ID')}"
                                              params="${params}"/>
                            <g:sortableColumn property="lastName"
                                              title="${message(code: 'user.lastName.label', default: 'Last Name')}"
                                              params="${params}"/>
                            <g:sortableColumn property="firstName"
                                              title="${message(code: 'user.firstName.label', default: 'First Name')}"
                                              params="${params}"/>
                            <th>${message(code: 'user.tag.label', default: 'Labels')}</th>
%{--                            <g:sortableColumn property="labels"--}%
%{--                                              title="${message(code: 'user.tag.label', default: 'Labels')}"--}%
%{--                                              params="${params}"/>--}%
                            <g:sortableColumn style="text-align: center" property="transcribedCount"
                                              title="${message(code: 'user.recordsTranscribedCount.label', default: 'Tasks completed')}"
                                              params="${[q: params.q]}"/>
                            <g:sortableColumn style="text-align: center" property="validatedCount"
                                              title="${message(code: 'user.transcribedValidatedCount.label', default: 'Tasks validated')}"
                                              params="${[q: params.q]}"/>
                            <g:sortableColumn style="text-align: center" property="created"
                                              title="${message(code: 'user.created.label', default: 'A volunteer since')}"
                                              params="${[q: params.q]}"/>
                            <th/>
                        </tr>

                        </thead>
                        <tbody>
                        <g:each in="${userInstanceList}" status="i" var="userInstance">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

                                <td>
                                    <g:link controller="user" action="show" id="${userInstance.id}" title="View Notebook">${fieldValue(bean: userInstance, field: "id")}</g:link>
                                </td>

                                <td>${fieldValue(bean: userInstance, field: "lastName")}</td>

                                <td>${fieldValue(bean: userInstance, field: "firstName")}</td>

                                <td>
                                    <g:each in="${userInstance.labels}" var="userLabel">
%{--                                        <g:set var="labelColourName" val="${userLabel.category.labelColour ?: 'base'}"/>--}%
%{--                                        <span class="label label-${labelColourName}">${userLabel.value}</span>--}%
                                        <span class="label label-base">${userLabel.value}</span>
                                    </g:each>
                                </td>

                                <td class="bold text-center">${fieldValue(bean: userInstance, field: "transcribedCount")}</td>

                                <td class="bold text-center">${userInstance?.validatedCount}</td>

                                <td><g:formatDate format="yyyy-MM-dd" date="${userInstance.created}"/></td>

                                <td>
                                    <a class="btn btn-xs btn-default" title="Edit User"
                                       href="${createLink(controller: 'user', action: 'edit', id: userInstance.id)}">
                                            <i class="fa fa-edit"></i>
                                    </a>

                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                    <g:if test="${userInstanceCount > 20}">
                    <div class="pagination">
                        <g:paginate total="${userInstanceTotal ?: 0}" params="${params}"/>
                    </div>
                    </g:if>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:script type="text/javascript">
    $(function($) {

/*
        $('.delete-institution').on('click', function(e) {
            e.preventDefault();
            var self = this;
            bootbox.confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}', function(result) {
                if (result) {
                    $(self).closest('form').submit();
                }
            });
        });

        $('.statusFilter').change(function() {
            doSearch();
        });

        $("#searchbox").keydown(function(e) {
            if (e.keyCode == 13) {
                doSearch();
            }
        });

        function doSearch() {
            console.log(window.location.search);
            const params = new URLSearchParams(window.location.search);
            let statusFilter = params.get('statusFilter');
            let q = params.get('q');

            statusFilter = $('.statusFilter').val();
            q = encodeURIComponent($('#searchbox').val());
            console.log(q);

            let hasParams = false;
            let url = "${createLink(controller: 'institutionAdmin', action: 'index')}?";

            if (statusFilter) {
                url += "statusFilter=" + statusFilter;
                if (!hasParams) hasParams = true;
            }
            if (q) {
                if (hasParams) {
                    url += "&";
                }
                url += "q=" + q;
            }

            console.log(url);
            window.location = url;
        }
 */

    });
</asset:script>
</body>
</html>
