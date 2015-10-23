<%@ page import="au.org.ala.volunteer.DarwinCoreField; au.org.ala.volunteer.Picklist" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'picklist.label', default: 'Picklist')}"/>
    <title><g:message code="default.create.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: "default.create.label", args: [entityName])}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'picklist', action: 'manage'), label: message(code: 'manage.picklists.label', default: 'Manage picklists')],
            ]
        %>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${picklistInstance}">
                        <div class="errors">
                            <g:renderErrors bean="${picklistInstance}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form action="save" class="form-horizontal">
                        <div class="form-group ${hasErrors(bean: picklistInstance, field: 'name', 'has-error')}">
                            <label class="control-label col-md-2" for="name"><g:message code="picklist.name.label" default="Name"/></label>
                            <div class="col-md-4">
                                <g:select name="name" class="form-control" from="${DarwinCoreField.values().sort({ it.name() })}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: picklistInstance, field: 'fieldTypeClassifier', 'has-error')}">
                            <label class="control-label col-md-2" for="fieldTypeClassifier"><g:message
                                    code="picklist.fieldTypeClassifier.label" default="Classifier"/></label>

                            <div class="col-md-4">
                                <g:textField name="fieldTypeClassifier" class="form-control"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-8">
                            <g:submitButton class="btn btn-primary save" name="create"
                                            value="${message(code: 'default.button.create.label', default: 'Create')}"/>
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
