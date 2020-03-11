<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>

    <asset:stylesheet src="bootstrap-select.css" asset-defer="" />
    <asset:javascript src="bootstrap-select.js" asset-defer="" />
    <asset:script type="text/javascript">

        $(document).ready(function () {

            $("#addRole").click(function (e) {
                e.preventDefault();
                var byOption = null;
                var selectedValue = null;
                var selectedRole = $('#userRole_role').val();
                if ($("#byProject").is(':checked')) {
                    byOption = 'project';
                    selectedValue = $("#byproj").val();
                } else if ($("#byInstitution").is(':checked')) {
                     byOption = 'institution';
                     selectedValue = $("#byinst").val();
                }
                if (selectedValue == 'none') {
                     bootbox.alert("Please select " + byOption + " or All " + byOption + "s");
                     return;
                } else {
                    $.ajax({
                        url: "${createLink(controller: 'user', action: 'addRoles').encodeAsJavaScript()}" + "?id=${userInstance.id}&byoption=" + byOption + "&selectedValue=" + selectedValue + "&role=" + selectedRole,
                        success: function (data) {
                            $("#userRolesForm").html(data);
                            setupListener();
                        }
                    });
                }

            });

            $('.s1').hide();
            $('.byinst').show();

            $("input:radio").click(function() {
                $('.s1').hide();
                $('.' + $(this).attr("value")).show();
            });

            var $newOption = $( "<option value='none'></option>");
            // var $newInstOption = $( "<option value=''>--- ALL INSTITUTIONS ---</option>");
            $('#byinst').prepend($newOption);
            $('#byinst').val('none');
            $('#byinst').selectpicker('refresh');

            //
            var $newNoProjOption = $( "<option value='none'></option>");
            // var $newProjOption = $( "<option value=''>--- ALL PROJECTS ---</option>");
            $('#byproj').prepend($newNoProjOption);
            $('#byproj').val('none');
            $('#byproj').selectpicker('refresh');

            function setupListener() {
                 $(".deleteRole").click(function (e) {
                    e.preventDefault();
                    var id = $(this).attr("userRoleId");
                    $("#selectedUserRoleId").val(id);

                   // $("[name='rolesForm']").submit();
                    $.ajax({
                        url: "${createLink(controller: 'user', action: 'deleteRoles').encodeAsJavaScript()}" + "?selectedUserRoleId=" + id + "&id=${userInstance.id}",
                        success: function (data) {
                            if (data.status == "success") {
                                $("#userRole_" + id).remove();
                            }
                       //     $("#userRolesForm").html(data);
                        }
                    });
                });

            }

            setupListener();

        });

    </asset:script>

 %{--   <style>
        .bootstrap-select .btn {
            border-radius: 5px;
        }

        .custom-select {
            position: absolute;
        }

        .bootstrap-select.btn-group .dropdown-toggle .filter-option {
            white-space: normal;
        }


    </style>
--}%
</head>

<body class="admin">
<cl:headerContent crumbLabel="Edit Roles" title="Edit Roles for ${cl.displayNameForUserId(id: userInstance.userId)}">
    <%
        pageScope.crumbs = []
        pageScope.crumbs << [link: createLink(controller: 'user', action: 'show', id: userInstance.id), label: cl.displayNameForUserId(id: userInstance.userId)]
        pageScope.crumbs << [link: createLink(controller: 'user', action: 'edit', id: userInstance.id), label: 'Edit User']
    %>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">

                    <div>
                        <table class="table">
                            <thead>
                            <tr>
                                <td>Role</td>
                                <td>Options</td>
                                <td class="s1 byproj">Project</td>
                                <td class="s1 byinst">Institution</td>
                                <td></td>
                            </tr>

                            </thead>
                            <tr>
                                <td width="20%"><g:select name="userRole_role" from="${roles}" optionKey="id" class="selectpicker form-control"
                                              optionValue="name" value="${roles?.get(0)?.id}"></g:select>
                                </td>
                                <td width="20%">
                                    <div>
                                        <label for="byInstitution">
                                            <input name="opt" id="byInstitution" type="radio" value="byinst" checked="checked" />
                                            Institution</label>

                                        <label for="byProject">
                                            <input name="opt" id="byProject" type="radio" value="byproj"/>
                                            Project</label>
                                    </div>
                                </td>

                                <td width="50%" class="s1 byinst custom-select"><g:select name="institution" id="byinst" from="${institutions}" optionKey="id" class="form-control selectpicker"
                                                                optionValue="name" data-live-search="true" noSelection="${[null: '<All Institutions>']}"></g:select></td>
                                <td width="50%" class="s1 byproj custom-select"><g:select name="project" from="${projects}" id="byproj" optionKey="id" class="selectpicker form-control"
                                                                optionValue="featuredLabel" data-live-search="true"
                                                                noSelection="${[null: '<All Projects>']}"></g:select></td>

                                <td width="10%" style="text-align: right;"><button class="btn btn-primary" id="addRole">Add Role</button></td>
                            </tr>

                        </table>
                    </div>

                    <h4>Current roles</h4>
                    <div id="userRolesForm" style="margin-top: 50px">
                        <g:render template="userRoles" model="[userInstance: userInstance]"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
