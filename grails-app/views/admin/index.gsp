<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
  <title><g:message code="admin.label" default="Administration"/></title>
</head>
<body class="sublevel sub-site volunteerportal">
    <div class="nav">
      <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
      <span class="menuButton">Admin</span>
    </div>
    <div>
      <h2>Administration</h2>
      <div class="inner">
        <table class="bvp-expeditions">
          <thead>
            <tr>
              <th style="text-align: left">Tool</th>
              <th style="text-align: left">Description</th>
            </tr>
          </thead>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'admin', action:'mailingList')}'">Global mailing List</button></td>
            <td>Display a list of email address for all volunteers</td>
          </tr>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'ajax', action:'userReport', params: [wt: 'csv'])}'">User report</button></td>
            <td>Users and their various counts and last activity etc...</td>
          </tr>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'picklist', action:'manage')}'">Bulk manage picklists</button></td>
            <td>Allows modification to the values held in various picklists</td>
          </tr>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'frontPage', action:'edit')}'">Configure front page</button></td>
            <td>Configure the appearance of the front page</td>
          </tr>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'project', action:'create')}'">Create project</button></td>
            <td>Create a new volunteer project</td>
          </tr>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'collectionEvent', action:'load')}'">Load collection events</button></td>
            <td>Load/Replace collection events for a particular institution</td>
          </tr>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'locality', action:'load')}'">Load localities</button></td>
            <td>Load/Replace localities for a particular institution</td>
          </tr>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'stats', action:'index')}'">Stats</button></td>
            <td>Various Statistics (Experimental!)</td>
          </tr>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'admin', action:'reorganiseFileSystem')}'">Reorganize Filesystem</button></td>
            <td>One time only!</td>
          </tr>
          <tr>
            <td><button style="margin: 6px" onclick="location.href='${createLink(controller:'admin', action:'taskConsistencyReport')}'">Task consistency report</button></td>
            <td></td>
          </tr>

        </table>

      </div>
    </div>
    <br />
</body>
</html>
