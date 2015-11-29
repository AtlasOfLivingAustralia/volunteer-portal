<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}"/>
    <title><g:message code="institution.migrate.label" default="Migrate Project Sponsors"/></title>
</head>

<body class="admin">

<cl:headerContent title="${message(code: 'institution.migrate.label', default: 'Migrate Project Sponsors')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'admin', action: 'tools'), label: message(code: 'default.tools.label', default: 'Tools')]
        ]

    %>


</cl:headerContent>
<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <a id="migrate-button" class="btn btn-success" href="javascript:void(0)">Migrate Selected</a>
            <div id="list-institution" class="content scaffold-list table-responsive" role="main">
                <table class="table table-striped table-hover">
                    <thead>
                    <tr>
                        <th></th>
                        <g:sortableColumn property="name" title="${message(code: 'project.name.label', default: 'Project Name')}"/>
                        <g:sortableColumn property="featuredOwner"
                                          title="${message(code: 'project.featuredOwner.label', default: 'Project Sponsor')}"/>
                        <th><g:message code="institution.migrate.select" default="New Institution"/></th>
                    </tr>
                    </thead>
                    <tbody>
                    <g:each in="${projectsWithScores}" status="i" var="project">
                        <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

                            <td><input type="checkbox" name="enabled-${project.id}" id="enabled-${project.id}"/></td>

                            <td>${project.name}</td>

                            <td class="col-md-4">${project.owner}</td>

                            <td class="col-md-4">
                                <form id="select-${project.id}">
                                    <select name="inst-${project.id}" id="inst-${project.id}" class="form-control">
                                        <g:each in="${project.scores}" var="score" status="j">
                                            <option <g:if test="${j == 0}">selected</g:if>value="${score.id}">${score.name}</option>
                                        </g:each>
                                    </select>
                                </form>
                            </td>
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<r:script>
            jQuery(function($) {
                $('#migrate-button').click(postData);

                function postData(e) {
                    var url = "${createLink(action: 'doMigrateProjectsToInstitutions')}";
                    //var ids = $('input[type="checkbox"][checked]').map(function() {
                    var ids = $('input:checkbox:checked').map(function() {
                        var id = parseInt(this.id.substring(8));
                        return { id: id, inst: parseInt($('#inst-' + id).val()) };
                    }).toArray();
                    $.ajax({
                        type: 'POST',
                        url: url,
                        contentType: "application/json",
                        data: JSON.stringify(ids),
                        success: success}).error(failure);
                }
                function success(/**Object*/ data, /**String*/ textStatus, /**jqXHR*/jqXHR ) {
                    location.reload();
                }
                function failure() {
                    alert("Migration failed, please reload and try again");
                }
            });
</r:script>
</body>
</html>
