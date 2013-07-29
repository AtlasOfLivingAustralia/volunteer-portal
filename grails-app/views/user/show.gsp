<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'user.label', default: 'Volunteer')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>

    <r:script>

        $(document).ready(function () {
            // Context sensitive help popups
            $("a#gravitarLink").qtip({
                tip:true,
                position:{
                    corner:{
                        target:'bottomRight',
                        tooltip:'topLeft'
                    }
                },
                style:{
                    //width: 450,
                    padding:8,
                    background:'white', //'#f0f0f0',
                    color:'black',
                    textAlign:'left',
                    border:{
                        width:4,
                        radius:5,
                        color:'#E66542'// '#E66542' '#DD3102'
                    },
                    tip:'topLeft',
                    name:'light' // Inherit the rest of the attributes from the preset light style
                }
            });

            // Context sensitive help popups
            $("a.fieldHelp").qtip({
                tip:true,
                position:{
                    corner:{
                        target:'topMiddle',
                        tooltip:'bottomRight'
                    }
                },
                style:{
                    width:400,
                    padding:8,
                    background:'white', //'#f0f0f0',
                    color:'black',
                    textAlign:'left',
                    border:{
                        width:4,
                        radius:5,
                        color:'#E66542'// '#E66542' '#DD3102'
                    },
                    tip:'bottomRight',
                    name:'light' // Inherit the rest of the attributes from the preset light style
                }
            }).bind('click', function (e) {
                e.preventDefault();
                return false;
            });

            $('a[data-toggle="tab"]').on('click', function (e) {
                var tabIndex = $(this).attr('tabIndex');
                if (tabIndex) {
                    var url = "${createLink(action:'show', id:userInstance.id)}?selectedTab=" + tabIndex + "&projectId=${project?.id ?: ''}";
                    window.location.href = url;
                }
            });

        });

    </r:script>
</head>

<body>
    <cl:headerContent title="${fieldValue(bean: userInstance, field: "displayName")} ${userInstance.userId == currentUser ? "(that's you!)" : ''}" crumbLabel="${userInstance.displayName}">
        <%
            pageScope.crumbs = [
                [link: createLink(controller: 'user', action: 'list'), label: 'Volunteers']
            ]
        %>
    </cl:headerContent>

    <div class="row" id="content">
        <div class="span12">
            <table class="table">
                <tr>
                    <td style="padding-top:18px; width:150px;">
                        <img src="http://www.gravatar.com/avatar/${userInstance.userId.toLowerCase().encodeAsMD5()}?s=150" style="width:150px;" class="avatar"/>
                        <g:if test="${userInstance.userId == currentUser}">
                            <p>
                                <a href="http://en.gravatar.com/" class="external" target="_blank" id="gravitarLink" title="To customise this avatar, register your email address at gravatar.com...">Change avatar</a>
                            </p>
                        </g:if>
                    </td>
                    <td>
                        <table style="border: none; margin-top: 8px;">
                            <tbody>
                                <g:if test="${project}">
                                    <tr class="prop">
                                        <td valign="top" class="name"><g:message code="project.label" default="Project"/></td>
                                        <td valign="top" class="value">${project.featuredLabel} (<a href="${createLink(controller: 'user', action: 'show', id: userInstance.id)}">View tasks from all projects</a> )
                                        </td>
                                    </tr>
                                </g:if>
                                <tr class="prop">
                                    <td valign="top" class="name"><g:message code="user.score.label" default="Volunteer score"/></td>
                                    <td valign="top" class="value">${score}</td>
                                </tr>
                                <tr class="prop">
                                    <td valign="top" class="name"><g:message code="user.recordsTranscribedCount.label" default="Tasks Completed"/></td>
                                    <td valign="top" class="value">${totalTranscribedTasks} (${userInstance.validatedCount} validated)</td>
                                </tr>
                                <tr class="prop">
                                    <td valign="top" class="name"><g:message code="user.transcribedValidatedCount.label" default="Tasks validated"/></td>
                                    <td valign="top" class="value">${validatedCount}</td>
                                </tr>
                                <tr class="prop">
                                    <td valign="top" class="name"><g:message code="user.created.label" default="First contribution"/></td>
                                    <td valign="top" class="value">
                                        <prettytime:display date="${userInstance?.created}"/>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                    <td style="vertical-align: top" align="right">
                        <g:if test="${achievements.size() > 0}">
                            <table class="bvp-expeditions" style="margin:10px; border: 1px solid #d3d3d3;text-align: center; border-collapse: separate;" width="400px">
                                <thead>
                                    <tr><td colspan="5" style="border:none"><h3>Achievements</h3></td></tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <g:each in="${achievements}" var="ach" status="i">
                                                <div style="float:left;margin: 10px">
                                                    <img src='<g:resource file="${ach.icon}"/>' width="50px" alt="${ach.label}" title="${ach.description}"/>
                                                    %{--<div style="font:0.6em">${ach.label}</div>--}%
                                                </div>
                                            </g:each>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </g:if>
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <cl:ifAdmin>
                            <div class="alert alert-info" style="margin-bottom: 0px">
                            <g:link class="btn btn-small" controller="user" action="editRoles" id="${userInstance.id}">Manage user roles</g:link>
                            &nbsp;Email:&nbsp;<a href="mailto:${userInstance.userId}">${userInstance.userId}</a>
                            </div>
                        </cl:ifAdmin>
                    </td>
                </tr>
            </table>
        </div>

        <div class="span12">
            <div class="tabbable">
                <ul class="nav nav-tabs">
                    <li class="${selectedTab == 0 ? 'active' : ''}"><a href="#tabs0" data-toggle="tab" tabIndex="0"><strong>Transcribed Tasks</strong></a></li>
                    <li class="${selectedTab == 1 ? 'active' : ''}"><a href="#tabs1" data-toggle="tab" tabIndex="1"><strong>Saved Tasks</strong></a></li>
                    <cl:ifValidator>
                        <li class="${selectedTab == 2 ? 'active' : ''}"><a href="#tabs2" data-toggle="tab" tabIndex="2"><strong>Validated Tasks</strong></a></li>
                    </cl:ifValidator>
                    <li class="${selectedTab == 3 ? 'active' : ''}"><a href="#tabs3" data-toggle="tab" tabIndex="3"><strong>Forum messages</strong></a></li>
                </ul>
                <g:set var="includeParams" value="${params.findAll { it.key != 'selectedTab' }}"/>
                <div class="tab-content">
                    <div id="tabs0" class="tab-pane ${selectedTab == 0 ? 'active' : ''}">
                        <g:if test="${selectedTab == 0}">
                            <g:include action="taskListFragment" params="${includeParams + [projectId: project?.id]}"/>
                        </g:if>
                    </div>
                    <div id="tabs1" class="tab-pane ${selectedTab == 1 ? 'active' : ''}">
                        <g:if test="${selectedTab == 1}">
                            <g:include action="taskListFragment" params="${includeParams + [projectId: project?.id]}"/>
                        </g:if>
                    </div>
                    <div id="tabs2" class="tab-pane ${selectedTab == 2 ? 'active' : ''}">
                        <g:if test="${selectedTab == 2}">
                            <g:include action="taskListFragment" params="${includeParams + [projectId: project?.id]}"/>
                        </g:if>
                    </div>
                    <div id="tabs3" class="tab-pane ${selectedTab == 3 ? 'active' : ''}">
                        <g:if test="${selectedTab == 3}">
                            <g:include controller="forum" action="userCommentsFragment" params="${includeParams + [projectId: project?.id, userId: params.id]}"/>
                        </g:if>
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
