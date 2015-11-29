<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'picklistItem.label', default: 'PicklistItem')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: "default.show.label", args: [entityName])}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'picklist', action: 'manage'), label: message(code: 'manage.picklists.label', default: 'Manage picklists')],
                    [link: createLink(controller: 'picklist', action: 'list'), label: message(code: 'default.list.label', args: ['Picklist'])],
                    [link: createLink(controller: 'picklist', action: 'show', id:picklistItemInstance.picklist?.id), label: message(code: 'default.show.label', args: ["Picklist - ${picklistItemInstance.picklist?.uiLabel}"])]
            ]
        %>
    </cl:headerContent>
    %{--<div class="nav">--}%
        %{--<span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>--}%
        %{--</span>--}%
        %{--<span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label"--}%
                                                                               %{--args="[entityName]"/></g:link></span>--}%
        %{--<span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label"--}%
                                                                                   %{--args="[entityName]"/></g:link></span>--}%
    %{--</div>--}%

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12" >
                    <form class="form-horizontal">
                        <g:hiddenField name="id" value="${picklistItemInstance?.id}"/>
                        <div class="form-group">
                            <label for="picklistItemInstance.id" class="control-label col-md-2"><g:message code="picklistItem.id.label" default="Id"/></label>
                            <div class="col-md-10">
                                <p class="form-control-static" id="picklistItemInstance.id">${picklistItemInstance.id}</p>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="picklistItemInstance.key" class="control-label col-md-2"><g:message code="picklistItem.key.label" default="Key"/></label>
                            <div class="col-md-10">
                                <p class="form-control-static" id="picklistItemInstance.key">${picklistItemInstance.key}</p>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="picklistItemInstance.picklist" class="control-label col-md-2"><g:message code="picklistItem.picklist.label" default="Picklist"/></label>
                            <div class="col-md-10">
                                <p class="form-control-static" id="picklistItemInstance.picklist">${picklistItemInstance.picklist}</p>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="picklistItemInstance.value" class="control-label col-md-2"><g:message code="picklistItem.value.label" default="Value"/></label>
                            <div class="col-md-10">
                                <p class="form-control-static" id="picklistItemInstance.value">${picklistItemInstance.value}</p>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-10">
                                <span class="button"><g:actionSubmit class="btn btn-default" action="edit"
                                                                     value="${message(code: 'default.button.edit.label', default: 'Edit')}"/></span>
                                <span class="button"><g:actionSubmit class="btn btn-danger" action="delete"
                                                                     value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                                     onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/></span>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
