<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.admin.label', default:'Admin')}">
            <small class="muted">Version ${grailsApplication.metadata['app.version']}.${grailsApplication.metadata['app.buildNumber']}&nbsp;(built ${grailsApplication.metadata['app.buildDate']}&nbsp;${grailsApplication.metadata['app.buildProfile']})</small>
        </cl:headerContent>


        <div class="row">
            <div class="span12">

                <table class="table table-condensed">
                    <thead>
                        <tr>
                            <th style="text-align: left">Tool</th>
                            <th style="text-align: left">Description</th>
                        </tr>
                    </thead>
                    <tr>
                        <td>
                            <button class="btn" onclick="location.href = '${createLink(controller:'project', action:'createNewProject')}'">Create New Expedition</button>
                        </td>
                        <td>Create a new ${message(code:'default.application.name')} Expedition</td>
                    </tr>
                    <tr>
                        <td>
                            <button class="btn" onclick="location.href = '${createLink(controller:'template', action:'list')}'">Templates</button>
                        </td>
                        <td>Manage expedition templates and their fields</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'picklist', action:'manage')}'">Bulk manage picklists</button></td>
                        <td>Allows modification to the values held in various picklists</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'validationRule', action:'list')}'">Validation Rules</button></td>
                        <td>Manage transcription validation rules</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'frontPage', action:'edit')}'">Configure front page</button></td>
                        <td>Configure the appearance of the front page</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'stats', action:'index')}'">Stats</button></td>
                        <td>Various Statistics (Experimental!)</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'admin', action:'tutorialManagement')}'">Tutorial files</button></td>
                        <td>Manage tutorial files</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'admin', action:'tools')}'">Tools</button></td>
                        <td>Tools</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'institutionAdmin', action:'index')}'">Manage Institutions</button></td>
                        <td>Manage Institutions</td>
                    </tr>

                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'setting', action:'index')}'">Advanced Settings</button></td>
                        <td>Advanced Settings</td>
                    </tr>
                    <tr>
                        <td>Admin reports</td>
                        <td>
                            <button class="btn" title="Display a list of email address for all volunteers" onclick="location.href = '${createLink(controller:'admin', action:'mailingList')}'">Global mailing List</button>
                            <button class="btn" title="Users and their various counts and last activity etc..." onclick="location.href = '${createLink(controller:'ajax', action:'userReport', params: [wt: 'csv'])}'">User report</button>
                            <button class="btn" title="A summary of recent user activity" onclick="location.href = '${createLink(controller:'admin', action:'currentUsers')}'">Current users</button>
                        </td>
                    </tr>

                </table>

            </div>
        </div>
        <br/>
    </body>
</html>
