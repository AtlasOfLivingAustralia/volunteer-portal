<%@ page import="au.org.ala.volunteer.Picklist" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: "default.list.label", args: [entityName])}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'picklist', action: 'manage'), label: message(code: 'manage.picklists.label', default: 'Manage picklists')],
            ]
        %>

        <a href="${createLink(controller: 'picklist', action: 'create')}" class="btn btn-success">Create a new Picklist</a>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">

            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="id" title="${message(code: 'picklist.id.label', default: 'Id')}"/>
                            <g:sortableColumn property="name" title="${message(code: 'picklist.name.label', default: 'Name')}"/>
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${picklistInstanceList}" var="picklistInstance">
                            <tr>
                                <td><g:link action="show"
                                            id="${picklistInstance.id}">${picklistInstance.id}</g:link></td>
                                <td>${picklistInstance.uiLabel}</td>
                                <td><g:link class="btn btn-default" controller="picklist" action="show"
                                            id="${picklistInstance.id}">View</g:link></td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${picklistInstanceTotal}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
