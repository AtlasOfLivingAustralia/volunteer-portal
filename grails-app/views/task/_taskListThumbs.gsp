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

<div class="container-fluid px-4 my-4">
    <!-- Optimized for high-density image grids: 2 cols on mobile, scales up to 6 on wide screens -->
    <div class="row row-cols-2 row-cols-sm-3 row-cols-md-4 row-cols-lg-5 row-cols-xl-6 g-3 task-list">
    <g:each in="${taskInstanceList}" status="i" var="taskInstance">
        <g:set var="lastView" value="${lockedMap[taskInstance.id]}"/>
        <g:set var="taskStatus" value="new"/>

        <g:if test="${taskInstance.isFullyTranscribed}">
            <g:if test="${taskInstance.isValid == true}">
                <g:set var="taskStatus" value="validated"/>
            </g:if>
            <g:elseif test="${taskInstance.isValid == false}">
                <g:set var="taskStatus" value="transcribed"/>
            </g:elseif>
            <g:else>
                <g:if test="${projectInstance.requiredNumberOfTranscriptions > 1}">
                    <g:set var="taskStatus" value="in-progress"/>
                </g:if>
                <g:else>
                    <g:set var="taskStatus" value="transcribed"/>
                </g:else>
            </g:else>
        </g:if>
        <g:else>
            <g:if test="${taskInstance.numberOfTranscriptions > 0}">
                <g:set var="taskStatus" value="in-progress"/>
            </g:if>
            <g:else>
                <g:set var="taskStatus" value="new"/>
            </g:else>
        </g:else>


        <div class="col">
            <div class="card h-100 shadow-sm border-0 bg-light position-relative overflow-hidden">

                <!-- Thumbnail Container -->
                <div class="ratio ratio-4x3 bg-secondary-subtle">
                    <!-- Object-fit-contain or cover depending on handwritten vs document text images -->
%{--                    <img src="https://images.unsplash.com/photo-1631482397471-6769144d3c24?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=NHwxMjA3fDA%3D" class="card-img-top object-fit-contain p-1" alt="Document Fragment">--}%
                    <a href="${createLink(controller: 'task', action: 'showDetails', id: taskInstance.id)}">
                        <cl:taskThumbnail task="${taskInstance}" customCss="card-img-top object-fit-contain p-1"/>
                    </a>
                </div>
                <g:if test="${lastView}">
                <span class="position-absolute top-0 start-0 m-2 badge rounded-pill bg-secondary d-flex align-items-center gap-1 shadow-sm">
%{--                    <svg xmlns="http://w3.org" width="12" height="12" fill="currentColor" class="fa fa-lock lastViewedTask pointer" viewBox="0 0 16 16" title="Locked by ${lastView.userId}" viewedTaskId="${lastView.id}">--}%
%{--                        <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0m-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>--}%
%{--                    </svg>--}%
                    <svg viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg" class="fa fa-lock lastViewedTask pointer" title="Locked by ${lastView.userId}" viewedTaskId="${lastView.id}">>
                        <path d="M7.5 4C6.67157 4 6 4.67157 6 5.5V6H9V5.5C9 4.67157 8.32843 4 7.5 4Z"/>
                        <path fill-rule="evenodd" clip-rule="evenodd" d="M7.5 0C11.6421 0 15 3.35786 15 7.5C15 11.6421 11.6421 15 7.5 15C3.35786 15 -2.54447e-06 11.6421 0 7.5C0 3.35786 3.35786 -2.54447e-06 7.5 0ZM5 5.5V6.08535C4.4174 6.29127 4 6.84689 4 7.5V10.5C4 11.3284 4.67157 12 5.5 12H9.5C10.3284 12 11 11.3284 11 10.5V7.5C11 6.84689 10.5826 6.29127 10 6.08535V5.5C10 4.11929 8.88071 3 7.5 3C6.11929 3 5 4.11929 5 5.5Z"/>
                    </svg>
%{--                    <i class="fa fa-lock lastViewedTask float-start" title="Locked by ${lastView.userId}" viewedTaskId="${lastView.id}"></i>--}%
                </span>
                </g:if>

                <!-- Status Overlay Badge (Top Right) -->
                <g:if test="${taskStatus == 'validated'}">
                <span class="position-absolute top-0 end-0 m-2 badge rounded-pill bg-success d-flex align-items-center gap-1 shadow-sm">
                    <svg xmlns="http://w3.org" width="12" height="12" fill="currentColor" class="fa fa-check-circle-o" viewBox="0 0 16 16">
                        <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0m-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>
                    </svg>
                    Done
                </span>
                <div class="progress rounded-0" style="height: 4px;">
                    <div class="progress-bar bg-success" role="progressbar" style="width: 100%;" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
                </g:if>
                <g:elseif test="${taskStatus == 'in-progress'}">
                <span class="position-absolute top-0 end-0 m-2 badge rounded-pill bg-primary shadow-sm font-monospace">
                    ${taskInstance.numberOfTranscriptions}/${projectInstance.requiredNumberOfTranscriptions}
                </span>
                <!-- Slim inline progress indicator below thumbnail -->
                <div class="progress rounded-0" style="height: 4px;">
                    <g:set var="progressPercent" value="${taskInstance.numberOfTranscriptions / projectInstance.requiredNumberOfTranscriptions * 100}"/>
                    <div class="progress-bar bg-primary" role="progressbar" style="width: ${progressPercent}%;" aria-valuenow="${progressPercent}" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
                </g:elseif>
                <g:elseif test="${taskStatus == 'transcribed'}">
                <span class="position-absolute top-0 end-0 m-2 badge rounded-pill bg-secondary d-flex align-items-center gap-1 shadow-sm">
                    <svg xmlns="http://w3.org" width="12" height="12" fill="currentColor" class="fa fa-pencil" viewBox="0 0 16 16">
                        <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0m-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>
                    </svg>
                    Transcribed
                </span>
                <div class="progress rounded-0" style="height: 4px;">
                    <div class="progress-bar bg-secondary" role="progressbar" style="width: 100%;" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
                </g:elseif>
                <g:else>
                <div class="progress rounded-0" style="height: 4px;">
                    <div class="progress-bar bg-secondary" role="progressbar" style="width: 100%;" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
                </g:else>

                <!-- High-density card body -->
                <div class="card-body p-2 d-flex flex-column justify-content-between">
                    <div>
                        <div class="d-flex justify-content-between align-items-start mb-1">
                            <span class="fw-bold small text-muted text-uppercase tracking-wider">ID: ${taskInstance.id}</span>
                        </div>
                        <g:if test="${taskStatus == 'validated'}">
                        <p class="card-text text-truncate small mb-2 text-dark fw-medium">Validated</p>
                        </g:if>
                        <g:elseif test="${taskStatus == 'in-progress'}">
                        <p class="card-text text-truncate small mb-2 text-muted italic">In progress</p>
                        </g:elseif>
                        <g:elseif test="${taskStatus == 'transcribed'}">
                        <p class="card-text text-truncate small mb-2 text-muted italic">Transcribed, awaiting validation...</p>
                        </g:elseif>
                        <g:else>
                        <p>&nbsp;</p>
                        </g:else>
                    </div>
                    <div class="mt-auto">
                        <g:if test="${taskStatus == 'validated'}">
                            <a href="${createLink(controller: 'task', action: 'showDetails', id: taskInstance.id)}" class="btn btn-sm btn-outline-secondary w-100 py-1 small fw-medium">View</a>
                        </g:if>
                        <g:elseif test="${taskStatus == 'in-progress'}">
                            <g:if test="${taskInstance.numberOfTranscriptions >= projectInstance.thresholdMatchingTranscriptions}">
                            <a href="${lastView ? '#' : createLink(controller: 'validate', action: 'task', id: taskInstance.id)}" class="btn btn-sm btn-secondary w-100 py-1 small fw-medium ${lastView ? 'disabled' : ''}">Validate</a>
                            </g:if>
                            <g:else>
                            <a href="${lastView ? '#' : createLink(controller: 'transcribe', action: 'task', id: taskInstance.id)}" class="btn btn-sm btn-outline-primary w-100 py-1 small fw-medium ${lastView ? 'disabled' : ''}">Resume</a>
                            </g:else>
                        </g:elseif>
                        <g:elseif test="${taskStatus == 'transcribed'}">
                        <a href="${lastView ? '#' : createLink(controller: 'validate', action: 'task', id: taskInstance.id)}" class="btn btn-sm btn-secondary w-100 py-1 small fw-medium ${lastView ? 'disabled' : ''}">Validate</a>
                        </g:elseif>
                        <g:else>
                        <a href="${lastView ? '#' : createLink(controller: 'transcribe', action: 'task', id: taskInstance.id)}" class="btn btn-sm btn-primary w-100 py-1 small fw-medium ${lastView ? 'disabled' : ''}">Transcribe</a>
                        </g:else>
                    </div>
                </div>

            </div>
        </div>

    </g:each>
    </div>

</div>


<cl:paginate total="${taskQueryTotal}" id="${params?.id}" params="${[q: params.q, mode: params.mode]}"/>
