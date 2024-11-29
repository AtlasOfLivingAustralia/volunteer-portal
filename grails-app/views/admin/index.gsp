<%@ page import="java.text.DateFormat; au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <title><cl:pageTitle title="${g.message(code:"admin.label", default:"Administration")}" /></title>

    <style>
        .btn-admin {
            border-radius: 5px;
            width: 200px;
        }

        .btn-primary {
            background-color: #5d8ab1 !important;
            border-color: #2e6da4 !important;
        }
    </style>

</head>

<body class="admin">
<div class="container">

    <cl:headerContent title="${message(code: 'default.admin.label', default: 'Administration')}"
                      selectedNavItem="bvpadmin">
        <small class="muted">Version <g:meta name="info.app.version" />&nbsp;(built <cl:buildDate/>&nbsp;${grails.util.Environment.current}&nbsp;sha:&nbsp;<a
                href="https://github.com/AtlasOfLivingAustralia/volunteer-portal/commit/${g.meta(name: 'info.git.commit')}"><g:meta name="info.git.commit" /></a>)
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
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'institutionAdmin', action: 'index')}">Manage Institutions</a>
                            </td>
                            <td>Manage Institutions</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'project', action: 'manage')}">Manage Expeditions</a>
                            </td>
                            <td>Download expedition images and remove from server, clone and edit expedition.</td>
                        </tr>
                        <tr>
                            <td>
                                <a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'project', action: 'create')}">Create new Expedition</a>
                            </td>
                            <td>Create a new ${message(code: 'default.application.name')} Expedition</td>
                        </tr>
                        <tr>
                            <td>
                                <a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'template', action: 'list')}">Templates</a>
                            </td>
                            <td>Manage expedition templates and their fields</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'picklist', action: 'manage')}">Bulk manage Picklists</a>
                            </td>
                            <td>Allows modification to the values held in various picklists</td>
                        </tr>
                        <cl:ifSiteAdmin>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'validationRule', action: 'list')}">Validation Rules</a>
                            </td>
                            <td>Manage transcription validation rules</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'frontPage', action: 'edit')}">Configure Front Page</a>
                            </td>
                            <td>Configure the appearance of the front page</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'landingPageAdmin', action: 'index')}">Configure Landing Page</a>
                            </td>
                            <td>Configure the appearance of a landing page</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'leaderBoardAdmin', action: 'index')}">Manage Leaderboard</a>
                            </td>
                            <td>Configure the appearance of the Honour Board</td>
                        </tr>
                        </cl:ifSiteAdmin>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'stats', action: 'index')}">Stats</a></td>
                            <td>Various Statistics (Experimental!)</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'admin', action: 'tutorialManagement')}">Tutorial Files</a>
                            </td>
                            <td>Manage tutorial files</td>
                        </tr>
                    <cl:ifSiteAdmin>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'admin', action: 'tools')}">Tools</a></td>
                            <td>Tools</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'user', action: 'adminList')}">Manage Users</a></td>
                            <td>List of all User accounts on DigiVol</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'user', action: 'listOptOut')}">Users Opted-Out</a></td>
                            <td>List of all Users who have opted-out of receiving Institution Messages</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'admin', action: 'manageInstitutionAdmins')}">Manage Institution Admins</a>
                            </td>
                            <td>Manage Institution Admins</td>
                        </tr>
                    </cl:ifSiteAdmin>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'admin', action: 'manageUserRoles')}">Manage User Roles</a>
                            </td>
                            <td>Manage User Roles, such as validators and forum moderators.</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'institutionMessage', action: 'index')}">Institution Messages</a>
                            </td>
                            <td>Create and send messages to volunteers of your institutions and expeditions.</td>
                        </tr>
                        <cl:ifSiteAdmin>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'achievementDescription', action: 'index')}">Manage Badges</a>
                            </td>
                            <td>Manage Achievements</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'label', action: 'index')}">Manage Tags</a></td>
                            <td>Manage Expedition Tags</td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'setting', action: 'index')}">Advanced Settings</a>
                            </td>
                            <td>Advanced Settings</td>
                        </tr>
                        </cl:ifSiteAdmin>
                        <tr>
                            <td><a class="btn btn-admin btn-primary bs3"
                                   href="${createLink(controller: 'report', action: 'index')}">DigiVol Reporting</a>
                            </td>
                            <td>Admin Reports</td>
                        </tr>
                        <tr>
                            <td>Admin reports</td>
                            <td>
                                <cl:ifSiteAdmin>
                                <a class="btn btn-admin btn-primary bs3"
                                   title="Users and their various counts and last activity etc..."
                                   href="${createLink(controller: 'ajax', action: 'userReport', params: [wt: 'csv'])}">User report</a>
                                <a class="btn btn-admin btn-primary bs3" title="A summary of recent user activity"
                                   href="${createLink(controller: 'admin', action: 'currentUsers')}">Current users</a>
                                </cl:ifSiteAdmin>
                                <a class="btn btn-admin btn-primary bs3" title="List of all expeditions and their statistics"
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
