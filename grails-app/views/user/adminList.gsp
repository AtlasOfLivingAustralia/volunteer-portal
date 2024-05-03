<%@ page import="au.org.ala.volunteer.Institution" %>
<%@ page import="au.org.ala.volunteer.LabelColour" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.admin.label', default: 'User')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>

    <style>
        .label-button {
            cursor: pointer;
            font-size: 1.2em;
        }
    </style>
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
            <div class="row">
                <div class="col-md-3">

                    <g:select class="form-control labelFilter" name="labelFilter" from="${userLabels}"
                              optionKey="id"
                              optionValue="value"
                              value="${params?.labelFilter}"
                              noSelection="['':'- Filter by Tag -']" />

                </div>
                <div class="col-md-3">
                    <input type="text" id="searchbox" class="form-control" value="${params.q}" placeholder="Search by name or email..."/>
                </div>
                <div class="col-md-3">
                    <a class="btn btn-default bs3"
                        href="${createLink(controller: 'user', action: 'adminList')}">Reset</a>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    ${userInstanceTotal ?: 0} ${entityName}s found.
                </div>
            </div>

            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
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


                                <td>${fieldValue(bean: userInstance, field: "lastName")}</td>

                                <td>${fieldValue(bean: userInstance, field: "firstName")}</td>

                                <td>
                                    <g:each in="${userInstance.labels}" var="l">
                                        <g:set var="labelClassName" value="${l.category.labelColour ?: 'base'}"/>
                                        <span class="label label-${labelClassName}">${l.value}</span>
%{--                                        <span class="label label-base">${userLabel.value}</span>--}%
                                    </g:each>
                                </td>

                                <td class="bold text-center">${fieldValue(bean: userInstance, field: "transcribedCount")}</td>

                                <td class="bold text-center">${userInstance?.validatedCount}</td>

                                <td class="text-center"><g:formatDate format="yyyy-MM-dd" date="${userInstance.created}"/></td>

                                <td>
                                    <i class="fa fa-edit label-button doLink"
                                       data-href="${createLink(controller: 'user', action: 'edit', id: userInstance.id)}"
                                       title="Edit User"></i>

                                    <i class="fa fa-id-card-o label-button doLink" title="Display Notebook for User"
                                       data-href="${createLink(controller: 'user', action: 'show', id: userInstance.id)}"></i>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                    <g:if test="${userInstanceTotal > 20}">
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

    $('.doLink').click(function(event) {
        event.stopPropagation(); // Prevent row click event from firing
        var $this = $(this);
        var href = $this.data('href');
        goLink(href);
    });

    function goLink(href) {
        if (href !== undefined) {
            document.location = href;
        }
    }

    $('.labelFilter').change(function() {
        doSearch();
    });

    $("#searchbox").keydown(function(e) {
        if (e.keyCode === 13) {
            doSearch();
        }
    });

    function doSearch() {
        console.log(window.location.search);
        const params = new URLSearchParams(window.location.search);
        let statulabelFiltersFilter = params.get('labelFilter');
        let q = params.get('q');

        var labelFilter = $('.labelFilter').val();
        q = encodeURIComponent($('#searchbox').val());
        console.log(q);

        let hasParams = false;
        let url = "${createLink(controller: 'user', action: 'adminList')}?";

        if (labelFilter) {
            url += "labelFilter=" + labelFilter;
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

});
</asset:script>
</body>
</html>
