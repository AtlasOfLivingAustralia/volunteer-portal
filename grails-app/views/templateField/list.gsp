<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'templateField.label', default: 'TemplateField')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label"
                                                                               args="[entityName]"/></g:link></span>
</div>

<div class="inner">
    <h1><g:message code="default.list.label" args="[entityName]"/></h1>
    <cl:messages/>
    <div class="list">
        <table>
            <thead>
            <tr>

                <g:sortableColumn property="id" title="${message(code: 'templateField.id.label', default: 'Id')}"/>

                <g:sortableColumn property="fieldType"
                                  title="${message(code: 'templateField.fieldType.label', default: 'Field Type')}"/>

                <g:sortableColumn property="label"
                                  title="${message(code: 'templateField.label.label', default: 'Label')}"/>

                <g:sortableColumn property="category"
                                  title="${message(code: 'templateField.category.label', default: 'Category')}"/>

                <g:sortableColumn property="defaultValue"
                                  title="${message(code: 'templateField.defaultValue.label', default: 'Default Value')}"/>

                <g:sortableColumn property="mandatory"
                                  title="${message(code: 'templateField.displayOrder.label', default: 'Display Order')}"/>

                <g:sortableColumn property="template"
                                  title="${message(code: 'templateField.template.label', default: 'Template')}"/>

            </tr>
            </thead>
            <tbody>
            <g:each in="${templateFieldInstanceList}" status="i" var="templateFieldInstance">
                <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                    <td><g:link action="show"
                                id="${templateFieldInstance.id}">${fieldValue(bean: templateFieldInstance, field: "id")}</g:link></td>

                    <td>${fieldValue(bean: templateFieldInstance, field: "fieldType")} ${fieldValue(bean: templateFieldInstance, field: "fieldTypeClassifier")}</td>

                    <td>${fieldValue(bean: templateFieldInstance, field: "label")}</td>

                    <td>${fieldValue(bean: templateFieldInstance, field: "category")}</td>

                    <td>${fieldValue(bean: templateFieldInstance, field: "defaultValue")}</td>

                    <td>${fieldValue(bean: templateFieldInstance, field: "displayOrder")}</td>

                    <td>${fieldValue(bean: templateFieldInstance, field: "template")}</td>

                </tr>
            </g:each>
            </tbody>
        </table>
    </div>

    <div class="paginateButtons">
        <g:paginate total="${templateFieldInstanceTotal}"/>
    </div>
</div>
</body>
</html>
