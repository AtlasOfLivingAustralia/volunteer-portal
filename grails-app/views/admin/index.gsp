<%@ page import="au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.admin.label', default:'Admin')}" />

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
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'admin', action:'mailingList')}'">Global mailing List</button></td>
                        <td>Display a list of email address for all volunteers</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'ajax', action:'userReport', params: [wt: 'csv'])}'">User report</button></td>
                        <td>Users and their various counts and last activity etc...</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'picklist', action:'manage')}'">Bulk manage picklists</button></td>
                        <td>Allows modification to the values held in various picklists</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'frontPage', action:'edit')}'">Configure front page</button></td>
                        <td>Configure the appearance of the front page</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'project', action:'create')}'">Create Expedition</button></td>
                        <td>Create a new Volunteer Expedition</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'collectionEvent', action:'load')}'">Load collection events</button></td>
                        <td>Load/Replace collection events for a particular institution</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'locality', action:'load')}'">Load localities</button></td>
                        <td>Load/Replace localities for a particular institution</td>
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
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'template', action:'list')}'">Templates</button></td>
                        <td>Manage project templates and their fields</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'validationRule', action:'list')}'">Validation Rules</button></td>
                        <td>Manage transcription validation rules</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'setting', action:'index')}'">Advanced Settings</button></td>
                        <td>Advanced Settings</td>
                    </tr>
                    <tr>
                        <td><button class="btn" onclick="location.href = '${createLink(controller:'task', action:'calculateDates')}'">Calculate Task Dates (one off)</button></td>
                        <td>Advanced Settings</td>
                    </tr>


                </table>

            </div>
        </div>
        <br/>
    </body>
</html>
