<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'templateField.label', default: 'TemplateField')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent
            title="${message(code: 'default.edit.label', args: [entityName])} - ${templateFieldInstance.fieldType}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                    [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: ['Template'])],
                    [link: createLink(controller: 'template', action: 'edit', id: templateFieldInstance.template.id), label: message(code: 'default.edit.label', args: ['Template'])],
                    [link: createLink(controller: 'template', action: 'manageFields', id: templateFieldInstance.template.id), label: 'Manage Template Fields']
            ]
        %>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${templateFieldInstance}">
                        <div class="errors">
                            <g:renderErrors bean="${templateFieldInstance}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form method="post" class="form-horizontal">
                        <g:hiddenField name="id" value="${templateFieldInstance?.id}"/>
                        <g:hiddenField name="version" value="${templateFieldInstance?.version}"/>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'fieldType', 'has-error')}">
                            <label for="fieldType" class="col-md-2 control-label"><g:message code="templateField.fieldType.label" default="Field Type"/></label>
                            <div class="col-md-6">
                                <g:select name="fieldType" class="form-control"
                                          from="${au.org.ala.volunteer.DarwinCoreField?.values()?.sort { it.name() }}"
                                          keys="${au.org.ala.volunteer.DarwinCoreField?.values()*.name()?.sort { it }}"
                                          value="${templateFieldInstance?.fieldType?.name()}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'fieldTypeClassifier', 'has-error')}">
                            <label for="fieldTypeClassifier" class="col-md-2 control-label"><g:message code="templateField.fieldTypeClassifier.label" default="Classifier"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control" name="fieldTypeClassifier" value="${templateFieldInstance?.fieldTypeClassifier}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'label', 'has-error')}">
                            <label for="label" class="col-md-2 control-label"><g:message code="templateField.label.label" default="Label"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control" name="label" value="${templateFieldInstance?.label}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'defaultValue', 'has-error')}">
                            <label for="defaultValue" class="col-md-2 control-label"><g:message code="templateField.defaultValue.label" default="Default Value"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control" name="defaultValue" maxlength="200" value="${templateFieldInstance?.defaultValue}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'mandatory', 'has-error')}">
                            <label for="mandatory" class="col-md-2 control-label"><g:message code="templateField.mandatory.label" default="Mandatory"/></label>
                            <div class="col-md-6 form-control-static">
                                <g:checkBox class="" name="mandatory" value="${templateFieldInstance?.mandatory}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'multiValue', 'has-error')}">
                            <label for="multiValue" class="col-md-2 control-label"><g:message code="templateField.multiValue.label" default="Multi Value"/></label>
                            <div class="col-md-6 form-control-static">
                                <g:checkBox class="" name="multiValue" value="${templateFieldInstance?.multiValue}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'helpText', 'has-error')}">
                            <label for="helpText" class="col-md-2 control-label"><g:message code="templateField.helpText.label" default="Help Text"/></label>
                            <div class="col-md-6">
                                <g:textArea class="form-control" name="helpText" rows="4" value="${templateFieldInstance?.helpText}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'validationRule', 'has-error')}">
                            <label for="validationRule" class="col-md-2 control-label"><g:message code="templateField.validationRule.label" default="Validation Rule"/></label>
                            <div class="col-md-6">
                                <g:select name="validationRule" class="form-control" from="${validationRules}"
                                          value="${templateFieldInstance.validationRule}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'template', 'has-error')}">
                            <label for="template" class="col-md-2 control-label"><g:message code="templateField.template.label" default="Template"/></label>
                            <div class="col-md-6">
                                <g:select class="form-control" name="template.id" from="${au.org.ala.volunteer.Template.list()}" optionKey="id"
                                          value="${templateFieldInstance?.template?.id}" noSelection="['null': '']"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'displayOrder', 'has-error')}">
                            <label for="displayOrder" class="col-md-2 control-label"><g:message code="templateField.displayOrder.label" default="Display Order"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control" name="displayOrder"
                                             value="${fieldValue(bean: templateFieldInstance, field: 'displayOrder')}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'category', 'has-error')}">
                            <label for="category" class="col-md-2 control-label"><g:message code="templateField.category.label" default="Category"/></label>
                            <div class="col-md-6">
                                <g:select class="form-control" name="category" from="${au.org.ala.volunteer.FieldCategory?.values()}"
                                          keys="${au.org.ala.volunteer.FieldCategory?.values()*.name()}"
                                          value="${templateFieldInstance?.category?.name()}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'type', 'has-error')}">
                            <label for="type" class="col-md-2 control-label"><g:message code="templateField.type.label" default="Type"/></label>
                            <div class="col-md-6">
                                <g:select class="form-control" name="type" from="${au.org.ala.volunteer.FieldType?.values()}"
                                          keys="${au.org.ala.volunteer.FieldType?.values()*.name()}"
                                          value="${templateFieldInstance?.type?.name()}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: templateFieldInstance, field: 'layoutClass', 'has-error')}">
                            <label for="layoutClass" class="col-md-2 control-label"><g:message code="templateField.layoutClass.label" default="Layout Class"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control" name="layoutClass"
                                             value="${fieldValue(bean: templateFieldInstance, field: 'layoutClass')}"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-9">
                                <g:actionSubmit class="btn btn-default save" action="update"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <g:actionSubmit class="btn btn-danger delete" action="delete"
                                                value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
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
