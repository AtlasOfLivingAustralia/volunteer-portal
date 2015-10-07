<%@ page import="au.org.ala.volunteer.Template" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}"/>
    <title><g:message code="default.create.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.create.label', args: [entityName])}" selectedNavItem="bvpadmin">
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
                    <g:hasErrors bean="${templateInstance}">
                        <div class="errors">
                            <g:renderErrors bean="${templateInstance}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form class="form form-horizontal" action="save">
                        <div class="form-group ${hasErrors(bean: templateInstance, field: 'name', 'has-error')}">
                            <label for="name" class="col-md-2 control-label"><g:message code="template.name.label" default="Name"/></label>
                            <div class="col-md-6">
                                <g:textField name="name" class="form-control" maxlength="200" value="${templateInstance?.name}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateInstance, field: 'viewName', 'has-error')}">
                            <label for="viewName" class="col-md-2 control-label"><g:message code="template.viewName.label" default="View Name"/></label>
                            <div class="col-md-6">
                                <g:if test="${availableViews}">
                                    <g:select from="${availableViews}" name="viewName" class="form-control"
                                              value="${templateInstance?.viewName}"/>
                                </g:if>
                                <g:else>
                                    <g:textField name="viewName" class="form-control" value="${templateInstance?.viewName}"/>
                                </g:else>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-10">
                                <g:submitButton name="create" class="btn btn-primary"
                                                value="${message(code: 'default.button.create.label', default: 'Create')}"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
