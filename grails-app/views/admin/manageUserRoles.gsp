<%@ page import="au.org.ala.volunteer.Institution" %>
<%@ page import="au.org.ala.volunteer.Role" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="au.org.ala.volunteer.BVPRole" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.user.role.label" default="Administration - User Roles"/></title>
    <asset:stylesheet src="label-autocomplete"/>
    <asset:stylesheet src="bootstrap-select.css" asset-defer="" />
    <style type="text/css">
        table {
            font-size: 0.9em;
        }
    </style>
    <asset:javascript src="bootstrap-select.js" asset-defer="" />
    <asset:script type="text/javascript">

        $(document).ready(function () {
            $('.s1').hide();
            $('.byinst').show();

            $("input:radio").click(function() {
                $('.s1').hide();
                $('.' + $(this).attr("value")).show();
            });

            $('#byproj').selectpicker();
        });

    </asset:script>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'user.role.label', default: 'User Role')}" selectedNavItem="bvpadmin">
<%
    pageScope.crumbs = [
        [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
    ]
%>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <h3>Add new User Role</h3>
            <p>
                This tool is to maintain users and specific roles within your institutions or expeditions as validators or forum moderators.<br>
                This section is for adding new users to roles.
                <a data-toggle="collapse" href="#collapseInstructions" aria-expanded="false"
                   aria-controls="collapseInstructions">Click here for instructions</a>.
            </p>
            <div class="collapse" id="collapseInstructions">
                <div class="panel panel-default panel-body">
                    <p>
                        To add a user to a new role:
                    </p>
                    <ol>
                        <li>Select the role type (validator or forum moderator)</li>
                        <li>Select the role level; Is this for the whole institution or just at an expedition level?</li>
                        <li>Select the specific institution or expedition for the role</li>
                        <li>
                            Enter the user's name.<br>
                            The username field will search available users and display results as you type. Once the desired name
                            is displayed, select the name.
                        </li>
                        <li>Click the Save button.</li>
                    </ol>
                    <p>
                        Please note: If a user has an institution-level role, they cannot have an expedition-level role of the
                        same type as the institution-level role covers all expeditions.
                    </p>
                </div>
            </div>
            <g:form controller="admin" action="addUserRole" method="POST">
            <div class="form-group">
                <div class="form-row">
                    <div class="form-group col-md-2">
                        <label for="userRole_role">Role Type</label>
                        <g:select name="userRole_role" from="${Role.findAllByNameInList([BVPRole.VALIDATOR, BVPRole.FORUM_MODERATOR])}"
                                  optionKey="id" class="selectpicker form-control" required="true" optionValue="name"
                                  noSelection="['':'- Select a Role -']" />
                    </div>
                    <div class="form-group col-md-2" style="white-space: nowrap;">
                        <label>Role Level</label>
                        <div style="margin-top: 5px;">
                            <label for="byInstitution">
                                <input name="opt" id="byInstitution" type="radio" value="byinst" checked="checked" />
                                Institution</label>

                            <label for="byProject">
                                <input name="opt" id="byProject" type="radio" value="byproj"/>
                                Expedition</label>
                        </div>
                    </div>
                    <div class="form-group col-md-5">
                        <label>Institution/Expedition</label>
                        <div class="s1 byinst">
                            <g:select class="form-control" name="institution" from="${institutionList}"
                                      optionKey="id" id="byinst" data-live-search="true"
                                      value="${params?.institution}" noSelection="['':'- Select an Institution -']"/>
                        </div>
                        <div class="s1 byproj">
                            <g:select name="project" from="${projectList}" id="byproj"
                                      optionKey="id" class="form-control selectpicker"
                                      optionValue="featuredLabel" data-live-search="true"
                                      noSelection="${['': '- Select an Expedition -']}" />
                        </div>
                    </div>
                    <div class="form-group col-md-3">
                        <label>User's Name</label>
                        <input class="form-control" id="user" type="text" placeholder="Enter user's name" value="${displayName}" required autocomplete="off"/>
                        <i id="ajax-spinner" class="fa fa-cog fa-spin hidden"></i>
                        <input id="userId" name="userId" type="hidden" value="${userId}"/>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-12">
                        <input type="submit" class="save btn btn-primary" id="addButton"
                               value="${message(code: 'default.button.add.label', default: 'Save')}"/>
                    </div>
                </div>
            </div>
            </g:form>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-body">
            <div id="maintain-message">

            </div>
            <h3>Maintain User Roles</h3>
            <p>
                This section allows Institution Administrators to manage the existing user roles within their institutions
                and expeditions. You can filter the roles by institution, expedition and/or by user.<br />
                <a data-toggle="collapse" href="#collapseInformation" aria-expanded="false"
                   aria-controls="collapseInformation">Click here for more information</a>.
            </p>
            <div class="collapse" id="collapseInformation">
                <div class="panel panel-default panel-body">
                    <ul>
                        <li><b>Filter by institution:</b> Select the institution to filter the roles by that institution.</li>
                        <li><b>Filter by expedition:</b> Type in a search term to search all expedition names within your
                        institutions that contain that term.</li>
                        <li><b>Filter by user:</b> Enter the user's name into the search field and potential results will be
                        displayed. Select the required user to filter roles for that particular user.</li>
                        <li>Click the Apply button to execute the filter criteria or the Reset button to reset all filters.</li>
                        <li>You can filter by one or more of these filters. Select/enter each filter and click the Apply button.</li>
                        <li><b>Note:</b> the number next to user's names is their internal DigiVol ID. This is to assist with identifying
                        between multiple users with the same name. You can obtain their ID from the URL in their user profile.</li>
                    </ul>
                </div>
            </div>

            <div class="row">
                <div class="col-md-4">
                    <g:select class="form-control" name="institution" id="institution" from="${institutionList}"
                              optionKey="id"
                              value="${params?.institution}" noSelection="['':'- Filter by Institution -']" />
                </div>
                <div class="col-md-3">
                    <input type="text" id="searchbox" class="form-control" value="${params.q}" placeholder="Filter by Expedition..."/>
                </div>
                <div class="col-md-3">
                    <input type="text" id="user-searchbox" class="form-control" value="${displayUserFilter}" placeholder="Filter by User..." autocomplete="off"/>
                    <input id="filter-userId" name="filterUserId" type="hidden" value="${filterUserId}"/>
                    <i id="ajax-filter-spinner" class="fa fa-cog fa-spin hidden"></i>
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-default bs3" id="apply-filter">Apply</button>
                    <a class="btn btn-default bs3"
                       href="${createLink(controller: 'admin', action: 'manageUserRoles')}">Reset</a>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    <small>${userRoleTotalCount ?: 0} User roles found.</small>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <th style="width: 12%; text-wrap: none !important;"><span><g:message code="admin.user.role.name.label" default="Name" /></span></th>
                            <th><span><g:message code="admin.user.role.role.label" default="Role" /></span></th>
                            <th><span><g:message code="admin.user.role.level.label" default="Role Level" /></span></th>
                            <th style="width: 45%;"><span><g:message code="admin.user.role.level.name.label" default="Institution/Expedition" /></span></th>
                            <th style="width: 12%; text-wrap: none !important;"><span><g:message code="admin.user.role.createdby.label" default="Added By" /></span></th>
                            <th style="width: 12%; text-wrap: none !important;"><span><g:message code="admin.user.role.dateadded.label" default="Date Added" /></span></th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${userRoleList}" var="userRole" status="i">
                            <tr id="userRole_${userRole.id}">

                                <td class="role-user" style="white-space: nowrap;">${userRole.user?.displayName} <span style="color: #bbbbbb;">(${userRole.user?.id})</span></td>
                                <td class="role-name"><g:if test="${userRole.role.name == BVPRole.FORUM_MODERATOR}">Forum Moderator</g:if><g:else>Validator</g:else></td>
                                <td class="role-level"><g:if test="${userRole.project}">Expedition</g:if><g:else>Institution</g:else></td>
                                <td class="role-level-name">
                                    <g:if test="${userRole.project}">
                                        <g:link controller="project" action="editGeneralSettings" id="${userRole.project.id}">${userRole.project.name}</g:link>
                                    </g:if>
                                    <g:elseif test="${userRole.institution}">
                                        <g:link controller="institutionAdmin" action="edit" id="${userRole.institution.id}">${userRole.institution.name}</g:link>
                                    </g:elseif>
                                </td>
                                <td style="white-space: nowrap;">${userRole.createdBy?.displayName}</td>
                                <td style="white-space: nowrap;"><g:formatDate format="yyyy-MM-dd HH:mm" date="${userRole.dateCreated}"/></td>
                                <td>
                                    <button class="btn btn-danger deleteRole"
                                            userRoleId="${userRole.id}">
                                        <i class="fa fa-times" title="Delete Role from User"></i>
                                    </button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${userRoleTotalCount ?: 0}" action="manageUserRoles" params="${params}"/>
                    </div>
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

    labelAutocomplete("#user-searchbox", url, '#ajax-filter-spinner', function(item) {
        $('#filter-userId').val(item.id);
        console.log(item.id);
        console.log($('#filter-userId').val());
        return null;
    }, 'displayName');

    $(".deleteRole").click(function (e) {
        e.preventDefault();
        let id = $(this).attr("userRoleId");
        const roleLevel = $(this).closest('tr').find('.role-level').html().trim();
        let roleUser = $(this).closest('tr').find('.role-user').clone();
        roleUser = $.trim($("span", roleUser).remove().end().html());
        const roleName = $(this).closest('tr').find('.role-name').html().trim();
        let roleLevelName = $(this).closest('tr').find('.role-level-name').find('a').html();
        console.log("ID: " + id);

        if (id) {
            let confirmMsg = 'Are you sure you wish to delete the '+ roleLevel +' '+ roleName +' role for ' +
                roleUser + (roleLevelName ? ' and the '+ roleLevel + ' "' + roleLevelName + '"?' : '');

            bootbox.confirm(confirmMsg, function(result) {
                if (result) {
                    const params = new URLSearchParams(window.location.search);
                    let url = "${createLink(controller: 'admin', action: 'deleteUserRole').encodeAsJavaScript()}";
                    let institution = params.get('institution');
                    if (institution !== "" && institution !== undefined && institution !== null) {
                        url += "?institution=" + institution + "&userRoleId=" + id;
                    } else {
                        url += "?userRoleId=" + id;
                    }
                    console.log("url: " + url);
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

    $("#searchbox").keydown(function(e) {
        if (e.keyCode === 13) {
            doSearch();
        }
    });

    $("#user-searchbox").keydown(function(e) {
        if (e.keyCode === 13) {
            doSearch();
        }
    });

    $('#apply-filter').click(function(e) {
        e.preventDefault();
        doSearch();
    });

    function doSearch() {
        const params = new URLSearchParams(window.location.search);
        let institutionId = params.get('institution');
        let userId = params.get('userid');
        let q = params.get('q');

        console.log($('#filter-userId').val());

        institutionId = $('#institution').val();
        q = encodeURIComponent($('#searchbox').val());
        userId = $('#filter-userId').val();
        console.log();
        console.log(userId);

        let hasParams = false;
        let url = "${createLink(controller: 'admin', action: 'manageUserRoles')}?";

        if (institutionId) {
            url += "institution=" + institutionId;
            if (!hasParams) hasParams = true;
        }
        if (userId) {
            if (hasParams) {
                url += "&";
            }
            url += "userid=" + userId;
            if (!hasParams) hasParams = true;
        }
        if (q) {
            if (hasParams) {
                url += "&";
            }
            url += "q=" + q;
            if (!hasParams) hasParams = true;
        }

        //console.log(url);
        window.location = url;
    }

});
</asset:script>
</body>
</html>