<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
    </head>

    <body>

        <cl:headerContent title="Change setting value - ${settingDefinition.key}" crumbLabel="Edit Setting">
           <%
               pageScope.crumbs = [
                   [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                   [link: createLink(controller: 'setting', action: 'index'), label: 'Advanced Settings']
               ]
           %>
       </cl:headerContent>

        <div class="row">
            <div class="span12">
                <span class="lead">${settingDefinition?.description}</span>
                <g:form action="saveSetting">
                    <g:hiddenField name="settingKey" value="${settingDefinition?.key}" />
                    <g:textField style="margin-bottom: 0" name="settingValue" value="${currentValue}" />
                    <g:submitButton class="btn" name="save">Save</g:submitButton>
                </g:form>
            </div>
        </div>
    </body>
</html>
