<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<table class="table table-striped table-condensed task-table">
    <thead>
    <tr>
        <g:sortableColumn property="id" width="30%" style="padding: 0.9em;"
                          title="${message(code: 'task.id.label', default: 'External Id')}"
                          params="${[q: params.q]}"/>

        <g:each in="${extraFields}"
                var="field"><th style="padding: 0.9em;">${field.key?.capitalize().replaceAll(~/([a-z])([A-Z])/, '$1 $2')}</th></g:each>

        <th style="padding: 0.9em;">${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}</th>

        <g:if test="${projectInstance.requiredNumberOfTranscriptions > 1}">
            <g:sortableColumn property="numberOfMatchingTranscriptions" style="padding: 0.9em;"
                              title="${message(code: 'task.numberOfMatchingTranscriptions.label', default: 'Matching')}"
                              params="${[q: params.q]}"/>
        </g:if>

        <g:sortableColumn property="fullyValidatedBy" style="padding: 0.9em;"
                          title="${message(code: 'task.fullyValidatedBy.label', default: 'Fully Validated By')}"
                          params="${[q: params.q]}"/>

        <g:sortableColumn property="isValid"
                          title="${message(code: 'task.isValid.label', default: 'Validation Status')}"
                          params="${[q: params.q]}" style="text-align: center; padding: 0.9em;"/>

        <th style="text-align: center; padding: 0.9em;">Action</th>

    </tr>
    </thead>
    <tbody>
    <g:each in="${taskInstanceList}" status="i" var="taskInstance">
        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

            <td style="padding: 0.9em;">
                <g:link controller="task" action="showDetails" id="${taskInstance.id}" title="${g.message(code: 'task.details.button.label')}"><i
                        class="glyphicon glyphicon-list-alt"></i></g:link>
                ${taskInstance.externalIdentifier}
                <g:set var="lastView" value="${lockedMap[taskInstance.id]}"/>
                <g:if test="${lastView}">
                    <i class="glyphicon glyphicon-lock lastViewedTask" title="Locked by ${lastView.userId}"
                       viewedTaskId="${lastView.id}"></i>
                </g:if>
            </td>

            <g:each in="${extraFields}" var="field">
                <td style="padding: 0.9em;">
                    %{-- Use superceded field or the first row--}%
                    ${field?.value[taskInstance.id]?.value?.getAt(0)}
                </td>
            </g:each>

            <td style="padding: 0.9em;">
                <cl:transcriberNames task="${taskInstance}"/>
            </td>

            <g:if test="${projectInstance.requiredNumberOfTranscriptions > 1}">
                <td style="padding: 0.9em;">
                    <g:if test="${taskInstance.isFullyTranscribed}">
                        ${taskInstance.numberOfMatchingTranscriptions}
                    </g:if>
                    <g:else>
                        0
                    </g:else>
                </td>
            </g:if>

            <td style="padding: 0.9em;">
                <g:if test="${taskInstance.fullyValidatedBy}">
                    <g:set var="thisUser" value="${User.findByUserId(taskInstance.fullyValidatedBy)}"/>
                    <g:link controller="user" action="show" id="${thisUser?.id}"><cl:userDetails id="${taskInstance.fullyValidatedBy}"
                                                                                                displayName="true"/></g:link>
                </g:if>
            </td>

            <td style="text-align: center; padding: 0.9em;">
                <g:if test="${taskInstance.isValid == true}"><!-- &#10003; --> Validated</g:if>
                <g:elseif test="${taskInstance.isValid == false}"><!-- &#10005; --> In Progress</g:elseif>
                <g:else><!-- &#8211; -->
                    <g:if test="${taskInstance.isFullyTranscribed}">
                        Transcribed
                    </g:if>
                    <g:else>
                        New
                    </g:else>
                </g:else>
            </td>

            <td style="text-align: center; padding: 0.9em;">
                %{-- Validated/Review --}%
    <g:if test="${taskInstance.fullyValidatedBy}">
        <g:if test="${taskInstance.isValid}">
%{--                <g:link class="btn btn-small" controller="validate" action="task" id="${taskInstance.id}">Review</g:link>--}%
            <g:if test="${lastView}">
                <button class="btn btn-link" disabled><i class="fa fa-2x fa-eye" title="Review - currently being viewed by another volunteer"></i></button>
            </g:if>
            <g:else>
                <a class="btn btn-small" href="${createLink(controller: 'validate', action: 'task', id: taskInstance.id)}">
                    <i class="fa fa-2x fa-eye" title="Review"></i>
                </a>
            </g:else>
        </g:if>
        <g:else>
            <g:if test="${lastView}">
                <button  class="btn btn-link" disabled>
                    <i class="fa fa-2x fa-check-square-o" title="Complete Validation - currently being viewed by another volunteer"></i>
                </button>
            </g:if>
            <g:else>
                <a class="btn btn-small" href="${createLink(controller: 'validate', action: 'task', id: taskInstance.id)}">
                    <i class="fa fa-2x fa-check-square-o" title="Complete Validation"></i>
                </a>
            </g:else>
        </g:else>
    </g:if>
    %{-- Transcribed --}%
    <g:elseif test="${taskInstance.isFullyTranscribed}">
        <g:if test="${lastView}">
                <button  class="btn btn-link" disabled>
                    <i class="fa fa-2x fa-check-square-o" title="Validate - currently being viewed by another volunteer"></i>
                </button>
        </g:if>
        <g:else>
%{--                    <g:link  controller="validate" action="task" id="${taskInstance.id}">Validate</g:link>--}%
                <a class="btn btn-small" href="${createLink(controller: 'validate', action: 'task', id: taskInstance.id)}">
                    <i class="fa fa-2x fa-check-square-o" title="Validate"></i>
                </a>
        </g:else>
    </g:elseif>
    %{-- Not Transcribed --}%
    <g:else>
        <g:if test="${lastView}">
            <button  class="btn btn-link" disabled>
                <i class="fa fa-2x fa-pencil-square-o" title="Transcribe - currently being viewed by another volunteer"></i>
            </button>
        </g:if>
        <g:else>
%{--                    <g:link class="btn btn-small" controller="transcribe" action="task" id="${taskInstance.id}">Transcribe</g:link>--}%

                <a class="btn btn-small" ${(lastView ? 'disabled' : '')} href="${createLink(controller: 'transcribe', action: 'task', id: taskInstance.id)}">
                    <i class="fa fa-2x fa-pencil-square-o" title="Transcribe"></i>
                </a>
        </g:else>
    </g:else>
            </td>

        </tr>
    </g:each>
    </tbody>
</table>

<div class="pagination">
    <g:paginate total="${taskQueryTotal}" id="${params?.id}" params="${[q: params.q]}"/>
</div>
