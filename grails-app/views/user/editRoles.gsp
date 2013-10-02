<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
        <title><g:message code="default.show.label" args="[entityName]"/></title>
        <r:script type="text/javascript">

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

        </r:script>
    </head>

    <body>
        <cl:headerContent crumbLabel="Volunteers" title="Edit Roles for ${userInstance.displayName}">
            <%
                pageScope.crumbs = []
                pageScope.crumbs << [link: createLink(controller: 'user', action: 'show', id: userInstance.id), label: userInstance.displayName]
            %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">

                <g:form controller="user" action="updateRoles" id="${userInstance.id}" name="rolesForm">
                    <g:if test="${userInstance.userRoles?.size() == 0}">
                        This user has no roles currently. Click 'Add role' to create a new role
                    </g:if>
                    <g:hiddenField name="selectedUserRoleId" value="" id="selectedUserRoleId"/>
                    <g:hiddenField name="selectedUserRoleAction" value="" id="selectedUserRoleAction"/>
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <td>Role</td>
                                <td>Project</td>
                                <td></td>
                            </tr>
                        </thead>
                        <g:each in="${userInstance.userRoles}" var="userRole" status="i">
                            <tr>

                                <td><g:select name="userRole_${userRole.id}_role" from="${roles}" optionKey="id" optionValue="name" value="${userRole.role?.id}"></g:select></td>
                                <td><g:select name="userRole_${userRole.id}_project" from="${projects}" optionKey="id" optionValue="featuredLabel" value="${userRole.project?.id}" noSelection="${[null: '<All Projects>']}"></g:select></td>
                                <td>
                                    <button class="btn btn-danger deleteRole" userRoleId="${userRole.id}">
                                    <i class="icon-remove icon-white"></i>&nbsp;Delete
                                    </button>
                                </td>

                            </tr>
                        </g:each>
                    </table>
                    <button class="btn btn-primary" id="update">Update</button>
                    <button class="btn" id="addRole">Add Role</button>
                    <br/>
                </g:form>
            </div>
        </div>
    </body>
</html>
