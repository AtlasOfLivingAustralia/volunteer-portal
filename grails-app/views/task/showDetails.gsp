<%@ page import="au.org.ala.volunteer.ValidationType; au.org.ala.volunteer.ValidationRule; au.org.ala.volunteer.Template; au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="au.org.ala.volunteer.FieldCategory" %>
<%@ page import="au.org.ala.volunteer.DarwinCoreField" %>
<%@ page import="au.org.ala.volunteer.ProjectType" %>
<%@ page contentType="text/html; UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
    <title>Task Details</title>

    <sitemesh:parameter name="useFluidLayout" value="${true}"/>

    <asset:stylesheet src="image-viewer"/>
    <style type="text/css">

    tr.fieldrow[superceded="true"] td {
        background-color: palevioletred;
    }

    .imageDiv {
        margin-bottom: 10px;
    }

    </style>

</head>

<body>

<cl:headerContent title="Task Details - ${taskInstance?.id}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'list'), label: message(code: 'default.expeditions.label', default: 'Expeditions')]

        ]
        if (taskInstance) {
            pageScope.crumbs << [link: createLink(controller: 'project', action: 'index', id: taskInstance?.project?.id), label: taskInstance?.project?.featuredLabel]
            pageScope.crumbs << [link: createLink(controller: 'task', action: 'projectAdmin', id: taskInstance?.project?.id), label: "Admin list"]
        }
    %>

    <div>
        <g:if test="${sequenceNumber >= 0}">
            <span>Image sequence number: ${sequenceNumber}</span>
        </g:if>
    </div>
</cl:headerContent>

<section id="main-content">
<g:if test="${!taskInstance}">
    <div class="alert alert-danger">
        Task is null!
    </div>
</g:if>
<g:else>
    <div class="container-fluid mb-4">
        <div class="row g-4">
            <div class="col-12 col-lg-6">
                <div class="card h-100 shadow-sm border-0">
                    <div class="card-body p-0 rounded overflow-hidden position-relative" style="min-height: 450px;">
                        <g:if test="${taskInstance?.project?.projectType?.name == ProjectType.PROJECT_TYPE_AUDIO}">
                            <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                                <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('audio/')}">
                                    <g:audioWaveViewer multimedia="${multimedia}"/>
                                </g:if>
                            </g:each>
                        </g:if>
                        <g:else>
                        <div class="imageDiv">
                            <g:set var="multimedia" value="${taskInstance?.multimedia?.first()}"/>
                            <g:imageViewer multimedia="${multimedia}"/>
                        </div>
                        </g:else>

                        <div class="col-12 d-flex justify-content-center gap-2 mt-auto pt-1 ps-0 mb-3">
                            <a class="btn btn-sm btn-outline-secondary"
                               href="${createLink(action: 'show', id: taskInstance?.id)}">Transcribe/Validate Task</a>
                        <cl:ifAdmin>
                            <g:if test="${taskInstance?.project.requiredNumberOfTranscriptions > 1}">
                            <a class="btn btn-sm btn-warning disabled">Reset transcribed status</a>
                            <a class="btn btn-sm btn-warning disabled">Reset validated status</a>
                            </g:if>
                            <g:else>
                            <a class="btn btn-sm btn-warning"
                               href="${createLink(action: 'resetTranscribedStatus', id: taskInstance?.id)}">Reset transcribed status</a>
                            <a class="btn btn-sm btn-warning"
                               href="${createLink(action: 'resetValidatedStatus', id: taskInstance?.id)}">Reset validated status</a>
                            </g:else>
                        </cl:ifAdmin>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-12 col-lg-6">
                <div class="card h-100 shadow-sm border">
                    <div class="card-header bg-body-tertiary d-flex justify-content-between align-items-center py-3">
                        <h5 class="card-title mb-0 fw-semibold fs-6 text-uppercase text-secondary">Metadata Details</h5>
                        <span class="badge bg-secondary-subtle text-secondary border fs-7">Task ID: ${taskInstance.id}</span>
                    </div>


                    <!-- Key metadata -->
                    <div class="list-group list-group-flush">
                        <div class="list-group-item d-flex justify-content-between align-items-center py-2 fs-7">
                            <span class="text-muted fw-medium">External ID</span>
                            <span class="font-monospace text-dark fw-semibold">${taskInstance.externalIdentifier}</span>
                        </div>

                        <div class="list-group-item d-flex justify-content-between align-items-center py-2 fs-7">
                            <span class="text-muted fw-medium">Project</span>
                            <span class="fw-semibold text-dark text-end">
                                <g:link controller="task" action="projectAdmin" id="${taskInstance.project?.id}" target="_blank">
                                    ${taskInstance.project?.name}<i class="fa fa-external-link ms-1"></i>
                                </g:link>
                            </span>
                        </div>

                        <div class="list-group-item d-flex justify-content-between align-items-center py-2 fs-7">
                            <span class="text-muted fw-medium">Created Date</span>
                            <span class="text-dark font-monospace">${taskInstance.created?.format("yyyy-MM-dd HH:mm:ss")}</span>
                        </div>

                        <div class="list-group-item py-2 fs-7">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted fw-medium">Transcribed</span>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="badge bg-success-subtle text-success border border-success-subtle">${transcriptions?.size()} Contributed</span>
                                    <g:if test="${transcriptions?.size() > 0}">
                                    <button class="btn btn-sm btn-link p-0 text-decoration-none" type="button" data-bs-toggle="collapse" data-bs-target="#transcribedHistory" aria-expanded="true">
                                        View Transcribers <i class="fa fa-chevron-down ms-1"></i>
                                    </button>
                                    </g:if>
                                </div>
                            </div>

                            <g:if test="${transcriptions?.size() > 0}">
                            <!-- Collapsible List -->
                            <div class="collapse mt-2" id="transcribedHistory">
                                <cl:transcribers transcriptionList="${transcriptions}"/>
                            </div>
                            </g:if>
                        </div>

                        <div class="list-group-item d-flex justify-content-between align-items-center py-2 fs-7">
                            <span class="text-muted fw-medium">Validation Status</span>
                            <g:if test="${taskInstance.dateFullyValidated}">
                                <g:if test="${!taskInstance.isValid}"><span class="badge badge--in-progress ms-auto me-2">In progress</span></g:if>
                                <g:if test="${taskInstance.isValid}"><span class="badge badge--validated ms-auto me-2">Validated</span></g:if>
                                <span class="me-2">
                                    <a href="#" class="scroll-link" data-target-transcription="transcription-${taskInstance.fullyValidatedBy}">
                                        ${cl.displayNameForUserId(id: taskInstance.fullyValidatedBy) ?: "Unknown"}
                                    </a>
                                </span>
                                <span class="font-monospace">${taskInstance.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")}</span>
                            </g:if>
                            <g:else>
                                <span class="muted ms-auto">
                                    Not validated
                                </span>
                            </g:else>
                        </div>

                        <div class="list-group-item d-flex justify-content-between align-items-center py-2 fs-7">
                            <span class="text-muted fw-medium">Date Last Updated</span>
                            <span class="text-dark font-monospace">2025-07-03 12:47:38</span>
                        </div>

                        <div class="list-group-item d-flex justify-content-between align-items-center py-2 fs-7">
                            <span class="text-muted fw-medium">External URL</span>
                            <span class="text-muted fs-7">
                                <g:if test="${taskInstance.externalUrl}">
                                    <a class="text-truncate" href="${taskInstance.externalUrl}" target="_blank">
                                        ${taskInstance.externalUrl}
                                        <i class="fa fa-external-link-alt ms-1"></i>
                                    </a>
                                </g:if>
                                <g:else>
                                    <em>None</em>
                                </g:else>
                            </span>
                        </div>

                        <div class="list-group-item py-2 fs-7">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted fw-medium">Views</span>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="badge bg-success-subtle text-success border border-success-subtle">${viewedTasks?.size()} Views</span>
                                    <g:if test="${viewedTasks?.size() > 0}">
                                        <button class="btn btn-sm btn-link p-0 text-decoration-none" type="button" data-bs-toggle="collapse" data-bs-target="#viewedTasks" aria-expanded="false">
                                            Activity Log <i class="fa fa-chevron-down ms-1"></i>
                                        </button>
                                    </g:if>
                                </div>
                            </div>

                            <g:if test="${viewedTasks?.size() > 0}">
                                <!-- Collapsible List -->
                                <div class="collapse mt-2" id="viewedTasks">
                                    <cl:activityLog viewedTasks="${viewedTasks}" transcriptions="${transcriptions}"/>
                                </div>
                            </g:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-3">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-body border-bottom d-flex align-items-center justify-content-between py-2">
                    <div class="d-flex align-items-center gap-2">
                        <h4 class="mb-0 fw-semibold text-secondary">Transcribed Fields</h4>
                    </div>
                    <g:if test="${fieldsByTranscriber.containsKey('system')}">
                    <div class="form-check form-switch mb-0 small">
                        <input class="form-check-input" type="checkbox" role="switch" id="toggleSystemGroup" data-bs-toggle="collapse" data-bs-target="#systemGroup" aria-expanded="false">
                        <label class="form-check-label text-muted" for="toggleSystemGroup">Show System Metadata</label>
                    </div>
                    </g:if>
                </div>

                <div class="table-responsive">
                    <table class="table table-sm table-hover align-middle mb-0 font-monospace small">
                        <thead class="table-light border-bottom text-uppercase fs-7 text-muted">
                        <tr>
%{--                            <th scope="col" style="width: 110px;">ID</th>--}%
                            <g:sortableColumn scope="col" style="width: 110px;" property="id" title="ID"/>
%{--                            <th scope="col" style="width: 350px;">Field</th>--}%
                            <g:sortableColumn scope="col" style="width: 350px;" property="name" title="Field"/>
%{--                            <th scope="col">Value</th>--}%
                            <g:sortableColumn scope="col" property="value" title="Value"/>
%{--                            <th scope="col" style="width: 70px;">Index</th>--}%
                            <g:sortableColumn scope="col" style="width: 70px;" property="recordIdx" title="Index"/>
%{--                            <th scope="col" style="width: 120px;">Validator</th>--}%
                            <g:sortableColumn scope="col" style="width: 120px;" property="validatedByUserId" title="Validator"/>
%{--                            <th scope="col" style="width: 160px;">Date Updated</th>--}%
                            <g:sortableColumn scope="col" style="width: 160px;" property="updated" title="Date Updated"/>
                        </tr>
                        </thead>

                <g:if test="${fieldsByTranscriber}">
                    <g:each in="${fieldsByTranscriber}" var="groupEntry">
                        <g:if test="${groupEntry.key.toLowerCase() != 'system'}">
                        <tbody class="border-top-0" data-transcription-id="transcription-${groupEntry.key}">
                        <tr class="table-secondary border-bottom">
                            <td colspan="6" class="py-2 px-3 fw-bold text-dark">
                                <div class="d-flex align-items-center justify-content-between">
                                    <span>
                                        Transcriber:
                                        <strong>
                                        <g:if test="${groupEntry.key == 'Unknown'}">Unknown</g:if>
                                        <g:else><cl:displayNameForUserId id="${groupEntry.key}"/></g:else>
                                        </strong>
                                        <g:if test="${taskInstance.fullyValidatedBy == groupEntry.key}">
                                            <span class="badge badge--validated ms-2">Validator</span>
                                        </g:if>
                                    </span>
                                    <span class="badge bg-light text-dark border fw-normal">${groupEntry.value?.size()} fields</span>
                                </div>
                            </td>
                        </tr>
                        <g:each in="${groupEntry.value}" var="field">
                        <tr class="table-light text-muted opacity-75">
                            <td><span class="text-secondary opacity-50">${field.id}</span></td>
                            <td class="fw-medium text-dark opacity-75">${field.name}</td>
                            <td>
                                <g:if test="${field.superceded}">
                                    <span class="text-decoration-line-through me-2">${field.value}</span>
                                    <span class="badge badge-keyword border border-red ms-auto">Superseded</span>
                                </g:if>
                                <g:else>
                                    <span class="fw-semibold text-body me-2">${field.value}</span>
                                </g:else>
                            </td>
                            <td>${field.recordIdx}</td>
                            <td><cl:displayNameForUserId id="${field.validatedByUserId}"/></td>
                            <td class="text-nowrap font-monospace">${field.updated?.format("yyyy-MM-dd HH:mm:ss")}</td>
                        </tr>
                        </g:each>
                        </tbody>
                        </g:if>
                    </g:each>
                    <g:if test="${fieldsByTranscriber['system']}">
                        <tbody class="collapse" id="systemGroup" data-transcription-id="transcription-system">
                        <tr class="table-secondary border-bottom">
                            <td colspan="6" class="py-2 px-3 fw-bold text-dark">
                                <div class="d-flex align-items-center justify-content-between">
                                    <span>
                                        System Metadata
                                    </span>
                                    <span class="badge bg-light text-dark border fw-normal">${fieldsByTranscriber['system']?.size()} fields</span>
                                </div>
                            </td>
                        </tr>
                        <g:each in="${fieldsByTranscriber['system']}" var="field">
                        <tr class="table-light text-muted opacity-75">
                            <td><span class="text-secondary opacity-50">${field.id}</span></td>
                            <td class="fw-medium text-dark opacity-75">${field.name}</td>
                            <td>
                                <g:if test="${field.superceded}">
                                    <span class="text-decoration-line-through me-2">${field.value}</span>
                                    <span class="badge badge-keyword border border-red ms-auto">Superseded</span>
                                </g:if>
                                <g:else>
                                    <span class="fw-semibold text-body me-2">${field.value}</span>
                                </g:else>
                            </td>
                            <td>${field.recordIdx}</td>
                            <td><cl:displayNameForUserId id="${field.validatedByUserId}"/></td>
                            <td class="text-nowrap font-monospace">${field.updated?.format("yyyy-MM-dd HH:mm:ss")}</td>
                        </tr>
                        </g:each>
                        </tbody>
                    </g:if>
                </g:if>
                <g:else>
                        <tr>
                            <td colspan="6" class="text-muted">No fields found.</td>
                        </tr>
                </g:else>
                    </table>
                </div>
            </div>
        </div>

        <cl:returnToTopButton/>
    </div>
</g:else>
</section>
<asset:javascript src="image-viewer" asset-defer=""/>

<g:if test="${taskInstance?.project?.projectType?.name == ProjectType.PROJECT_TYPE_AUDIO}">
<script src="https://unpkg.com/wavesurfer.js@6.1.0/dist/wavesurfer.js"></script>
</g:if>

<asset:script type="text/javascript">

    $(document).ready(function () {
        setupPanZoom();
    });

    document.querySelectorAll('.scroll-link').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();

            const targetId = this.getAttribute('data-target-transcription');
            const targetElement = document.querySelector('[data-transcription-id="' + targetId + '"]');

            if (targetElement) {
                // 1. Get the height of your fixed header dynamically
                const headerHeight = document.getElementById('fixed-digivol-header').offsetHeight;

                // 2. Calculate the exact vertical position of the target element
                const elementPosition = targetElement.getBoundingClientRect().top;

                // 3. Add the current window scroll to find the absolute position, then subtract the header
                const offsetPosition = elementPosition + window.scrollY - headerHeight;

                // 4. Scroll smoothly to the calculated pixel position
                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });

</asset:script>
<asset:script type="text/javascript">

    $(document).ready(function() {

        $("#showImageWindow").click(function(e) {
            e.preventDefault();
            window.open("${createLink(controller: 'task', action: "showImage", id: taskInstance?.id)}", "imageViewer", 'directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=600');
            });

        });

</asset:script>
</body>
</html>
