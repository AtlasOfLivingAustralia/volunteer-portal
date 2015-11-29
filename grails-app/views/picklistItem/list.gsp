<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'picklistItem.label', default: 'PicklistItem')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: "default.list.label", args: [entityName])}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'picklist', action: 'manage'), label: message(code: 'manage.picklists.label', default: 'Manage picklists')],
                    [link: createLink(controller: 'picklist', action: 'list'), label: message(code: 'default.list.label', args: ['Picklist'])],
                    [link: createLink(controller: 'picklist', action: 'show', id:params.id), label: message(code: 'default.show.label', args: ["Picklist - ${picklistInstance?.uiLabel}"])]
            ]
        %>
    </cl:headerContent>
    <cl:messages/>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12" >
                    <table class="table-striped table-condensed table-hover">
                        <thead>
                        <tr>

                            <g:sortableColumn property="id" title="${message(code: 'picklistItem.id.label', default: 'Id')}"/>

                            <g:sortableColumn property="key" title="${message(code: 'picklistItem.key.label', default: 'Key')}"/>

                            <th><g:message code="picklistItem.picklist.label" default="Picklist"/></th>

                            <g:sortableColumn property="value"
                                              title="${message(code: 'picklistItem.value.label', default: 'Value')}"/>

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${picklistItemInstanceList}" status="i" var="picklistItemInstance">
                            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                                <td><g:link action="show"
                                            id="${picklistItemInstance.id}">${picklistItemInstance?.id}</g:link></td>

                                <td>${picklistItemInstance?.key}</td>

                                <td>${picklistItemInstance?.picklist}</td>

                                <td>${picklistItemInstance?.value}</td>

                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${picklistItemInstanceTotal}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>


</div>
</body>
</html>
