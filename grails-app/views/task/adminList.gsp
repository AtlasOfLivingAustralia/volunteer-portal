<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
        <script type="text/javascript">
            $(document).ready(function() {
                $("#searchButton").click(function(e) {
                    e.preventDefault();
                    doSearch();
                });

                $("#q").keypress(function(e) {
                    if (e.keyCode == 13) {
                      e.preventDefault();
                      doSearch();
                    }
                });

            }); // end .ready()

            function doSearch() {
              var query = $("#q").val()
              location.href="?q=" + query;
            }

          function validateInSeparateWindow(taskId) {
            window.open("${createLink(controller:'validate', action:'task')}/" + taskId, "bvp_validate_window");
          }
        </script>
    </head>
    <body class="sublevel sub-site volunteerportal">

        <cl:navbar selected="expeditions" />

        <header id="page-header">
          <div class="inner">
            <nav id="breadcrumb">
              <ol>
                <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                <g:if test="${projectInstance}">
                  <li><g:link controller="project" action="index" id="${projectInstance.id}" class="crumb">${projectInstance.featuredLabel}</g:link></li>
                </g:if>
                <li class="last">Project Admin</li>
              </ol>
            </nav>
            <hgroup>
              <h1>Project Admin -
                <g:if test="${projectInstance}">
                    ${projectInstance.featuredLabel}
                </g:if>
                <g:else>
                    Tasks
                </g:else>
              </h1>
              <cl:ifAdmin>
                <button style="float:left;margin:5px;" onclick="location.href='${createLink(controller:'project', action:'edit', id:projectInstance.id)}'">Edit Project</button>
                <button style="float:left;margin:5px;" onclick="location.href='${createLink(controller:'newsItem', action:'create', params:['project.id': projectInstance.id])}'">New News Item</button>
                <button style="float:left;margin:5px;" onclick="location.href='${createLink(controller:'project', action:'mailingList', id:projectInstance.id)}'">Mailing List</button>
                <button style="float:left;margin:5px;" onclick="location.href='${createLink(controller:'picklist', id:projectInstance.id)}'">Picklists</button>
              </cl:ifAdmin>

            </hgroup>
          </div><!--inner-->
        </header>

        <div class="inner">
            <div style="margin: 8px 0 6px 0; clear: both;">
                Total Tasks: ${taskInstanceTotal},
                Transcribed Tasks: ${Task.countByProjectAndFullyTranscribedByNotIsNull(projectInstance)},
                Validated Tasks: ${Task.countByProjectAndFullyValidatedByNotIsNull(projectInstance)}
                <g:link controller="user" action="myStats" id="${userInstance.id}" params="${['projectId':projectInstance.id]}">My stats</g:link>
                &nbsp;&nbsp;
                <button onclick="location.href='${createLink(controller:'project', action:'exportCSV', id:projectInstance.id)}'">Export all</button>
                <button onclick="location.href='${createLink(controller:'project', action:'exportCSV', id:projectInstance.id, params:[transcribed:true])}'">Export transcribed</button>
                <button onclick="location.href='${createLink(controller:'project', action:'exportCSV', id:projectInstance.id, params:[validated:true])}'">Export validated</button>
                <input type="text" name="q" id="q" value="${params.q}" size="30"/>
                <button id="searchButton">search</button>
            </div>
          <div>

            <cl:messages />

            <div class="list">
                <table style="border-top: 2px solid #D9D9D9; width: 100%;">
                    <thead>
                        <tr>
                        
                            <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'External Id')}" params="${[q:params.q]}"/>
                        
                            <g:each in="${extraFields}" var="field"><th>${field.key?.capitalize().replaceAll(~/([a-z])([A-Z])/, '$1 $2')}</th></g:each>
                        
                            <g:sortableColumn property="fullyTranscribedBy" title="${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}" params="${[q:params.q]}"/>
                        
                            <g:sortableColumn property="fullyValidatedBy" title="${message(code: 'task.fullyValidatedBy.label', default: 'Fully Validated By')}" params="${[q:params.q]}"/>
                        
                            <g:sortableColumn property="isValid" title="${message(code: 'task.isValid.label', default: 'Validation Status')}" params="${[q:params.q]}" style="text-align: center;"/>

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
                                    <button onclick="validateInSeparateWindow(${taskInstance.id})" title="Review task in a separate window"><img src="${resource(dir:'/images', file:'right_arrow.png')}"></button>
                                </g:if>
                                <g:elseif test="${taskInstance.fullyTranscribedBy}">
                                    <button onclick="location.href='${createLink(controller:'validate', action:'task', id:taskInstance.id, params: params.clone())}'">validate</button>
                                    <button onclick="validateInSeparateWindow(${taskInstance.id})" title="Validate in a separate window"><img src="${resource(dir:'/images', file:'right_arrow.png')}"></button>
                                </g:elseif>
                                <g:else>
                                  <button onclick="location.href='${createLink(controller:'transcribe', action:'task', id:taskInstance.id, params: params.clone())}'">transcribe</button>
                                </g:else>
                            </td>

                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${taskInstanceTotal}" id="${params?.id}" params="${[q:params.q]}"/>
            </div>
          </div>
        </div>
    </body>
</html>
