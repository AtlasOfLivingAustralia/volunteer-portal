<%@ page import="au.org.ala.volunteer.Template" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body class="admin">

<div class="container">
    <cl:headerContent title="${message(code: 'default.show.label', args: [entityName])} - ${templateInstance.name}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                    [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
            ]
        %>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <form class="form-horizontal">
                        <div class="form-group">
                            <label for="templateId" class="col-md-3 control-label"><g:message code="template.id.label" default="Id"/></label>
                            <div class="col-md-6">
                                <div id="templateId" class="form-control-static">${fieldValue(bean: templateInstance, field: "id")}</div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="author" class="col-md-3 control-label"><g:message code="template.author.label" default="Author"/></label>
                            <div class="col-md-6">
                                <div id="author" class="form-control-static">${cl.emailForUserId(id: templateInstance.author)}</div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="name" class="col-md-3 control-label"><g:message code="template.name.label" default="Name"/></label>
                            <div class="col-md-6">
                                <div id="name" class="form-control-static">${fieldValue(bean: templateInstance, field: "name")}</div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="viewName" class="col-md-3 control-label"><g:message code="template.viewName.label" default="View Name"/></label>
                            <div class="col-md-6">
                                <div id="viewName" class="form-control-static">${fieldValue(bean: templateInstance, field: "viewName")}</div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="project" class="col-md-3 control-label"><g:message code="template.project.label" default="Projects"/></label>
                            <div class="col-md-6">
                                <ul class="form-control-static" id="project">
                                    <g:each in="${templateInstance.project}" var="p">
                                        <li><g:link controller="project" action="show"
                                                    id="${p.id}">${p?.encodeAsHTML()}</g:link></li>
                                    </g:each>
                                </ul>
                            </div>
                        </div>

                        <div class="form-group buttons">
                            <div class="col-md-offset-3 col-md-9">
                                <g:hiddenField name="id" value="${templateInstance?.id}"/>
                                <g:actionSubmit class="btn btn-default edit" action="edit"
                                                value="${message(code: 'default.button.edit.label', default: 'Edit')}"/>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
