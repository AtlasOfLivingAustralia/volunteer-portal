<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'picklistItem.label', default: 'PicklistItem')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: "default.edit.label", args: [entityName])}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'picklist', action: 'manage'), label: message(code: 'manage.picklists.label', default: 'Manage picklists')],
                    [link: createLink(controller: 'picklist', action: 'list'), label: message(code: 'default.list.label', args: ['Picklist'])],
                    [link: createLink(controller: 'picklist', action: 'show', id:picklistItemInstance.picklist?.id), label: message(code: 'default.show.label', args: ["Picklist - ${picklistItemInstance.picklist?.uiLabel}"])]
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12" >
                    <g:hasErrors bean="${picklistItemInstance}">
                        <div class="alert alert-danger">
                            <g:renderErrors bean="${picklistItemInstance}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form method="post" class="form-horizontal">
                        <g:hiddenField name="id" value="${picklistItemInstance?.id}"/>
                        <g:hiddenField name="version" value="${picklistItemInstance?.version}"/>

                        <div class="form-group ${hasErrors(bean: picklistItemInstance, field: 'key', 'has-error')}">
                            <label for="key" class="control-label col-md-2"><g:message code="picklistItem.key.label" default="Key"/></label>
                            <div class="col-md-4">
                                <g:textField name="key" class="form-control" value="${picklistItemInstance?.key}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: picklistItemInstance, field: 'picklist', 'has-error')}">
                            <label for="picklist" class="control-label col-md-2"><g:message code="picklistItem.picklist.label" default="Picklist"/></label>
                            <div class="col-md-4">
                                <g:select name="picklist.id" class="form-control" from="${au.org.ala.volunteer.Picklist.list()}" optionKey="id"
                                          value="${picklistItemInstance?.picklist?.id}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: picklistItemInstance, field: 'value', 'has-error')}">
                            <label for="value" class="control-label col-md-2"><g:message code="picklistItem.value.label" default="Value"/></label>
                            <div class="col-md-4">
                                <g:textArea name="value" class="form-control" value="${picklistItemInstance?.value}" rows="5"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-10">
                                <span class="button"><g:actionSubmit class="save btn btn-default" action="update"
                                                                     value="${message(code: 'default.button.update.label', default: 'Update')}"/></span>
                                <span class="button"><g:actionSubmit class="delete btn btn-danger" action="delete"
                                                                     value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                                     onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/></span>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
