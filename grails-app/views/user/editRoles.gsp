<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
    <asset:script type="text/javascript">

        $(document).ready(function () {

            $(".deleteRole").click(function (e) {
                e.preventDefault();
                var id = $(this).attr("userRoleId");
                $("#selectedUserRoleId").val(id);
                $("#selectedUserRoleAction").val("delete");
                $("[name='rolesForm']").submit();
            });

            $("#update").click(function (e) {
                e.preventDefault();
                $("#selectedUserRoleAction").val("update");
                $("[name='rolesForm']").submit();
            });

            $("#addRole").click(function (e) {
                e.preventDefault();
                $("#selectedUserRoleAction").val("addRole");
                $("[name='rolesForm']").submit();
            });

        });

    </asset:script>
</head>

<body class="admin">
<cl:headerContent crumbLabel="Edit Roles" title="${message(code: 'user.editUser.edit_roles_for', args: cl.displayNameForUserId(id: userInstance.userId))}">
    <%
        pageScope.crumbs = []
        pageScope.crumbs << [link: createLink(controller: 'user', action: 'show', id: userInstance.id), label: cl.displayNameForUserId(id: userInstance.userId)]
        pageScope.crumbs << [link: createLink(controller: 'user', action: 'edit', id: userInstance.id), label: message(code: 'user.edit.edit_user')]
    %>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">

                    <g:form controller="user" action="updateRoles" id="${userInstance.id}" name="rolesForm">
                        <g:if test="${userInstance.userRoles?.size() == 0}">
                            <g:message code="user.editRoles.this_user_has_no_roles"/>
                        </g:if>
                        <g:hiddenField name="selectedUserRoleId" value="" id="selectedUserRoleId"/>
                        <g:hiddenField name="selectedUserRoleAction" value="" id="selectedUserRoleAction"/>
                        <table class="table table-hover table-striped">
                            <thead>
                            <tr>
                                <td>Role</td>
                                <td>Project</td>
                                <td></td>
                            </tr>
                            </thead>
                            <g:each in="${userInstance.userRoles}" var="userRole" status="i">
                                <tr>

                                    <td><g:select name="userRole_${userRole.id}_role" from="${roles}" optionKey="id" class="form-control"
                                                  optionValue="name" value="${userRole.role?.id}"></g:select></td>
                                    <td><g:select name="userRole_${userRole.id}_project" from="${projects}" optionKey="id" class="form-control"
                                                  optionValue="i18nName" value="${userRole.project?.id}"
                                                  noSelection="${[null: '<All Projects>']}"></g:select></td>
                                    <td>
                                        <button class="btn btn-danger deleteRole" userRoleId="${userRole.id}">
                                            <i class="icon-remove icon-white"></i>&nbsp;<g:message code="default.button.delete.label"/>
                                        </button>
                                    </td>

                                </tr>
                            </g:each>
                        </table>
                        <button class="btn btn-primary" id="update"><g:message code="default.button.update.label"/></button>
                        <button class="btn btn-default" id="addRole"><g:message code="user.editRoles.add_role"/></button>
                        <br/>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
