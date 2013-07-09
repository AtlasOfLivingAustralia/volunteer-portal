<%@ page import="au.org.ala.volunteer.Picklist" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>
    </head>

    <body>

        <cl:headerContent title="${message(code: "default.list.label", args: [entityName])}"/>

        <div id="content" class="row">
            <div class="span12">
                <table class="table table-bordered table-striped">
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
                                <td><g:link action="show" id="${picklistInstance.id}">${fieldValue(bean: picklistInstance, field: "id")}</g:link></td>
                                <td>${fieldValue(bean: picklistInstance, field: "name")}</td>
                                <td><g:link class="btn btn-small" controller="picklist" action="show" id="${picklistInstance.id}">View</g:link></td>
                            </tr>
                        </g:each>
                    </tbody>
                </table>

                <div class="pagination">
                    <g:paginate total="${picklistInstanceTotal}"/>
                </div>
            </div>
        </div>
    </body>
</html>
