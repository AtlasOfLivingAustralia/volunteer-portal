<%@ page import="au.org.ala.volunteer.TemplateField" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'validationRule.label', default: 'Validation Rule')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.validationRuleList.label', default: 'Manage Validation Rules')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
            ]
        %>
        <a href="${createLink(action: 'addRule')}" class="btn btn-primary"><i
                class="icon-plus icon-white"></i>&nbsp;Add new rule</a>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover table-striped">
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
                                <td style="width: 90px;">
                                    <a href="${createLink(controller: 'validationRule', action: 'delete', id: rule.id)}"
                                       class="btn btn-xs btn-danger delete-button" title="Delete rule '${rule.name}"><i
                                            class="fa fa-remove"></i></a>
                                    <a href="${createLink(controller: 'validationRule', action: 'edit', id: rule.id)}"
                                       class="btn btn-default btn-xs" title="Edit rule '${rule.name}"><i class="fa fa-edit"></i></a>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                    <div class="pagination">
                        <g:paginate total="${totalCount}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:script>
    $(function() {
        $('a.delete-button').on('click', function(e) {
            e.preventDefault();
            var self = this;
            bootbox.confirm("Are you sure?", function (result) {
                _result = result;
                if(result) {
                    window.location.href = $(self).attr('href');
                }
            });
        });
    });
</asset:script>
</body>
</html>
