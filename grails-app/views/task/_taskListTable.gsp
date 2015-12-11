<%@ page import="au.org.ala.volunteer.User; au.org.ala.volunteer.Task" %>
<table class="table table-striped table-condensed table-bordered">
    <thead>
    <tr>

        <g:sortableColumn property="id" title="${message(code: 'task.id.label', default: 'External Id')}"
                          params="${[q: params.q]}"/>

        <g:each in="${extraFields}"
                var="field"><th>${field.key?.capitalize().replaceAll(~/([a-z])([A-Z])/, '$1 $2')}</th></g:each>

        <g:sortableColumn property="fullyTranscribedBy"
                          title="${message(code: 'task.fullyTranscribedBy.label', default: 'Fully Transcribed By')}"
                          params="${[q: params.q]}"/>

        <g:sortableColumn property="fullyValidatedBy"
                          title="${message(code: 'task.fullyValidatedBy.label', default: 'Fully Validated By')}"
                          params="${[q: params.q]}"/>

        <g:sortableColumn property="isValid"
                          title="${message(code: 'task.isValid.label', default: 'Validation Status')}"
                          params="${[q: params.q]}" style="text-align: center;"/>

        <th style="text-align: center;">Action</th>

    </tr>
    </thead>
    <tbody>
    <g:each in="${taskInstanceList}" status="i" var="taskInstance">
        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

            <td>
                <g:link controller="task" action="showDetails" id="${taskInstance.id}" title="Show task details"><i
                        class="glyphicon glyphicon-list-alt"></i></g:link>
                ${taskInstance.externalIdentifier}
                <g:set var="lastView" value="${lockedMap[taskInstance.id]}"/>
                <g:if test="${lastView}">
                    <i class="glyphicon glyphicon-lock lastViewedTask" title="Locked by ${lastView.userId}"
                       viewedTaskId="${lastView.id}"></i>
                </g:if>
            </td>

            <g:each in="${extraFields}" var="field">
                <td>${field?.value[taskInstance.id]?.value?.getAt(0)}</td>
            </g:each>

            <td>
                <g:if test="${taskInstance.fullyTranscribedBy}">
                    <g:set var="thisUser" value="${User.findByUserId(taskInstance.fullyTranscribedBy)}"/>
                    <g:link controller="user" action="show" id="${thisUser.id}"><cl:userDetails id="${thisUser.userId}"
                                                                                                displayName="true"/></g:link>
                </g:if>
            </td>

            <td>
                <g:if test="${taskInstance.fullyValidatedBy}">
                    <g:set var="thisUser" value="${User.findByUserId(taskInstance.fullyValidatedBy)}"/>
                    <g:link controller="user" action="show" id="${thisUser.id}"><cl:userDetails id="${thisUser.userId}"
                                                                                                displayName="true"/></g:link>
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
                %{--<button class="btn btn-mini" onclick="validateInSeparateWindow(${taskInstance.id})" title="Review task in a separate window"><img src="${resource(dir: '/images', file: 'right_arrow.png')}">--}%
                %{--</button>--}%
                </g:if>
                <g:elseif test="${taskInstance.fullyTranscribedBy}">
                    <button class="btn btn-small"
                            onclick="location.href = '${createLink(controller:'validate', action:'task', id:taskInstance.id, params: params.clone())}'">validate</button>
                %{--<button class="btn btn-small" onclick="validateInSeparateWindow(${taskInstance.id})" title="Validate in a separate window"><img src="${resource(dir: '/images', file: 'right_arrow.png')}">--}%
                %{--</button>--}%
                </g:elseif>
                <g:else>
                    <button class="btn btn-small"
                            onclick="location.href = '${createLink(controller:'transcribe', action:'task', id:taskInstance.id, params: params.clone())}'">transcribe</button>
                </g:else>
            </td>

        </tr>
    </g:each>
    </tbody>
</table>

<div class="pagination">
    <g:paginate total="${taskInstanceTotal}" id="${params?.id}" params="${[q: params.q]}"/>
</div>
