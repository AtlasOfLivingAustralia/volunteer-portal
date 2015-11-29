<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.label" default="Administration"/></title>
</head>

<body class="admin">

<cl:headerContent title="Change setting value - ${settingDefinition.key}" crumbLabel="Edit Setting" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                [link: createLink(controller: 'setting', action: 'index'), label: 'Advanced Settings']
        ]
    %>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <p class="lead">${settingDefinition?.description}</p>
                    <g:form action="saveSetting" class="form-horizontal">
                        <g:hiddenField name="settingKey" value="${settingDefinition?.key}"/>
                        <div class="col-md-4">
                            <g:textField class="form-control" name="settingValue" value="${currentValue}"/>
                        </div>
                        <g:submitButton class="btn btn-primary" name="save">Save</g:submitButton>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
