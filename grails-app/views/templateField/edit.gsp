<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'templateField.label', default: 'TemplateField')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
    </head>
    <body class="sublevel sub-site volunteerportal">

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a class="home" href="${createLink(controller: 'template', action: 'list')}">Templates</a>
                        <li><a class="home" href="${createLink(controller: 'template', action: 'edit', id: templateFieldInstance.template.id)}">Edit ${templateFieldInstance.template.name}</a></li>
                        <li><a class="home" href="${createLink(controller: 'template', action: 'manageFields', id: templateFieldInstance.template.id)}">Manage Fields</a></li>
                        <li class="last">Edit field</li>
                    </ol>
                </nav>
                <hgroup>
                    <h1>Edit Template Field - ${templateFieldInstance.fieldType}</h1>
                </hgroup>
            </div>
        </header>

        <div class="inner">
            <g:hasErrors bean="${templateFieldInstance}">
            <div class="errors">
                <g:renderErrors bean="${templateFieldInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <g:hiddenField name="id" value="${templateFieldInstance?.id}" />
                <g:hiddenField name="version" value="${templateFieldInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="fieldType"><g:message code="templateField.fieldType.label" default="Field Type" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'fieldType', 'errors')}">
                                    <g:select name="fieldType" from="${au.org.ala.volunteer.DarwinCoreField?.values()}" keys="${au.org.ala.volunteer.DarwinCoreField?.values()*.name()}" value="${templateFieldInstance?.fieldType?.name()}"  />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="label"><g:message code="templateField.label.label" default="Label" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'label', 'errors')}">
                                    <g:textField name="label" value="${templateFieldInstance?.label}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="defaultValue"><g:message code="templateField.defaultValue.label" default="Default Value" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'defaultValue', 'errors')}">
                                    <g:textField name="defaultValue" maxlength="200" value="${templateFieldInstance?.defaultValue}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="mandatory"><g:message code="templateField.mandatory.label" default="Mandatory" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'mandatory', 'errors')}">
                                    <g:checkBox name="mandatory" value="${templateFieldInstance?.mandatory}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="multiValue"><g:message code="templateField.multiValue.label" default="Multi Value" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'multiValue', 'errors')}">
                                    <g:checkBox name="multiValue" value="${templateFieldInstance?.multiValue}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="helpText"><g:message code="templateField.helpText.label" default="Help Text" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'helpText', 'errors')}">
                                    <g:textArea name="helpText" cols="40" rows="5" value="${templateFieldInstance?.helpText}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="validationRule"><g:message code="templateField.validationRule.label" default="Validation Rule" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'validationRule', 'errors')}">
                                    <g:textField name="validationRule" value="${templateFieldInstance?.validationRule}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="template"><g:message code="templateField.template.label" default="Template" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'template', 'errors')}">
                                    <g:select name="template.id" from="${au.org.ala.volunteer.Template.list()}" optionKey="id" value="${templateFieldInstance?.template?.id}" noSelection="['null': '']" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="displayOrder"><g:message code="templateField.displayOrder.label" default="Display Order" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'displayOrder', 'errors')}">
                                    <g:textField name="displayOrder" value="${fieldValue(bean: templateFieldInstance, field: 'displayOrder')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="category"><g:message code="templateField.category.label" default="Category" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'category', 'errors')}">
                                    <g:select name="category" from="${au.org.ala.volunteer.FieldCategory?.values()}" keys="${au.org.ala.volunteer.FieldCategory?.values()*.name()}" value="${templateFieldInstance?.category?.name()}"  />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="type"><g:message code="templateField.type.label" default="Type" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: templateFieldInstance, field: 'type', 'errors')}">
                                    <g:select name="type" from="${au.org.ala.volunteer.FieldType?.values()}" keys="${au.org.ala.volunteer.FieldType?.values()*.name()}" value="${templateFieldInstance?.type?.name()}"  />
                                </td>
                            </tr>
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
