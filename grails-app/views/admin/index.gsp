<%@ page import="java.text.DateFormat; au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.label" default="Administration"/></title>
</head>

<body class="admin">
<div class="container">

    <cl:headerContent title="${message(code: 'default.admin.label', default: 'Administration')}"
                      selectedNavItem="bvpadmin">
        <small class="muted">Version ${grailsApplication.metadata['app.version']}&nbsp;(built <cl:buildDate/>&nbsp;${grails.util.Environment.current}&nbsp;sha:&nbsp;<a
                href="https://github.com/AtlasOfLivingAustralia/volunteer-portal/commit/${grailsApplication.metadata['environment.TRAVIS_COMMIT']}">${grailsApplication.metadata['environment.TRAVIS_COMMIT']}</a>)
        </small>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 table-responsive">

                    <table class="table table-condensed table-striped table-hover admin-table">
                        <thead>
                        <tr>
                            <th>Tool</th>
                            <th>Description</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td>
                                <a class="btn btn-default bs3"
                                   href="${createLink(controller: 'project', action: 'wizard')}">Create New Expedition</a>
                            </td>
                            <td>Create a new ${message(code: 'default.application.name')} Expedition</td>
                        </tr>
                        <tr>
                            <td>
                                <a class="btn btn-default bs3"
                                   href="${createLink(controller: 'template', action: 'list')}">Templates</a>
                            </td>
                            <td>Manage expedition templates and their fields</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'picklist', action: 'manage')}">Bulk manage picklists</a>
                            </td>
                            <td>Allows modification to the values held in various picklists</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'validationRule', action: 'list')}">Validation Rules</a>
                            </td>
                            <td>Manage transcription validation rules</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'frontPage', action: 'edit')}">Configure front page</a>
                            </td>
                            <td>Configure the appearance of the front page</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'leaderBoardAdmin', action: 'index')}">Configure Honour Board</a>
                            </td>
                            <td>Configure the appearance of the Honour Board</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'stats', action: 'index')}">Stats</a></td>
                            <td>Various Statistics (Experimental!)</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'admin', action: 'tutorialManagement')}">Tutorial files</a>
                            </td>
                            <td>Manage tutorial files</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'admin', action: 'tools')}">Tools</a></td>
                            <td>Tools</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'institutionAdmin', action: 'index')}">Manage Institutions</a>
                            </td>
                            <td>Manage Institutions</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'achievementDescription', action: 'index')}">Manage Badges</a>
                            </td>
                            <td>Manage Achievements</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'label', action: 'index')}">Manage Tags</a></td>
                            <td>Manage Project Tags</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'setting', action: 'index')}">Advanced Settings</a>
                            </td>
                            <td>Advanced Settings</td>
                        </tr>
                        <tr>
                            <td>Admin reports</td>
                            <td>
                                <a class="btn btn-default bs3"
                                   title="Display a list of email address for all volunteers"
                                   href="${createLink(controller: 'admin', action: 'mailingList')}">Global mailing List</a>
                                <a class="btn btn-default bs3"
                                   title="Users and their various counts and last activity etc..."
                                   href="${createLink(controller: 'ajax', action: 'userReport', params: [wt: 'csv'])}">User report</a>
                                <a class="btn btn-default bs3" title="A summary of recent user activity"
                                   href="${createLink(controller: 'admin', action: 'currentUsers')}">Current users</a>
                                <a class="btn btn-default bs3" title="List of all expeditions and their statistics"
                                   href="${createLink(controller: 'admin', action: 'projectSummaryReport')}">Expedition Summary Report</a>
                            </td>
                        </tr>
                        </tbody>
                    </table>

                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
