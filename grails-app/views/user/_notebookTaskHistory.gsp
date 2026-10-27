<%@ page import="au.org.ala.volunteer.DateConstants" %>
<!-- 3. Task History Table Section -->
<div class="card border-0 bg-white shadow-sm p-4 mb-4">
    <div class="mb-2">
        <h5 class="fw-bold text-dark mb-0">Task history</h5>
        <span class="text-muted fs-7">${totalMatchingTasks} tasks found.</span>
    </div>

    <!-- Filter Control and Pagination Toolbar Wrap -->
    <div class="d-flex flex-col flex-md-row flex-wrap justify-content-between align-items-md-baseline gap-3 my-3">

        <!-- Filters Sub-group -->
        <div class="d-flex align-items-center flex-wrap gap-2">
            <span class="text-muted fs-7 me-1">Filter by:</span>
            <div class="btn-group btn-group-sm" role="group" aria-label="Task history filters">
            <g:if test="${userInstance.userId == currentUser}">
                <g:set var="perspective" value="by me"/>
            </g:if>
                <g:else>
                    <g:set var="perspective" value="by ${cl.displayNameForUserId(id: userInstance.userId)}"/>
                </g:else>
                <g:link controller="user" action="show" id="${userInstance.id}" class="btn btn-outline-primary px-3 fw-semibold ${!params.filter ? 'active' : ''}">All tasks</g:link>

                <g:link controller="user" action="show" id="${userInstance.id}" params="${[filter: 'transcribed']}" class="btn btn-outline-primary px-3 fw-semibold ${params.filter?.equalsIgnoreCase('transcribed') ? 'active' : ''}" for="transcribedTasks">Transcribed ${perspective}</g:link>

                <g:link controller="user" action="show" id="${userInstance.id}" params="${[filter: 'validated']}" class="btn btn-outline-primary px-3 fw-semibold ${params.filter?.equalsIgnoreCase('validated') ? 'active' : ''}" for="validatedTasks">Validated ${perspective}</g:link>

            <g:if test="${userInstance.userId == currentUser}">
                <g:link controller="user" action="show" id="${userInstance.id}" params="${[filter: 'saved']}" class="btn btn-outline-primary px-3 fw-semibold ${params.filter?.equalsIgnoreCase('saved') ? 'active' : ''}" for="savedTasks">Saved for later</g:link>
            </g:if>
            </div>
        </div>

        <!-- Pagination Block Alignment -->
        <cl:paginate total="${totalMatchingTasks ?: 0}" action="show" params="${params}" ariaLabel="Tasks, top"/>

    </div>

    <!-- Data Table Container Grid -->
    <div class="table-responsive mt-2">
        <table class="table table-hover align-middle border-top">
            <thead class="table-light">
            <tr class="fs-7 text-uppercase text-muted border-bottom">
%{--                <th scope="col" style="width: 120px;">Task ID</th>--}%
                <g:sortableColumn property="id" style="width: 120px;"
                                title="${message(code: 'task.id.label', default: 'Task ID')}" params="${[filter: params.filter]}"/>
%{--                <th scope="col">Expedition</th>--}%
                <g:sortableColumn property="projectName"
                                title="${message(code: 'project.name.label', default: 'Expedition')}" params="${[filter: params.filter]}"/>
%{--                <th scope="col" style="width: 140px;">Transcribed</th>--}%
                <g:sortableColumn property="dateTranscribed" style="width: 140px;"
                                title="${message(code: 'task.dateFullyTranscribed.label', default: 'Transcribed')}" params="${[filter: params.filter]}"/>
%{--                <th scope="col" style="width: 180px;">Status</th>--}%
                <s:sortableColumn tag="th" property="status" style="width: 180px;"
                                title="${message(code: 'task.isValid.label', default: 'Status')}" params="${[filter: params.filter]}">
                    <cl:helpText>
                        The current status of the task. Shows 'Transcribed by me' or 'Validated by me' if you were the last to action the task, otherwise just the current status.
                    </cl:helpText>
                </s:sortableColumn>
                <th scope="col" class="text-end" style="width: 120px;">Action</th>
            </tr>
            </thead>
            <tbody class="fs-7">

        <g:each in="${viewTaskList}" var="row">
            <tr>
                <td class="text-muted fw-mono pointer">
                    <cl:taskThumbnail taskId="${row.task_id}" height="60" openFullImage="true"/>
%{--                    ${row.task_id}--}%
                </td>
                <td>
                    <div class="fw-semibold text-dark"><a href="${createLink(controller: 'project', action: 'index', id: row.projectId)}" target="_blank">${row.projectName}</a></div>
                    <small class="text-muted fs-8"><a href="${createLink(controller: 'institution', action: 'index', id: row.institutionId)}" target="_blank">${row.institutionName}</a></small>
                </td>
                <td class="text-nowrap text-muted"> <g:formatDate date="${row.dateTranscribed}"
                                                                  format="${DateConstants.DATE_TIME_FORMAT}"/></td>
                <td>
                    <g:set var="statusPerspective" value="" />
                    <g:if test="${currentUser == row.fullyTranscribedBy && row.status == message(code: 'status.transcribed')}">
                        <g:set var="statusPerspective" value=" by me" />
                    </g:if>
                    <g:if test="${currentUser == row.fullyValidatedBy && row.status == message(code: 'status.validated')}">
                        <g:set var="statusPerspective" value=" by me" />
                    </g:if>
                    <span class="badge badge--${row.status.replace(" ", "-").toLowerCase()} border-${row.status.replace(" ", "-").toLowerCase()} px-2.5 py-1.5 rounded">
                        ${row.status}${statusPerspective}
                    </span>
                </td>
                <td class="text-end">
                    <div class="btn-group btn-group-sm" role="group">
%{--                        // If task is fully transcribed and (the user is the transcriber or the user is a validator)--}%
%{--                        // display show task button--}%
                        <g:if test="${row.isFullyTranscribed && (row.fullyTranscribedBy == currentUser || row.isValidator)}">
                            <!-- show task -->
                            <a class="btn btn-light border" href="${createLink(controller: 'task', action: 'show', id: row.task_id)}">
                                <i class="fa fa-eye" title="View task" aria-label="View task"></i>
                            </a>
                        </g:if>

%{--                    // If task is fully transcribed and the user is a validator--}%
%{--                    // display validate button--}%
                        <g:if test="${row.isFullyTranscribed && row.isValidator}">
%{--                    // If task status is validated, label = review--}%
%{--                    // else label = validate--}%
                            <g:if test="${row.status == message(code: 'status.validated')}">
                                <g:set var="validateButtonLabel" value="Review" />
                            </g:if>
                            <g:else>
                                <g:set var="validateButtonLabel" value="Validate" />
                            </g:else>
                            <!-- validate task -->
                            <a class="btn btn-light border" href="${createLink(controller: 'validate', action: 'task', id: row.task_id)}">
                                <i class="fa fa-check-square-o" title="${validateButtonLabel}"></i>
                            </a>
                        </g:if>

%{--                    // If task is not fully transcribed--}%
%{--                    // display transcribe button--}%
                        <g:if test="${!row.isFullyTranscribed}">
                            <a class="btn btn-light border" href="${createLink(controller: 'transcribe', action: 'task', id: row.task_id)}">
                                <i class="fa fa-pencil" title="Transcribe"></i>
                            </a>
                        </g:if>
%{--                        <button type="button" class="btn btn-light border" title="View details" aria-label="View task details"><i class="fa fa-eye"></i></button>--}%
%{--                        <button type="button" class="btn btn-light border" title="Approve/Verify" aria-label="Verify task workflow"><i class="fa fa-check"></i></button>--}%
                    </div>
                </td>
            </tr>
        </g:each>
            </tbody>
        </table>
    </div>
</div>