<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'validationRule.label', default: 'ValidationRule')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])} - ${rule.name}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: message(code: 'default.admin.label')],
                    [link: createLink(controller: 'validationRule', action: 'list'), label: message(code: 'default.list.label', args: ['ValidationRule'])],
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${rule}">
                        <div class="errors">
                            <g:renderErrors bean="${rule}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form method="post" class="form-horizontal">
                        <g:hiddenField name="id" value="${rule?.id}"/>
                        <g:hiddenField name="version" value="${rule?.version}"/>

                        <div class="form-group ${hasErrors(bean: rule, field: 'name', 'has-error')}">
                            <label for="name" class="control-label col-md-3"><g:message code="validationRule.name.label" default="Name"/></label>
                            <div class="col-md-4">
                                <g:textField name="name" class="form-control" value="${rule?.name}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: rule, field: 'description', 'has-error')}">
                            <label for="description" class="control-label col-md-3"><g:message code="validationRule.description.label" default="Description"/></label>
                            <div class="col-md-4">
                                <g:textField name="description" class="form-control" value="${rule?.description}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: rule, field: 'validationType', 'has-error')}">
                            <label for="validationType" class="control-label col-md-3"><g:message code="validationRule.validationType.label" default="Validation Type"/></label>
                            <div class="col-md-4">
                                <g:select name="validationType" class="form-control" from="${au.org.ala.volunteer.ValidationType.values()}"
                                          value="${rule.validationType}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: rule, field: 'regularExpression', 'has-error')}">
                            <label for="regularExpression" class="control-label col-md-3"><g:message code="validationRule.regularExpression.label" default="Pattern"/></label>
                            <div class="col-md-4">
                                <g:textField name="regularExpression" class="form-control" value="${rule?.regularExpression}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: rule, field: 'testEmptyValues', 'has-error')}">
                            <label for="testEmptyValues" class="control-label col-md-3"><g:message code="validationRule.testEmptyValues.label" default="Test empty/blank values"/></label>
                            <div class="col-md-4">
                                <g:checkBox name="testEmptyValues" class="form-control" value="${rule?.testEmptyValues}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: rule, field: 'message', 'has-error')}">
                            <label for="message" class="control-label col-md-3"><g:message code="validationRule.message.label" default="Message"/></label>
                            <div class="col-md-4">
                                <g:textField name="message" class="form-control" value="${rule?.message}"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:actionSubmit class="btn save btn-primary" action="update"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <a href="${createLink(controller: 'validationRule', action: 'list')}" class="btn btn-default"><g:message code="default.cancel" /></a>
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
