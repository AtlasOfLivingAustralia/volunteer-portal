<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.qtip-1.0.0-rc3.min.js')}"></script>
    <script type="text/javascript">

      $(document).ready(function() {

        $(".deleteRole").click(function (e) {
          e.preventDefault();
          var id = $(this).attr("userRoleId");
          $("#selectedUserRoleId").val(id);
          $("#selectedUserRoleAction").val("delete");
          $("[name='rolesForm']").submit();
        });

        $("#update").click(function(e) {
          e.preventDefault();
          $("#selectedUserRoleAction").val("update");
          $("[name='rolesForm']").submit();
        });

        $("#addRole").click(function(e) {
          e.preventDefault();
          $("#selectedUserRoleAction").val("addRole");
          $("[name='rolesForm']").submit();
        });

      });

    </script>
  </head>
  <body class="sublevel sub-site volunteerportal">
    <cl:navbar selected="" />
    <header id="page-header">
      <div class="inner">
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li><a href="${createLink(controller: 'user', action:'list')}">Volunteers</a></li>
            <li><a href="${createLink(controller: 'user', action:'show', id: userInstance.id)}">${fieldValue(bean: userInstance, field: "displayName")}</a></li>
            <li class="last">Roles</li>
          </ol>
        </nav>
        <h1>Roles for Volunteer: ${fieldValue(bean: userInstance, field: "displayName")} <g:if test="${userInstance.userId == currentUser}">(that's you!)</g:if></h1>
      </div><!--inner-->
    </header>

    <div class="inner">
      <g:form controller="user" action="updateRoles" id="${userInstance.id}" name="rolesForm" >
        <g:if test="${userInstance.userRoles?.size() == 0}">
          This user has no roles currently. Click 'Add role' to create a new role
        </g:if>
        <g:hiddenField name="selectedUserRoleId" value="" id="selectedUserRoleId"/>
        <g:hiddenField name="selectedUserRoleAction" value="" id="selectedUserRoleAction" />
        <table class="bvp-expedition">
          <thead>
            <tr>
              <td>Role</td>
              <td>Project</td>
              <td></td>
            </tr>
          </thead>
        <g:each in="${userInstance.userRoles}" var="userRole" status="i">
          <tr>

            <td><g:select name="userRole_${userRole.id}_role" from="${roles}" optionKey="id" optionValue="name" value="${userRole.role?.id}"></g:select> </td>
            <td><g:select name="userRole_${userRole.id}_project" from="${projects}" optionKey="id" optionValue="featuredLabel" value="${userRole.project?.id}" noSelection="${[null:'<All projects>']}"></g:select> </td>
            <td><button class="deleteRole" userRoleId="${userRole.id}">Delete</button></td>

          </tr>
        </g:each>
        </table>
        <button id="update">Update</button>
        <button id="addRole">Add Role</button>
        %{--<g:submitButton name="update" value="Update" />--}%
        <br />
      </g:form>
      %{--<g:form controller="user" action="addRole" id="${userInstance.id}">--}%
        %{--<g:submitButton name="addRole" value="Add Role" />--}%
      %{--</g:form>--}%

    </div>
  </body>
</html>
