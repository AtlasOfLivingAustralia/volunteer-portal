<%@ page import="au.org.ala.volunteer.DarwinCoreField; au.org.ala.volunteer.Picklist" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}" />
        <title><g:message code="default.create.label" args="[entityName]" /></title>
    </head>
    <body>

        <cl:headerContent title="${message(code: "default.create.label", args: [entityName])}">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'picklist', action: 'manage'), label: message(code: 'manage.picklists.label', default:'Manage picklists')],
                    [link: createLink(controller: 'picklist', action: 'list'), label: message(code: 'default.list.label', args: [entityName])]
                ]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:hasErrors bean="${picklistInstance}">
                    <div class="errors">
                        <g:renderErrors bean="${picklistInstance}" as="list" />
                    </div>
                </g:hasErrors>
                <g:form action="save" class="form-horizontal">
                    <div class="control-group">
                        <label class="control-label" for="name"><g:message code="picklist.name.label" default="Name" /></label>
                        <div class="controls" ${hasErrors(bean: picklistInstance, field: 'name', 'errors')}>
                            <g:select name="name" from="${DarwinCoreField.values().sort({ it.name() })}"/>
                        </div>
                    </div>
                    <div class="control-group">
                        <label class="control-label" for="clazz"><g:message code="picklist.clazz.label" default="Class" /></label>
                        <div class="controls" ${hasErrors(bean: picklistInstance, field: 'clazz', 'errors')}>
                            <g:textField name="clazz" />
                        </div>
                    </div>
                    <div class="controls">
                        <g:submitButton class="btn btn-primary save" name="create" value="${message(code: 'default.button.create.label', default: 'Create')}" />
                    </div>
                </g:form>
            </div>
        </div>
    </body>
</html>
