<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<table class="table table-striped table-condensed table-bordered">
    <thead>
    <tr>
        <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'External Id')}"
                          params="${[q: params.q, mode: params.mode]}"/>
        <g:sortableColumn property="fullyTranscribedBy"
                          title="${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}"
                          params="${[q: params.q, mode: params.mode]}"/>
        <g:sortableColumn property="fullyValidatedBy"
                          title="${message(code: 'task.fullyValidatedBy.label', default: 'Fully Validated By')}"
                          params="${[q: params.q, mode: params.mode]}"/>
        <g:sortableColumn property="isValid"
                          title="${message(code: 'task.isValid.label', default: 'Validation Status')}"
                          params="${[q: params.q, mode: params.mode]}" style="text-align: center;"/>
    </tr>
    </thead>
</table>

<ul class="thumbnails">
    <g:each in="${taskInstanceList}" status="i" var="taskInstance">
        <li class="span2">
            <div class="thumbnail">

                <div style="text-align: center;">
                    %{--<g:link controller="task" action="show" id="${taskInstance.id}">${taskInstance.externalIdentifier}</g:link>--}%
                </div>

                <div style="text-align: center">
                    <a href="${createLink(controller: 'task', action: 'showDetails', id: taskInstance.id)}">
                        <cl:taskThumbnail task="${taskInstance}"/>
                    </a>
                </div>

                <div style="text-align: center">
                    <g:if test="${taskInstance.fullyTranscribedBy}">
                        <g:if test="${taskInstance.isValid == true}">
                            <div class="badge badge-success">
                                <g:link controller="validate" action="task" id="${taskInstance.id}">&#10003;</g:link>
                            </div>
                        </g:if>
                        <g:elseif test="${taskInstance.isValid == false}">
                            <div class="badge badge-important">
                                <g:link controller="validate" action="task" id="${taskInstance.id}">&#10005;</g:link>
                            </div>
                        </g:elseif>
                        <g:else>
                            <div class="badge badge-info">
                                <g:link controller="validate" action="task" id="${taskInstance.id}">?</g:link>
                            </div>
                        </g:else>
                    </g:if>
                    <g:else>
                        <div class="label">
                            Not transcribed
                        </div>
                    </g:else>

                    <g:set var="lastView" value="${lockedMap[taskInstance.id]}"/>
                    <g:if test="${lastView}">
                        <i class="icon-lock lastViewedTask pull-right" title="Locked by ${lastView.userId}"
                           viewedTaskId="${lastView.id}"></i>
                    </g:if>
                </div>
            </div>
        </li>
    </g:each>
</ul>

<div class="pagination">
    <g:paginate total="${taskInstanceTotal}" id="${params?.id}" params="${[q: params.q, mode: params.mode]}"/>
</div>
