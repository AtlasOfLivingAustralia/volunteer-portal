<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.ala.skin}">
    <g:set var="entityName" value="${message(code: 'project.label', default: 'Expedition')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'project.archive.label', default: 'Archive Expeditions')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]

    %>
</cl:headerContent>
<div class="container" role="main">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="name"
                                              title="${message(code: 'project.name.label')}"/>

                            <g:sortableColumn property="percentTranscribed"
                                              title="${message(code: 'project.archive.percentTranscribed.label', default: 'Transcribed %')}"/>

                            <g:sortableColumn property="percentValidated"
                                              title="${message(code: 'project.archive.percentValidated.label', default: 'Validated %')}"/>

                            <g:sortableColumn property="created"
                                              title="${message(code: 'project.created.label', default: 'Created')}"/>

                            <g:sortableColumn property="size"
                                              title="${message(code: 'project.archive.size.label', default: 'Size')}"/>

                            <th></th>

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${archiveProjectInstanceList}" status="i" var="projectInstance">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
                                <td style="vertical-align: middle;">
                                    <g:link action="edit" id="${projectInstance.project.id}">${fieldValue(bean: projectInstance.project, field: "name")}</g:link>
                                </td>

                                <td style="vertical-align: middle;">${fieldValue(bean: projectInstance, field: "percentTranscribed")}</td>

                                <td style="vertical-align: middle;">${fieldValue(bean: projectInstance, field: "percentValidated")}</td>

                                <td style="vertical-align: middle;"><g:formatDate type="date" style="medium"
                                        date="${projectInstance.project.created}"/></td>

                                <td style="vertical-align: middle;"><cl:formatFileSize size="${projectInstance.size}"/></td>

                                <td>
                                    <g:link action="downloadImageArchive" id="${projectInstance.project.id}" class="btn btn-default btn-sm"><i class="fa fa-download"></i></g:link>
                                    <button role="button" class="btn btn-danger btn-sm archive-project" data-project-name="${projectInstance.project.name}" data-href="${createLink(action:"archive", id:projectInstance.project.id)}"><i class="fa fa-trash"></i></button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${archiveProjectInstanceListSize ?: 0}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<r:script>
jQuery(function($) {
   $('.archive-project').click(function(e) {
       var $this = $(this);
       var href = $this.data('href');
       var name = $this.data('projectName');
       bootbox.confirm("Are you sure you wish to archive \"" + name + "\"?", function(result) {
           if (result) {
               $.post(href).then(function() {
                   window.location.reload();
               });
           }
       });
   });
});
</r:script>
</body>
</html>
