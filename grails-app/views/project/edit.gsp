<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
        <title><g:message code="default.edit.label" args="[entityName]"/></title>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>

        <tinyMce:resources />

        <script type="text/javascript">

            tinyMCE.init({
                mode: "textareas",
                theme: "advanced",
                editor_selector: "mceadvanced",
                theme_advanced_toolbar_location : "top",
                convert_urls : false
            });

            function confirmDeleteAllTasks() {
                return confirm("Warning!!!! This will remove all tasks, including those that have already been transcribed!\n\nAre you sure you want to delete all ${taskCount} tasks for '${projectInstance.featuredLabel}'?");
            }

        </script>

        <style type="text/css">

            .table tr td {
                border: none;
            }

        </style>

    </head>
    <body>
        <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])} - ${projectInstance.name}" selectedNavItem="expeditions">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'index', id:projectInstance.id), label: projectInstance.featuredLabel]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:hasErrors bean="${projectInstance}">
                    <div class="errors">
                        <g:renderErrors bean="${projectInstance}" as="list"/>
                    </div>
                </g:hasErrors>
                <g:form method="post">
                    <g:hiddenField name="id" value="${projectInstance?.id}"/>
                    <g:hiddenField name="version" value="${projectInstance?.version}"/>

                    <g:render template="projectDetailsTable" model="${[projectInstance: projectInstance]}" />

                    <div>
                        <g:actionSubmit class="save btn" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                        <g:actionSubmit class="delete btn btn-danger" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
                    </div>
                </g:form>
            </div>
        </div>
        <div class="row">
            <div class="span12">
                <table align="center" border="1">
                    <thead><tr><td colspan="3">Image Upload</td></tr></thead>
                    <tr>
                        <td style="vertical-align: middle;padding:20px">
                            <label><g:message code="project.featuredImage.label" default="Featured Image"/></label>
                        </td>
                        <td style="padding: 20px">
                            <img src="${projectInstance?.featuredImage}" align="middle"/>
                        </td>
                        <td style="vertical-align: middle;padding: 20px">
                            <g:form action="uploadFeaturedImage" controller="project" method="post" enctype="multipart/form-data">
                                <input type="file" name="featuredImage"/>
                                <input type="hidden" name="id" value="${projectInstance.id}"/>
                                <g:submitButton class="btn" name="Upload"/>
                            </g:form>
                            <br/>
                            Images should be 254 x 158 pixels in size
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </body>
</html>
