<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'validationRule.label', default: 'Validation Rule')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body>
<cl:headerContent title="${message(code: 'default.validationRuleList.label', default: 'Manage Validation Rules')}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
        ]
    %>
</cl:headerContent>
<div class="row">
    <div class="buttons" style="margin-bottom: 10px">
        <a href="${createLink(action: 'addRule')}" class="btn btn-primary"><i
                class="icon-plus icon-white"></i>&nbsp;Add new rule</a>
    </div>
    <table class="table table-bordered table-striped">
        <thead>
        <tr>
            <g:sortableColumn property="name" title="${message(code: 'validationRule.name.label', default: 'Rule')}"/>
            <g:sortableColumn property="regularExpression"
                              title="${message(code: 'validationRule.regularExpression.label', default: 'Pattern')}"/>
            <g:sortableColumn property="testEmptyValues"
                              title="${message(code: 'validationRule.testEmptyValues.label', default: 'Test empty values')}"/>
            <g:sortableColumn property="description"
                              title="${message(code: 'validationRule.description.label', default: 'Description')}"/>
            <g:sortableColumn property="message"
                              title="${message(code: 'validationRule.message.label', default: 'Message')}"/>
            <th/>
        </tr>
        </thead>
        <tbody>
        <g:each in="${validationRules}" status="i" var="rule">
            <tr>
                <td><g:link action="edit" id="${rule.id}">${rule.name}</g:link></td>
                <td>${rule.regularExpression}</td>
                <td>${rule.testEmptyValues ? 'Yes' : 'No'}</td>
                <td>${rule.description}</td>
                <td>${rule.message}</td>
                <td>
                    <a href="${createLink(controller: 'validationRule', action: 'delete', id: rule.id)}"
                       class="btn btn-mini btn-danger" title="Delete rule '${rule.name}"><i
                            class="icon-remove icon-white"></i></a>
                    <a href="${createLink(controller: 'validationRule', action: 'edit', id: rule.id)}"
                       class="btn btn-mini" title="Edit rule '${rule.name}"><i class="icon-edit"></i></a>
                </td>
            </tr>
        </g:each>
        </tbody>
    </table>
    <g:paginate total="${totalCount}"/>
</div>
</body>
</html>
