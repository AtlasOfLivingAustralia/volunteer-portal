<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title>Project Administration</title>

        <r:script type="text/javascript">

            $(document).ready(function () {

                $("#searchButton").click(function (e) {
                    e.preventDefault();
                    doSearch();
                });

                $("#q").keypress(function (e) {
                    if (e.keyCode == 13) {
                        e.preventDefault();
                        doSearch();
                    }
                });

            }); // end .ready()

            function doSearch() {
                var query = $("#q").val()
                location.href = "?q=" + query;
            }

            function validateInSeparateWindow(taskId) {
                window.open("${createLink(controller:'validate', action:'task')}/" + taskId, "bvp_validate_window");
            }
        </r:script>
    </head>

    <body>

        <cl:headerContent title="Project Admin - ${projectInstance ? projectInstance.featuredLabel : 'Tasks'}" selectedNavItem="expeditions">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'list'), label: 'Expeditions'],
                    [link: createLink(controller: 'project', action: 'index', id: projectInstance?.id), label: projectInstance?.featuredLabel]
                ]
            %>

            <div>
                <cl:ifAdmin>
                    <button class="btn" style="float:left;margin:5px;" onclick="location.href = '${createLink(controller:'project', action:'edit', id:projectInstance.id)}'">Edit Project</button>
                    <button class="btn" style="float:left;margin:5px;" onclick="location.href = '${createLink(controller:'newsItem', action:'create', params:['project.id': projectInstance.id])}'">New News Item</button>
                    <button class="btn" style="float:left;margin:5px;" onclick="location.href = '${createLink(controller:'project', action:'mailingList', id:projectInstance.id)}'">Mailing List</button>
                    <button class="btn" style="float:left;margin:5px;" onclick="location.href = '${createLink(controller:'picklist', id:projectInstance.id)}'">Picklists</button>
                </cl:ifAdmin>
                <g:link style="color: white" class="btn btn-info pull-right" controller="user" action="myStats" id="${userInstance.id}" params="${['projectId': projectInstance.id]}">My Stats</g:link>
            </div>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <div class="alert alert-info">
                    Total Tasks: ${taskInstanceTotal},
                    Transcribed Tasks: ${Task.countByProjectAndFullyTranscribedByNotIsNull(projectInstance)},
                    Validated Tasks: ${Task.countByProjectAndFullyValidatedByNotIsNull(projectInstance)}
                    &nbsp;&nbsp;
                    <button class="btn btn-small" onclick="location.href = '${createLink(controller:'project', action:'exportCSV', id:projectInstance.id)}'">Export all</button>
                    <button class="btn btn-small" onclick="location.href = '${createLink(controller:'project', action:'exportCSV', id:projectInstance.id, params:[transcribed:true])}'">Export transcribed</button>
                    <button class="btn btn-small" onclick="location.href = '${createLink(controller:'project', action:'exportCSV', id:projectInstance.id, params:[validated:true])}'">Export validated</button>
                    <input class="input-small" style="margin-bottom: 0px" type="text" name="q" id="q" value="${params.q}" size="30"/>
                    <button class="btn btn-small btn-primary" id="searchButton">search</button>
                </div>
            </div>
        </div>
        <div class="row" id="content">
            <div class="span12">
                <table class="table table-striped table-condensed table-bordered">
                    <thead>
                        <tr>

                            <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'External Id')}" params="${[q: params.q]}"/>

                            <g:each in="${extraFields}" var="field"><th>${field.key?.capitalize().replaceAll(~/([a-z])([A-Z])/, '$1 $2')}</th></g:each>

                            <g:sortableColumn property="fullyTranscribedBy" title="${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}" params="${[q: params.q]}"/>

                            <g:sortableColumn property="fullyValidatedBy" title="${message(code: 'task.fullyValidatedBy.label', default: 'Fully Validated By')}" params="${[q: params.q]}"/>

                            <g:sortableColumn property="isValid" title="${message(code: 'task.isValid.label', default: 'Validation Status')}" params="${[q: params.q]}" style="text-align: center;"/>

                            <th style="text-align: center;">Action</th>

                        </tr>
                    </thead>
                    <tbody>
                        <g:each in="${taskInstanceList}" status="i" var="taskInstance">
                            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                                <td><g:link controller="task" action="show" id="${taskInstance.id}">${taskInstance.externalIdentifier}</g:link></td>

                                <g:each in="${extraFields}" var="field">
                                    <td>${field?.value[taskInstance.id]?.value?.getAt(0)}</td>
                                </g:each>

                                <td>
                                    <g:if test="${taskInstance.fullyTranscribedBy}">
                                        <g:set var="thisUser" value="${User.findByUserId(taskInstance.fullyTranscribedBy)}"/>
                                        <g:link controller="user" action="show" id="${thisUser.id}">${thisUser.displayName}</g:link>
                                    </g:if>
                                </td>

                                <td>
                                    <g:if test="${taskInstance.fullyValidatedBy}">
                                        <g:set var="thisUser" value="${User.findByUserId(taskInstance.fullyValidatedBy)}"/>
                                        <g:link controller="user" action="show" id="${thisUser.id}">${thisUser.displayName}</g:link>
                                    </g:if>
                                </td>

                                <td style="text-align: center;">
                                    <g:if test="${taskInstance.isValid == true}">&#10003;</g:if>
                                    <g:elseif test="${taskInstance.isValid == false}">&#10005;</g:elseif>
                                    <g:else>&#8211;</g:else>
                                </td>

                                <td style="text-align: center;">
                                    <g:if test="${taskInstance.fullyValidatedBy}">
                                        <g:link controller="validate" action="task" id="${taskInstance.id}">review</g:link>
                                        <button class="btn btn-mini" onclick="validateInSeparateWindow(${taskInstance.id})" title="Review task in a separate window"><img src="${resource(dir: '/images', file: 'right_arrow.png')}">
                                        </button>
                                    </g:if>
                                    <g:elseif test="${taskInstance.fullyTranscribedBy}">
                                        <button class="btn btn-small" onclick="location.href = '${createLink(controller:'validate', action:'task', id:taskInstance.id, params: params.clone())}'">validate</button>
                                        <button class="btn btn-small" onclick="validateInSeparateWindow(${taskInstance.id})" title="Validate in a separate window"><img src="${resource(dir: '/images', file: 'right_arrow.png')}">
                                        </button>
                                    </g:elseif>
                                    <g:else>
                                        <button class="btn btn-small" onclick="location.href = '${createLink(controller:'transcribe', action:'task', id:taskInstance.id, params: params.clone())}'">transcribe</button>
                                    </g:else>
                                </td>

                            </tr>
                        </g:each>
                    </tbody>
                </table>

                <div class="pagination">
                    <g:paginate total="${taskInstanceTotal}" id="${params?.id}" params="${[q: params.q]}"/>
                </div>
            </div>
        </div>
    </body>
</html>
