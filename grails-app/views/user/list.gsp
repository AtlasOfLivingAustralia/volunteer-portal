<%@ page import="au.org.ala.volunteer.User" %>

<html>
<head>

    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
    <title>Volunteers</title>

    <r:script type="text/javascript">

            doSearch = function () {
                var searchTerm = $('#searchbox').val()
                var link = "${createLink(controller: 'user', action: 'list')}?q=" + searchTerm
                window.location.href = link;
            };

    </r:script>
</head>

<body class="admin">

<cl:headerContent crumbLabel="Volunteers" title="Volunteer transcribers"  selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = []
    %>
</cl:headerContent>
<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <th colspan="5" style="text-align: right">
                                <cl:ifAdmin>
                                    <g:link controller="admin" action="updateUsers" class="btn btn-default pull-left">Update Users</g:link>
                                </cl:ifAdmin>
                                <div class="custom-search-input body">
                                    <div class="input-group">
                                        <g:textField id="searchbox" value="${params.q}" name="searchbox" class="form-control input-lg" placeholder="Search by name"/>
                                        <span class="input-group-btn">
                                            <button class="btn btn-info btn-lg" type="button" onclick="doSearch();">
                                                <i class="glyphicon glyphicon-search"></i>
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </th>
                        </tr>
                        <tr>
                            <th></th>
                            <g:sortableColumn style="text-align: left" property="displayName"
                                              title="${message(code: 'user.user.label', default: 'Name')}"
                                              params="${[q: params.q]}"/>
                            <g:sortableColumn style="text-align: center" property="transcribedCount"
                                              title="${message(code: 'user.recordsTranscribedCount.label', default: 'Tasks completed')}"
                                              params="${[q: params.q]}"/>
                            <cl:ifValidator project="${null}">
                                <g:sortableColumn style="text-align: center" property="validatedCount"
                                                  title="${message(code: 'user.transcribedValidatedCount.label', default: 'Tasks validated')}"
                                                  params="${[q: params.q]}"/>
                            </cl:ifValidator>
                            <cl:ifNotValidator>
                                <th></th>
                            </cl:ifNotValidator>
                            <g:sortableColumn style="text-align: center" property="created"
                                              title="${message(code: 'user.created.label', default: 'A volunteer since')}"
                                              params="${[q: params.q]}"/>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${userInstanceList}" status="i" var="userInstance">
                            <tr>
                                <td><img src="//www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=80"
                                         class="avatar"/>
                                </td>
                                <td style="width:300px;" class="text-left">
                                    <g:link controller="user" action="show" id="${userInstance.id}"><cl:displayNameForUserId
                                            id="${userInstance.userId}"/></g:link>
                                    <g:if test="${userInstance.userId == currentUser}">(that's you!)</g:if>
                                </td>
                                <td class="bold text-center">${fieldValue(bean: userInstance, field: "transcribedCount")}</td>
                                <td class="bold text-center">
                                    <cl:ifValidator project="${null}">
                                        ${userInstance?.validatedCount}
                                    </cl:ifValidator>
                                </td>
                                <td class="bold text-center"><prettytime:display date="${userInstance?.created}"/></td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>

                <div class="pagination">
                    <g:paginate total="${userInstanceTotal}" id="${params.id}" params="${[q: params.q]}"/>
                </div>
            </div>
        </div>
    </div>
</div>
<r:script type="text/javascript">
    $("th > a").addClass("btn")
    $("th.sorted > a").addClass("active")
</r:script>
</body>
</html>
