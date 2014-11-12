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
                            <a class="btn" href="${createLink(controller:'project', action:'createNewProject')}">Create New Expedition</a>
                        </td>
                        <td>Create a new ${message(code:'default.application.name')} Expedition</td>
                    </tr>
                    <tr>
                        <td>
                            <a class="btn" href="${createLink(controller:'template', action:'list')}">Templates</a>
                        </td>
                        <td>Manage expedition templates and their fields</td>
                    </tr>
                    <tr>
                        <td><a class="btn" href="${createLink(controller:'picklist', action:'manage')}">Bulk manage picklists</a></td>
                        <td>Allows modification to the values held in various picklists</td>
                    </tr>
                    <tr>
                        <td><a class="btn" href="${createLink(controller:'validationRule', action:'list')}">Validation Rules</a></td>
                        <td>Manage transcription validation rules</td>
                    </tr>
                    <tr>
                        <td><a class="btn" href="${createLink(controller:'frontPage', action:'edit')}">Configure front page</a></td>
                        <td>Configure the appearance of the front page</td>
                    </tr>
                    <tr>
                        <td><a class="btn" href="${createLink(controller:'stats', action:'index')}">Stats</a></td>
                        <td>Various Statistics (Experimental!)</td>
                    </tr>
                    <tr>
                        <td><a class="btn" href="${createLink(controller:'admin', action:'tutorialManagement')}">Tutorial files</a></td>
                        <td>Manage tutorial files</td>
                    </tr>
                    <tr>
                        <td><a class="btn" href="${createLink(controller:'admin', action:'tools')}">Tools</a></td>
                        <td>Tools</td>
                    </tr>
                    <tr>
                        <td><a class="btn" href="${createLink(controller:'institutionAdmin', action:'index')}">Manage Institutions</a></td>
                        <td>Manage Institutions</td>
                    </tr>

                    <tr>
                        <td><a class="btn" href="${createLink(controller:'setting', action:'index')}">Advanced Settings</a></td>
                        <td>Advanced Settings</td>
                    </tr>
                    <tr>
                        <td>Admin reports</td>
                        <td>
                            <a class="btn" title="Display a list of email address for all volunteers" href="${createLink(controller:'admin', action:'mailingList')}">Global mailing List</a>
                            <a class="btn" title="Users and their various counts and last activity etc..." href="${createLink(controller:'ajax', action:'userReport', params: [wt: 'csv'])}">User report</a>
                            <a class="btn" title="A summary of recent user activity" href="${createLink(controller:'admin', action:'currentUsers')}">Current users</a>
                            <a class="btn" title="List of all expeditions and their statistics" href="${createLink(controller:'admin', action:'projectSummaryReport')}">Expedition Summary Report</a>
                        </td>
                    </tr>

                </table>

            </div>
        </div>
        <br/>
    </body>
</html>
