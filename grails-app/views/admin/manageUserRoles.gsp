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
            <g:form controller="admin" action="addUserRole" method="POST">
            <div class="form-group">
                <div class="col-md-2">
                    <g:select name="userRole_role" from="${Role.findAllByNameInList([BVPRole.VALIDATOR, BVPRole.FORUM_MODERATOR])}"
                              optionKey="id" class="selectpicker form-control" required="true" optionValue="name"
                              noSelection="['':'- Select a Role -']" />
                </div>
                <div class="col-md-2">
                    <div style="margin-top: 5px;">
                        <label for="byInstitution">
                            <input name="opt" id="byInstitution" type="radio" value="byinst" checked="checked" />
                            Institution</label>

                        <label for="byProject">
                            <input name="opt" id="byProject" type="radio" value="byproj"/>
                            Project</label>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="s1 byinst custom-select">
                        <g:select class="form-control" name="institution" from="${institutionList}"
                                  optionKey="id" id="byinst" data-live-search="true"
                                  value="${params?.institution}" noSelection="['':'- Select an Institution -']"/>
                    </div>
                    <div class="s1 byproj custom-select">
                        <g:select name="project" from="${projectList}" id="byproj"
                                  optionKey="id" class="form-control"
                                  optionValue="featuredLabel" data-live-search="true"
                                  noSelection="${['': '- Select a Project -']}" />
                    </div>
                </div>
                <div class="col-md-3">
                    <input class="form-control" id="user" type="text" placeholder="Enter user's name" value="${displayName}" required autocomplete="off"/>
                    <i id="ajax-spinner" class="fa fa-cog fa-spin hidden"></i>
                    <input id="userId" name="userId" type="hidden" value="${userId}"/>
                </div>
                <div class="col-md-1">
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
            <h3>Maintain User Roles</h3>

            <div class="row">
                <div class="col-md-4">
                    <g:select class="form-control" name="institution" id="institution" from="${institutionList}"
                              optionKey="id"
                              value="${params?.institution}" noSelection="['':'- Filter by Institution -']" />
                </div>
                <div class="col-md-3">
                    <input type="text" id="searchbox" class="form-control" value="${params.q}" placeholder="Filter by Project..."/>
                </div>
                <div class="col-md-3">
                    <input type="text" id="user-searchbox" class="form-control" value="" placeholder="Filter by User..." autocomplete="off"/>
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
                    <small>${userRoleTotalCount ?: 0} Users found.</small>
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
                            <th style="width: 45%;"><span><g:message code="admin.user.role.level.name.label" default="Institution/Project" /></span></th>
                            <th style="width: 12%; text-wrap: none !important;"><span><g:message code="admin.user.role.createdby.label" default="Added By" /></span></th>
                            <th style="width: 12%; text-wrap: none !important;"><span><g:message code="admin.user.role.dateadded.label" default="Date Added" /></span></th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${userRoleList}" var="userRole" status="i">
                            <tr id="userRole_${userRole.id}">

                                <td>${userRole.user?.displayName}</td>
                                <td><g:if test="${userRole.role.name == BVPRole.FORUM_MODERATOR}">Forum Moderator</g:if><g:else>Validator</g:else></td>
                                <td><g:if test="${userRole.project}">Project</g:if><g:else>Institution</g:else></td>
                                <td>
                                    <g:if test="${userRole.project}">
                                        <g:link controller="project" action="editGeneralSettings" id="${userRole.project.id}">${userRole.project.name}</g:link>
                                    </g:if>
                                    <g:elseif test="${userRole.institution}">
                                        <g:link controller="institutionAdmin" action="edit" id="${userRole.institution.id}">${userRole.institution.name}</g:link>
                                    </g:elseif>
                                </td>
                                <td>${userRole.createdBy?.displayName}</td>
                                <td><g:formatDate format="yyyy-MM-dd HH:mm" date="${userRole.dateCreated}"/></td>
                                <td>
                                    <button class="btn btn-danger deleteRole" userRoleId="${userRole.id}">
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
<asset:script>
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
        var id = $(this).attr("userRoleId");

        $.ajax({
            url: "${createLink(controller: 'admin', action: 'deleteUserRole').encodeAsJavaScript()}" + "?userRoleId=" + id,
            success: function (data) {
                if (data.status == "success") {
                    $("#userRole_" + id).remove();
                    var alert = $('#maintain-message');
                    $('<div class="alert alert-info" style="margin-top:10px">User Role successfully deleted.</div>').insertBefore(alert)
                        .delay(4000).fadeOut();
                } else if (data.status == "error") {
                    var alert = $('#maintain-message');
                    $('<div class="alert alert-danger" style="margin-top:10px">' + data.message + '</div>').insertBefore(alert)
                        .delay(4000).fadeOut();
                }
            }
        });
    });

    $("#searchbox").keydown(function(e) {
        if (e.keyCode == 13) {
            doSearch();
        }
    });

    $("#user-searchbox").keydown(function(e) {
        if (e.keyCode == 13) {
            doUserSearch();
        }
    });

    $('#apply-filter').click(function(e) {
        e.preventDefault();
        doSearch();
    });

    function doSearch() {
        console.log(window.location.search);
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

        console.log(url);
        window.location = url;
    }

});
</asset:script>
</body>
</html>