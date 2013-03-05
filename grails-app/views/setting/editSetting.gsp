<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <style type="text/css">

            #buttonBar {
                margin-bottom: 10px;
            }

            .bvp-expeditions td button {
                margin-top: 5px;
            }

        </style>
        <script type='text/javascript'>

            $(document).ready(function() {
            });

        </script>
    </head>

    <body class="sublevel sub-site volunteerportal">

        <cl:navbar />

        <header id="page-header">
            <div class="inner">
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a class="home" href="${createLink(controller: 'admin', action: 'index')}"><g:message code="default.admin.label" default="Admin"/></a></li>
                        <li><a class="home" href="${createLink(controller: 'setting', action: 'index')}"><g:message code="default.advancedSettings.label" default="Advanced Settings"/></a></li>
                        <li class="last">Change setting</li>
                    </ol>
                </nav>
                <hgroup>
                    <h1>Change Setting Value - ${settingDefinition?.key}</h1>
                </hgroup>
            </div>
        </header>

        <div>
            <div class="inner">
                <cl:messages />
                <div id="buttonBar">
                </div>
                <h3>${settingDefinition?.key}</h3>
                <p>${settingDefinition?.description}</p>
                <g:form action="saveSetting">
                    <g:hiddenField name="settingKey" value="${settingDefinition?.key}" />
                    <g:textField name="settingValue" value="${currentValue}" />
                    <g:submitButton class="btn" name="save">Save</g:submitButton>
                </g:form>
            </div>
        </div>
    </body>
</html>
