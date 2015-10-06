<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'templateField.label', default: 'TemplateField')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body>

<cl:headerContent
        title="${message(code: 'default.edit.label', args: [entityName])} - ${templateFieldInstance.fieldType}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: ['Template'])],
                [link: createLink(controller: 'template', action: 'edit', id: templateFieldInstance.template.id), label: message(code: 'default.edit.label', args: ['Template'])],
                [link: createLink(controller: 'template', action: 'manageFields', id: templateFieldInstance.template.id), label: 'Manage Template Fields']
        ]
    %>
</cl:headerContent>

<div class="row">
    <div class="span12">
        <g:hasErrors bean="${templateFieldInstance}">
            <div class="errors">
                <g:renderErrors bean="${templateFieldInstance}" as="list"/>
            </div>
        </g:hasErrors>
        <g:form method="post">
            <g:hiddenField name="id" value="${templateFieldInstance?.id}"/>
            <g:hiddenField name="version" value="${templateFieldInstance?.version}"/>

            <table class="table">
                <tbody>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="fieldType"><g:message code="templateField.fieldType.label"
                                                          default="Field Type"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'fieldType', 'errors')}">
                        <g:select name="fieldType"
                                  from="${au.org.ala.volunteer.DarwinCoreField?.values()?.sort { it.name() }}"
                                  keys="${au.org.ala.volunteer.DarwinCoreField?.values()*.name()?.sort { it }}"
                                  value="${templateFieldInstance?.fieldType?.name()}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="fieldTypeClassifier"><g:message code="templateField.fieldTypeClassifier.label"
                                                                    default="Classifier"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'fieldTypeClassifier', 'errors')}">
                        <g:textField name="fieldTypeClassifier" value="${templateFieldInstance?.fieldTypeClassifier}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="label"><g:message code="templateField.label.label" default="Label"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'label', 'errors')}">
                        <g:textField name="label" value="${templateFieldInstance?.label}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="defaultValue"><g:message code="templateField.defaultValue.label"
                                                             default="Default Value"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'defaultValue', 'errors')}">
                        <g:textField name="defaultValue" maxlength="200"
                                     value="${templateFieldInstance?.defaultValue}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="mandatory"><g:message code="templateField.mandatory.label"
                                                          default="Mandatory"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'mandatory', 'errors')}">
                        <g:checkBox name="mandatory" value="${templateFieldInstance?.mandatory}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="multiValue"><g:message code="templateField.multiValue.label"
                                                           default="Multi Value"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'multiValue', 'errors')}">
                        <g:checkBox name="multiValue" value="${templateFieldInstance?.multiValue}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="helpText"><g:message code="templateField.helpText.label"
                                                         default="Help Text"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'helpText', 'errors')}">
                        <g:textArea name="helpText" cols="40" rows="5" value="${templateFieldInstance?.helpText}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="validationRule"><g:message code="templateField.validationRule.label"
                                                               default="Validation Rule"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'validationRule', 'errors')}">
                        <g:select name="validationRule" from="${validationRules}"
                                  value="${templateFieldInstance.validationRule}"/>
                        %{--<g:textField name="validationRule" value="${templateFieldInstance?.validationRule}" />--}%
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="template"><g:message code="templateField.template.label"
                                                         default="Template"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'template', 'errors')}">
                        <g:select name="template.id" from="${au.org.ala.volunteer.Template.list()}" optionKey="id"
                                  value="${templateFieldInstance?.template?.id}" noSelection="['null': '']"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="displayOrder"><g:message code="templateField.displayOrder.label"
                                                             default="Display Order"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'displayOrder', 'errors')}">
                        <g:textField name="displayOrder"
                                     value="${fieldValue(bean: templateFieldInstance, field: 'displayOrder')}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="category"><g:message code="templateField.category.label"
                                                         default="Category"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'category', 'errors')}">
                        <g:select name="category" from="${au.org.ala.volunteer.FieldCategory?.values()}"
                                  keys="${au.org.ala.volunteer.FieldCategory?.values()*.name()}"
                                  value="${templateFieldInstance?.category?.name()}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="type"><g:message code="templateField.type.label" default="Type"/></label>
                    </td>
                    <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'type', 'errors')}">
                        <g:select name="type" from="${au.org.ala.volunteer.FieldType?.values()}"
                                  keys="${au.org.ala.volunteer.FieldType?.values()*.name()}"
                                  value="${templateFieldInstance?.type?.name()}"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="type"><g:message code="templateField.type.layoutClass"
                                                     default="Layout Class"/></label>
                    </td>
                    <td valign="top"
                        class="value ${hasErrors(bean: templateFieldInstance, field: 'layoutClass', 'errors')}">
                        <g:textField name="layoutClass"
                                     value="${fieldValue(bean: templateFieldInstance, field: 'layoutClass')}"/>
                    </td>
                </tr>

                </tbody>
            </table>

            <div>
                <g:actionSubmit class="btn save" action="update"
                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                <g:actionSubmit class="btn btn-danger delete" action="delete"
                                value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
            </div>
        </g:form>
    </div>
</div>
</body>
</html>
