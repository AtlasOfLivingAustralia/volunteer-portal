<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<table class="table table-striped table-condensed">
    <thead>
    <tr>
        <g:sortableColumn property="id" style="padding: 0.9em;"
                          title="${message(code: 'task.id.label', default: 'External Id')}"
                          params="${[q: params.q, mode: params.mode]}"/>
        <th style="padding: 0.9em;" >${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}</th>
        <g:if test="${projectInstance.requiredNumberOfTranscriptions > 1}">
            <g:sortableColumn property="numberOfMatchingTranscriptions" style="padding: 0.9em;"
                              title="${message(code: 'task.numberOfMatchingTranscriptions.label', default: 'Matching')}"
                              params="${[q: params.q]}"/>
        </g:if>
        <g:sortableColumn property="fullyValidatedBy" style="padding: 0.9em;"
                          title="${message(code: 'task.fullyValidatedBy.label', default: 'Fully Validated By')}"
                          params="${[q: params.q, mode: params.mode]}"/>
        <g:sortableColumn property="isValid"
                          title="${message(code: 'task.isValid.label', default: 'Validation Status')}"
                          params="${[q: params.q, mode: params.mode]}" style="text-align: center; padding: 0.9em;"/>
    </tr>
    </thead>
</table>

<div class="panel-body">
    <div class="row">
        <g:each in="${taskInstanceList}" status="i" var="taskInstance">
            <g:set var="lastView" value="${lockedMap[taskInstance.id]}"/>
            <div class="col-md-2 col-sm-4">

                <div class="thumbnail">

                    <div style="text-align: center">
                        <a href="${createLink(controller: 'task', action: 'showDetails', id: taskInstance.id)}">
                            <cl:taskThumbnail task="${taskInstance}"/>
                        </a>
                    </div>

                    <div style="text-align: center">
                        <g:if test="${taskInstance.isFullyTranscribed}">
                            <g:if test="${taskInstance.isValid == true}">
                                <div>
                                    <a class="btn btn-small" ${(lastView ? 'disabled' : '')}
                                       href="${lastView ? '#' : createLink(controller: 'validate', action: 'task', id: taskInstance.id)}">
                                    <i class="fa fa-eye" title="Review"></i>
                                    </a>

                            </g:if>
                            <g:elseif test="${taskInstance.isValid == false}">
                                <div>
%{--                                    <g:link controller="validate" action="task" id="${taskInstance.id}">In progress</g:link>--}%
                                    <a class="btn btn-small" ${(lastView ? 'disabled' : '')}
                                       href="${lastView ? '#' : createLink(controller: 'validate', action: 'task', id: taskInstance.id)}">
                                        <i class="fa fa-check-square-o" title="Complete Validation ${(lastView ? '- currently being viewed by another volunteer' : '')}"></i>
                                    </a>

                            </g:elseif>
                            <g:else>

                                    <g:if test="${projectInstance.requiredNumberOfTranscriptions > 1}">
                                        <div class="label label-info">
                                            <a href="${lastView ? '#' : createLink(controller: 'validate', action: 'task', id: taskInstance.id)}">
                                                ${taskInstance.numberOfMatchingTranscriptions} / ${projectInstance.requiredNumberOfTranscriptions}
                                            </a>
                                    </g:if>
                                    <g:else>
                                        <div>
                                        <a class="btn btn-small" ${(lastView ? 'disabled' : '')}
                                        href="${lastView ? '#' : createLink(controller: 'validate', action: 'task', id: taskInstance.id)}">
                                            <i class="fa fa-check-square-o" title="Validate"></i>
                                        </a>
                                    </g:else>


                            </g:else>
                        </g:if>
                        <g:else>
                            <div class="label label-default">
                                New

                        </g:else>

                        <g:if test="${lastView}">
                            <i class="glyphicon glyphicon-lock lastViewedTask pull-right" title="Locked by ${lastView.userId}"
                               viewedTaskId="${lastView.id}"></i>
                        </g:if>
                        </div> %{-- End of thumbnail div --}%
                    </div>
                </div>
            </div>
            <g:if test="${(i+1) % 6 == 0}"><div class="clearfix visible-md-block visible-lg-block"></div></g:if>
            <g:if test="${(i+1) % 3 == 0}"><div class="clearfix visible-sm-block"></div></g:if>
        </g:each>
    </div>
</div>

<div class="pagination">
    <g:paginate total="${taskQueryTotal}" id="${params?.id}" params="${[q: params.q, mode: params.mode]}"/>
</div>
