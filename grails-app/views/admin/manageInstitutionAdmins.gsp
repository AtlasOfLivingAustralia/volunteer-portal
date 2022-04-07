<%@ page import="au.org.ala.volunteer.Institution" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.institution-admin.label" default="Administration - Institution Admin"/></title>
    <asset:stylesheet src="label-autocomplete"/>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.institution-admin.label', default: 'Institution Admin')}" selectedNavItem="bvpadmin">
<%
    pageScope.crumbs = [
        [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
    ]
%>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <h3>Add new Institution Admin</h3>
            <p>
                Select the institution and enter the user's name or email address. The system will search for a users
                that match the search. <br>
                If no users appear, enter the email address and click the 'Add' button to search the ALA's CAS
                Authorisation system and import them into DigiVol.
            </p>
            <g:form controller="admin" action="addInstituionAdmin" method="POST">
            <div class="form-group">
                <div class="col-md-4">
                        <g:select class="form-control" name="institution" required="true" from="${Institution.listApproved([sort: 'name', order: 'asc'])}"
                                  optionKey="id"
                                  value="${params?.institution}" noSelection="['':'- Select an Institution -']"/>
                </div>
                <div class="col-md-4">
                    <input class="form-control" id="user" name="userSearch" type="text" placeholder="Search user..." value="${displayName}" required autocomplete="new-password"/>
                    <i id="ajax-spinner" class="fa fa-cog fa-spin hidden"></i>
                    <input id="userId" name="userId" type="hidden" value="${userId}"/>
                </div>
                <div class="col-md-3">
                    <input type="submit" class="save btn btn-default" id="addButton"
                           value="${message(code: 'default.button.add.label', default: 'Add')}"/>
                </div>
            </div>
            </g:form>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-body">
            <div id="maintain-message">

            </div>
            <h3>Maintain Institution Admins</h3>
            <div class="row">
                <div class="col-md-6">
                    <g:form controller="admin" action="manageInstitutionAdmins" method="GET">
                        <g:select class="form-control" name="institution" from="${Institution.listApproved([sort: 'name', order: 'asc'])}"
                                  optionKey="id"
                                  value="${params?.institution}" noSelection="['':'- Filter by Institution -']" onchange="submit()" />
                    </g:form>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <th><span><g:message code="admin.institution-admin.name.label" default="Name" /></span></th>
                            <th><span><g:message code="admin.institution-admin.institution.label" default="Institution" /></span></th>
                            <th><span><g:message code="admin.institution-admin.createdby.label" default="Added By" /></span></th>
                            <th><span><g:message code="admin.institution-admin.dateadded.label" default="Date Added" /></span></th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${institutionAdminRoles}" var="userRole" status="i">
                            <tr id="userRole_${userRole.id}">

                                <td class="role-user" width="20%">${userRole.user?.displayName}</td>
                                <td width="40%">${userRole.institution?.name}</td>
                                <td width="20%">${userRole.createdBy?.displayName}</td>
                                <td width="20%"><g:formatDate format="yyyy-MM-dd HH:mm" date="${userRole.dateCreated}"/></td>
                                <td witdth="10%">
                                    <button class="btn btn-danger deleteRole" userRoleId="${userRole.id}">
                                        <i class="fa fa-times"></i>
                                    </button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
</body>

<asset:javascript src="label-autocomplete" asset-defer=""/>
<asset:script type="text/javascript">
$(function($) {
    var url = "${createLink(controller: 'user', action: 'listUsersForJson')}";

    labelAutocomplete("#user", url, '#ajax-spinner', function(item) {
        $('#userId').val(item.userId);
        return null;
    }, 'displayName');

    $(".deleteRole").click(function (e) {
        e.preventDefault();
        var id = $(this).attr("userRoleId");
        const roleUser = $(this).closest('tr').find('.role-user').html().trim();

        if (id) {
            let confirmMsg = 'Are you sure you wish to delete the Institution Admin role for ' + roleUser + '?';

            bootbox.confirm(confirmMsg, function(result) {
                if (result) {
                    const params = new URLSearchParams(window.location.search);
                    let url = "${createLink(controller: 'admin', action: 'deleteUserRole').encodeAsJavaScript()}";
                    let institution = params.get('institution');
                    if (institution !== "" && institution !== undefined) {
                        url += "?institution=" + institution + "&userRoleId=" + id;
                    } else {
                        url += "?userRoleId=" + id;
                    }
                    window.location = url;
                }
            });
        } else {
            var alert = $('#maintain-message');
            $('<div class="alert alert-danger" style="margin-top:10px">Unable to delete User Role due to missing ' +
'                       information. Please contact DigiVol Admins.</div>').insertBefore(alert)
                .delay(4000).fadeOut();
        }
    });


});
</asset:script>
</body>
</html>