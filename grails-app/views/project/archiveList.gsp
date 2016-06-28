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

    <h2><g:message code="project.archived.description" /></h2>
</cl:headerContent>
<div class="container" role="main">
    <div class="panel panel-default">
        <table class="table table-condensed">
            <tr>
                <th><g:message code="system.space.usable" default="Usable space"/></th>
                <th><g:message code="system.space.free" default="Free space"/></th>
                <th><g:message code="system.space.total" default="Total space"/></th>
                <th><g:message code="system.space.percentFull" default="Percent full"/></th>
            </tr>
            <tr>
                <td><cl:formatFileSize size="${imageStoreStats.usable}"/></td>
                <td><cl:formatFileSize size="${imageStoreStats.free}"/></td>
                <td><cl:formatFileSize size="${imageStoreStats.total}"/></td>
                <td>${((imageStoreStats.total - imageStoreStats.free) / imageStoreStats.total) * 100.0}%</td>
            </tr>
        </table>
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="id"
                                              title="${message(code: 'project.id.label', default: 'Id')}"/>

                            <g:sortableColumn property="name"
                                              title="${message(code: 'project.name.label')}"/>

                            <th><span><g:message code="project.archive.percentTranscribed.label" default="Transcribed %" /></span></th>


                            <th><span><g:message code="project.archive.percentValidated.label" default="Validated %" /></span></th>

                            <g:sortableColumn property="created"
                                              title="${message(code: 'project.dateCreated.label', default: 'Date Created')}"/>


                            <th><span><g:message code="project.archive.size.label" default="Size" /></span></th>

                            <th></th>

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${archiveProjectInstanceList}" status="i" var="projectInstance">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
                                <td style="vertical-align: middle;">
                                    ${projectInstance.project.id}
                                </td>
                                <td style="vertical-align: middle;">
                                    <g:link action="edit" id="${projectInstance.project.id}">${fieldValue(bean: projectInstance.project, field: "name")}</g:link>
                                </td>

                                <td style="vertical-align: middle;">${fieldValue(bean: projectInstance, field: "percentTranscribed")}</td>

                                <td style="vertical-align: middle;">${fieldValue(bean: projectInstance, field: "percentValidated")}</td>

                                <td style="vertical-align: middle;"><g:formatDate type="date" style="medium"
                                        date="${projectInstance.project.dateCreated}"/></td>

                                <td style="vertical-align: middle;"><span class="archive-list-file-size" data-id="${projectInstance.project.id}"><i class="fa fa-2x fa-cog fa-spin"></i></span></td>

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
<asset:script>
jQuery(function($) {
  $('.archive-project').click(function(e) {
    var $this = $(this);
    var href = $this.data('href');
    var name = $this.data('projectName');
    bootbox.confirm("Are you sure you wish to archive \"" + name + "\"?  Note that this will remove all task images and there may not be any backups!", function(result) {
      if (result) {
        $.post(href).then(function() {
        window.location.reload();
        });
      }
    });
  });
  $('.archive-list-file-size').each(function() {
    var $this = $(this);
    var id = $this.data('id');
    $.getJSON('${g.createLink(controller: 'project', action: 'projectSize')}/' + id).then(function(data) {
      $this.text(data.size);
    });
  })
});
</asset:script>
</body>
</html>
