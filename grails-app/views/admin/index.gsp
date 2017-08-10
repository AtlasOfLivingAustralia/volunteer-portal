<%@ page import="java.text.DateFormat; au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><cl:pageTitle title="${g.message(code:"admin.label", default:"Administration")}" /></title>
</head>

<body class="admin">
<div class="container">

    <cl:headerContent title="${message(code: 'default.admin.label', default: 'Administration')}"
                      selectedNavItem="bvpadmin">
        <small class="muted"><g:message code="admin.version" /> <g:meta name="info.app.version" />&nbsp;(<g:message code="admin.built" /> <cl:buildDate/>&nbsp;${grails.util.Environment.current}&nbsp;sha:&nbsp;<a
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
                            <th><g:message code="admin.tool" /></th>
                            <th><g:message code="admin.description" /></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td>
                                <a class="btn btn-default bs3"
                                   href="${createLink(controller: 'project', action: 'wizard')}"><g:message code="admin.create_new_expedition" /></a>
                            </td>
                            <td><g:message code="admin.create_a_new_expedition" /></td>
                        </tr>
                        <tr>
                            <td>
                                <a class="btn btn-default bs3"
                                   href="${createLink(controller: 'template', action: 'list')}"><g:message code="admin.templates" /></a>
                            </td>
                            <td><g:message code="admin.templates.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'picklist', action: 'manage')}"><g:message code="admin.bulk_manage_picklists" /></a>
                            </td>
                            <td><g:message code="admin.bulk_manage_picklists.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'validationRule', action: 'list')}"><g:message code="admin.validation_rules" /></a>
                            </td>
                            <td><g:message code="admin.validation_rules.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'frontPage', action: 'edit')}"><g:message code="admin.configure_front_page" /></a>
                            </td>
                            <td><g:message code="admin.configure_front_page.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'leaderBoardAdmin', action: 'index')}"><g:message code="admin.configure_honour_board" /></a>
                            </td>
                            <td><g:message code="admin.configure_honour_board.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'stats', action: 'index')}"><g:message code="admin.stats" /></a></td>
                            <td><g:message code="admin.various_statistics" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'admin', action: 'tutorialManagement')}"><g:message code="admin.tutorial_files" /></a>
                            </td>
                            <td><g:message code="admin.tutorial_files.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'admin', action: 'tools')}"><g:message code="admin.tools" /></a></td>
                            <td><g:message code="admin.tools.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'institutionAdmin', action: 'index')}"><g:message code="admin.manage_institutions" /></a>
                            </td>
                            <td><g:message code="admin.manage_institutions.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'achievementDescription', action: 'index')}"><g:message code="admin.manage_badges" /></a>
                            </td>
                            <td><g:message code="admin.manage_badges.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'label', action: 'index')}"><g:message code="admin.manage_tags" /></a></td>
                            <td><g:message code="admin.manage_tags.description" /></td>
                        </tr>
                        <tr>
                            <td><a class="btn btn-default bs3"
                                   href="${createLink(controller: 'setting', action: 'index')}"><g:message code="admin.advanced_settings" /></a>
                            </td>
                            <td><g:message code="admin.advanced_settings.description" /></td>
                        </tr>
                        <tr>
                            <td><g:message code="admin.admin_reports" /></td>
                            <td>
                                <a class="btn btn-default bs3"
                                   title="Display a list of email address for all volunteers"
                                   href="${createLink(controller: 'admin', action: 'mailingList')}"><g:message code="admin.global_mailing_list" /></a>
                                <a class="btn btn-default bs3"
                                   title="Users and their various counts and last activity etc..."
                                   href="${createLink(controller: 'ajax', action: 'userReport', params: [wt: 'csv'])}"><g:message code="admin.user_report" /></a>
                                <a class="btn btn-default bs3" title="A summary of recent user activity"
                                   href="${createLink(controller: 'admin', action: 'currentUsers')}"><g:message code="admin.current_users" /></a>
                                <a class="btn btn-default bs3" title="List of all expeditions and their statistics"
                                   href="${createLink(controller: 'admin', action: 'projectSummaryReport')}"><g:message code="admin.expedition_summary_report" /></a>
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
