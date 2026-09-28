<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'validationRule.label', default: 'ValidationRule')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.edit.label', args: [entityName])} - ${rule.name}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                    [link: createLink(controller: 'validationRule', action: 'list'), label: message(code: 'default.list.label', args: ['ValidationRule'])],
            ]
        %>
    </cl:headerContent>
    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${rule}">
                        <div class="errors">
                            <g:renderErrors bean="${rule}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form method="post">
                        <g:hiddenField name="id" value="${rule?.id}"/>
                        <g:hiddenField name="version" value="${rule?.version}"/>

                        <div class="form-group">
                            <label for="name" class="form-label col-md-3"><g:message code="validationRule.name.label" default="Name"/></label>
                            <div class="col-md-4">
                                <g:textField name="name" class="form-control ${hasErrors(bean: rule, field: 'name', 'is-invalid')}" value="${rule?.name}"/>
                                <cl:fieldError bean="${rule}" field="name"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="description" class="form-label col-md-3"><g:message code="validationRule.description.label" default="Description"/></label>
                            <div class="col-md-4">
                                <g:textField name="description" class="form-control ${hasErrors(bean: rule, field: 'description', 'is-invalid')}" value="${rule?.description}"/>
                                <cl:fieldError bean="${rule}" field="description"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="validationType" class="form-label col-md-3"><g:message code="validationRule.validationType.label" default="Validation Type"/></label>
                            <div class="col-md-4">
                                <g:select name="validationType" class="form-select ${hasErrors(bean: rule, field: 'validationType', 'is-invalid')}" from="${au.org.ala.volunteer.ValidationType.values()}"
                                          value="${rule.validationType}"/>
                                <cl:fieldError bean="${rule}" field="validationType"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="regularExpression" class="form-label col-md-3"><g:message code="validationRule.regularExpression.label" default="Pattern"/></label>
                            <div class="col-md-4">
                                <g:textField name="regularExpression" class="form-control ${hasErrors(bean: rule, field: 'regularExpression', 'is-invalid')}" value="${rule?.regularExpression}"/>
                                <cl:fieldError bean="${rule}" field="regularExpression"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="testEmptyValues" class="form-label col-md-3"><g:message code="validationRule.testEmptyValues.label" default="Test empty/blank values"/></label>
                            <div class="col-md-4">
                                <g:checkBox name="testEmptyValues" class="form-check-input ${hasErrors(bean: rule, field: 'testEmptyValues', 'is-invalid')}" value="${rule?.testEmptyValues}"/>
                                <cl:fieldError bean="${rule}" field="testEmptyValues"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="message" class="form-label col-md-3"><g:message code="validationRule.message.label" default="Message"/></label>
                            <div class="col-md-4">
                                <g:textField name="message" class="form-control ${hasErrors(bean: rule, field: 'message', 'is-invalid')}" value="${rule?.message}"/>
                                <cl:fieldError bean="${rule}" field="message"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:actionSubmit class="btn save btn-primary" action="update"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <a href="${createLink(controller: 'validationRule', action: 'list')}" class="btn btn-secondary">Cancel</a>
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
