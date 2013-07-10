<%@ page import="au.org.ala.volunteer.Template" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}" />
        <r:require module="jquery-ui" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
        <style type="text/css">

            table.bvp-expeditions thead th {
                text-align: left;
            }

        </style>
        <script type="text/javascript">

            $(function() {

                $(".btnDeleteTemplate").click(function(e) {
                    e.preventDefault();
                    var templateId = $(this).parents("[templateId]").attr("templateId");
                    var templateName = $(this).parents("[templateName]").attr("templateName");
                    if (templateId && templateName) {
                        if (confirm("Are you sure you wish to delete template " + templateName + "?")) {
                            window.location = "${createLink(controller:'template', action:'delete')}/" + templateId;
                        }
                    }
                });

                $(".btnCloneTemplate").click(function(e) {
                    e.preventDefault();
                    var oldTemplateId = $(this).parents("[templateId]").attr("templateId");
                    var oldTemplateName = $(this).parents("[templateName]").attr("templateName");

                    if (oldTemplateId && oldTemplateName) {
                        $("#selectedTemplateId").val(oldTemplateId);
                        $("#oldTemplateName").html("<b>" + oldTemplateName + "</b>");
                        $("#dialog").dialog( "open" );
                        $("#newTemplateName").val("CopyOf" + oldTemplateName);
                        $("#newTemplateName").select();
                    }
                });

                $("#btnCancelCopy").click(function() {
                    $("#dialog").dialog("close");
                });

                $("#btnApplyCopy").click(function() {
                    var newName = $("#newTemplateName").val();
                    var existingTemplateId = $("#selectedTemplateId").val();
                    if (newName && existingTemplateId) {
                        window.location = "${createLink(controller:'template', action:'cloneTemplate')}?templateId=" + existingTemplateId + "&newName=" + newName
                    }
                });

                $( "#dialog" ).dialog({
                    minHeight: 200,
                    minWidth: 400,
                    resizable: false,
                    autoOpen: false
                });

            });

        </script>
    </head>
    <body>

        <cl:headerContent title="${message(code: 'default.list.label', args: [entityName])}">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration']
                ]
            %>
            <div>
                <a href="${createLink(action:'create')}" class="btn">Create new template</a>
            </div>
        </cl:headerContent>

        <div class="row" id="content">
            <div class="span12">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <g:sortableColumn property="name" title="${message(code: 'template.name.label', default: 'Name')}" />
                            <g:sortableColumn property="author" title="${message(code: 'template.author.label', default: 'Author')}" />
                            <g:sortableColumn property="viewName" title="${message(code: 'template.viewName.label', default: 'View Name')}" />
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${templateInstanceList}" status="i" var="templateInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}" templateId="${templateInstance.id}" templateName="${templateInstance.name}" >

                            <td>${fieldValue(bean: templateInstance, field: "name")}</td>
                            <td>${fieldValue(bean: templateInstance, field: "author")}</td>
                            <td>${fieldValue(bean: templateInstance, field: "viewName")}</td>

                            <td>
                                <a class="btn btnCloneTemplate" href="#" style="margin-top: 6px">Clone</a>
                                <a class="btn" style="margin-top: 6px" href="${createLink(controller:'template', action:'edit', id:templateInstance.id)}">Edit</a>
                                <a class="btn" style="margin-top: 6px" href="${createLink(controller:'template', action:'preview', id:templateInstance.id)}">Preview</a>
                                <a class="btn btn-danger btnDeleteTemplate" href="#" style="margin-top: 6px">Delete</a>
                            </td>
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="pagination">
                <g:paginate total="${templateInstanceTotal}" />
            </div>
        </div>

        <div id="dialog" title="Clone template" style="display: none">
            Create a copy of the <span id="oldTemplateName"></span> template with a new name:
            <table style="width: 100%">
                <tr>
                    <td><strong>Template Name:</strong></td>
                    <td><g:textField name="newTemplateName" id="newTemplateName" size="20"/></td>
                </tr>
            </table>
            <div>
                <button class="btn" id="btnCancelCopy">Cancel</button>
                <button class="btn" id="btnApplyCopy">Clone Template</button>
            </div>
            <g:hiddenField name="selectedTemplateId" id="selectedTemplateId"/>
        </div>
    </body>
</html>
