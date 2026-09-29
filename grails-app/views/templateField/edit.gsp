<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
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

    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${templateFieldInstance}">
                        <div class="errors">
                            <g:renderErrors bean="${templateFieldInstance}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form method="post">
                        <g:hiddenField name="id" value="${templateFieldInstance?.id}"/>
                        <g:hiddenField name="version" value="${templateFieldInstance?.version}"/>

                        <div class="form-group">
                            <label for="fieldType" class="col-md-2 form-label"><g:message code="templateField.fieldType.label" default="Field Type"/></label>
                            <div class="col-md-6">
                                <g:select name="fieldType" class="form-select ${hasErrors(bean: templateFieldInstance, field: 'fieldType', 'is-invalid')}"
                                          from="${au.org.ala.volunteer.DarwinCoreField?.values()?.sort { it.name() }}"
                                          keys="${au.org.ala.volunteer.DarwinCoreField?.values()*.name()?.sort { it }}"
                                          value="${templateFieldInstance?.fieldType?.name()}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="fieldType"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="fieldTypeClassifier" class="form-label"><g:message code="templateField.fieldTypeClassifier.label" default="Classifier"/></label>
                            <cl:helpText><g:message code="field.classifier.help" default="Distinguishes multiple fields with the same type but only works on select templates"/></cl:helpText>
                            <div class="col-md-6">
                                <g:textField class="form-control ${hasErrors(bean: templateFieldInstance, field: 'fieldTypeClassifier', 'is-invalid')}" name="fieldTypeClassifier" value="${templateFieldInstance?.fieldTypeClassifier}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="fieldTypeClassifier"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="label" class="col-md-2 form-label"><g:message code="templateField.label.label" default="Label"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control ${hasErrors(bean: templateFieldInstance, field: 'label', 'is-invalid')}" name="label" value="${templateFieldInstance?.label}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="label"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="defaultValue" class="col-md-2 form-label"><g:message code="templateField.defaultValue.label" default="Default Value"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control ${hasErrors(bean: templateFieldInstance, field: 'defaultValue', 'is-invalid')}" name="defaultValue" maxlength="200" value="${templateFieldInstance?.defaultValue}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="defaultValue"/>
                            </div>
                        </div>

                        <div class="form-check">

                            <div class="col-md-6">
                                <g:checkBox class="form-check-input ${hasErrors(bean: templateFieldInstance, field: 'mandatory', 'is-invalid')}" name="mandatory" value="${templateFieldInstance?.mandatory}"/>
                                <label for="mandatory" class="col-md-6 form-label"><g:message code="templateField.mandatory.label" default="Mandatory"/></label>
                                <cl:fieldError bean="${templateFieldInstance}" field="mandatory"/>
                            </div>
                        </div>

                        <div class="form-check">
                            <div class="col-md-6">
                                <g:checkBox class="form-check-input ${hasErrors(bean: templateFieldInstance, field: 'multiValue', 'is-invalid')}" name="multiValue" value="${templateFieldInstance?.multiValue}"/>
                                <label for="multiValue" class="col-md-6 form-label"><g:message code="templateField.multiValue.label" default="Multi Value"/></label>
                                <cl:fieldError bean="${templateFieldInstance}" field="multiValue"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="helpText" class="col-md-2 form-label"><g:message code="templateField.helpText.label" default="Help Text"/></label>
                            <div class="col-md-6">
                                <g:textArea class="form-control ${hasErrors(bean: templateFieldInstance, field: 'helpText', 'is-invalid')}" name="helpText" rows="4" value="${templateFieldInstance?.helpText}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="helpText"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="validationRule" class="col-md-2 form-label"><g:message code="templateField.validationRule.label" default="Validation Rule"/></label>
                            <div class="col-md-6">
                                <g:select name="validationRule" class="form-select ${hasErrors(bean: templateFieldInstance, field: 'validationRule', 'is-invalid')}" from="${validationRules}"
                                          value="${templateFieldInstance.validationRule}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="validationRule"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="template" class="col-md-2 form-label"><g:message code="templateField.template.label" default="Template"/></label>
                            <div class="col-md-6">
                                <g:select class="form-select ${hasErrors(bean: templateFieldInstance, field: 'template', 'is-invalid')}" name="template.id" from="${au.org.ala.volunteer.Template.list()}" optionKey="id"
                                          value="${templateFieldInstance?.template?.id}" noSelection="['null': '']"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="template"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="displayOrder" class="col-md-2 form-label"><g:message code="templateField.displayOrder.label" default="Display Order"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control ${hasErrors(bean: templateFieldInstance, field: 'displayOrder', 'is-invalid')}" name="displayOrder"
                                             value="${fieldValue(bean: templateFieldInstance, field: 'displayOrder')}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="displayOrder"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="category" class="col-md-2 form-label"><g:message code="templateField.category.label" default="Category"/></label>
                            <div class="col-md-6">
                                <g:select class="form-select ${hasErrors(bean: templateFieldInstance, field: 'category', 'is-invalid')}" name="category" from="${au.org.ala.volunteer.FieldCategory?.values()}"
                                          keys="${au.org.ala.volunteer.FieldCategory?.values()*.name()}"
                                          value="${templateFieldInstance?.category?.name()}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="category"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="type" class="col-md-2 form-label"><g:message code="templateField.type.label" default="Type"/></label>
                            <div class="col-md-6">
                                <g:select class="form-select ${hasErrors(bean: templateFieldInstance, field: 'type', 'is-invalid')}" name="type" from="${au.org.ala.volunteer.FieldType?.values()}"
                                          keys="${au.org.ala.volunteer.FieldType?.values()*.name()}"
                                          value="${templateFieldInstance?.type?.name()}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="type"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="layoutClass" class="col-md-2 form-label"><g:message code="templateField.layoutClass.label" default="Layout Class"/></label>
                            <div class="col-md-6">
                                <g:textField class="form-control ${hasErrors(bean: templateFieldInstance, field: 'layoutClass', 'is-invalid')}" name="layoutClass"
                                             value="${fieldValue(bean: templateFieldInstance, field: 'layoutClass')}"/>
                                <cl:fieldError bean="${templateFieldInstance}" field="layoutClass"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-9">
                                <g:actionSubmit class="btn btn-primary save" action="update"
                                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                                <g:actionSubmit class="btn btn-danger delete" action="delete"
                                                value="${message(code: 'default.button.delete.label', default: 'Delete')}"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:script type="text/javascript">
    // Bind tooltips when document is ready (non-jQuery):
    bvp.bindTooltips();

    $(function() {
        let deleteConfirmed = false;
        $('.delete').click(function(e) {
            if (deleteConfirmed) {
                return true;
            }
            e.preventDefault();
            const self = this;
            bvp.confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?', args: ['field'])}', function() {
                deleteConfirmed = true;
                $(self).click();
            });
        });
    });
</asset:script>

</body>
</html>
