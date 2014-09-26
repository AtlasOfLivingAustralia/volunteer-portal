<%@ page import="au.org.ala.volunteer.User" %>

<html>
    <head>

        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}"/>
        <title>Volunteers</title>

        <r:script type="text/javascript">

            $(document).ready(function () {

                // Context sensitive help popups
                $("a.fieldHelp").qtip({
                    tip: true,
                    position: {
                        corner: {
                            target: 'topMiddle',
                            tooltip: 'bottomRight'
                        }
                    },
                    style: {
                        width: 400,
                        padding: 8,
                        background: 'white', //'#f0f0f0',
                        color: 'black',
                        textAlign: 'left',
                        border: {
                            width: 4,
                            radius: 5,
                            color: '#E66542'// '#E66542' '#DD3102'
                        },
                        tip: 'bottomRight',
                        name: 'light' // Inherit the rest of the attributes from the preset light style
                    }
                }).bind('click', function (e) {
                        e.preventDefault();
                        return false;
                    });

                $('#searchbox').bind('keypress', function (e) {
                    var code = (e.keyCode ? e.keyCode : e.which);
                    if (code == 13) {
                        doSearch();
                    }
                });

                $('#searchbox').focus();

            });

            doSearch = function () {
                var searchTerm = $('#searchbox').val()
                var link = "${createLink(controller: 'user', action: 'list')}?q=" + searchTerm
                window.location.href = link;
            };

        </r:script>
    </head>

    <body>

        <cl:headerContent crumbLabel="Volunteers" title="Volunteer transcribers">
            <%
                pageScope.crumbs = []
            %>
        </cl:headerContent>

        <div id="content" class="row">
            <div class="span12">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th colspan="5" style="text-align: right">
                                <span>
                                    <a style="vertical-align: middle;" href="#" class="fieldHelp" title="Enter search text here to show only members with matching names"><span class="help-container">&nbsp;</span>
                                    </a>
                                </span>
                                <g:textField style="margin-bottom: 0px" id="searchbox" value="${params.q}" name="searchbox" onkeypress=""/>
                                <button class="btn" onclick="doSearch()">Search</button>
                            </th>
                        </tr>
                        <tr>
                            <th></th>
                            <g:sortableColumn style="text-align: left" property="displayName" title="${message(code: 'user.user.label', default: 'Name')}" params="${[q: params.q]}"/>
                            <g:sortableColumn style="text-align: center" property="transcribedCount" title="${message(code: 'user.recordsTranscribedCount.label', default: 'Tasks completed')}" params="${[q: params.q]}"/>
                            <cl:ifValidator project="${null}">
                                <g:sortableColumn style="text-align: center" property="validatedCount" title="${message(code: 'user.transcribedValidatedCount.label', default: 'Tasks validated')}" params="${[q: params.q]}"/>
                            </cl:ifValidator>
                            <cl:ifNotValidator>
                                <th></th>
                            </cl:ifNotValidator>
                            <g:sortableColumn style="text-align: center" property="created" title="${message(code: 'user.created.label', default: 'A volunteer since')}" params="${[q: params.q]}"/>
                        </tr>
                    </thead>
                    <tbody>
                        <g:each in="${userInstanceList}" status="i" var="userInstance">
                            <tr>
                                <td><img src="http://www.gravatar.com/avatar/${userInstance.email.toLowerCase().encodeAsMD5()}?s=80" class="avatar"/>
                                </td>
                                <td style="width:300px;">
                                    <g:link controller="user" action="show" id="${userInstance.id}">${fieldValue(bean: userInstance, field: "displayName")}</g:link>
                                    <g:if test="${userInstance.userId == currentUser}">(that's you!)</g:if>
                                </td>
                                <td class="bold centertext">${fieldValue(bean: userInstance, field: "transcribedCount")}</td>
                                <td class="bold centertext">
                                    <cl:ifValidator project="${null}">
                                        ${userInstance?.validatedCount}
                                    </cl:ifValidator>
                                </td>
                                <td class="bold centertext"><prettytime:display date="${userInstance?.created}"/></td>
                            </tr>
                        </g:each>
                    </tbody>
                </table>
            </div>

            <div class="pagination">
                <g:paginate total="${userInstanceTotal}" id="${params.id}" params="${[q:params.q]}"/>
            </div>
        </div>

        <r:script type="text/javascript">
            $("th > a").addClass("btn")
            $("th.sorted > a").addClass("active")
        </r:script>
    </body>
</html>
