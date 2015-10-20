<%@ page import="au.org.ala.volunteer.ValidationType; au.org.ala.volunteer.ValidationRule; au.org.ala.volunteer.Template; au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Picklist" %>
<%@ page import="au.org.ala.volunteer.PicklistItem" %>
<%@ page import="au.org.ala.volunteer.TemplateField" %>
<%@ page import="au.org.ala.volunteer.field.*" %>
<%@ page import="au.org.ala.volunteer.FieldCategory" %>
<%@ page import="au.org.ala.volunteer.DarwinCoreField" %>
<%@ page contentType="text/html; UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
    <title>Task Details</title>

    <sitemesh:parameter name="useFluidLayout" value="${true}"/>

    <r:require module="bootstrap-js"/>
    <r:require module="panZoom"/>
    <r:require module="imageViewer"/>

    <r:script>


        $(document).ready(function () {
            setupPanZoom();
        });

    </r:script>

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

<g:if test="${!taskInstance}">
    <div class="alert alert-danger">
        Task is null!
    </div>
</g:if>
<g:else>
    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span6">
                <div class="imageDiv">
                    <g:set var="multimedia" value="${taskInstance?.multimedia?.first()}"/>
                    <g:imageViewer multimedia="${multimedia}"/>
                </div>

                <div class="well well-small">
                    <a class="btn btn-small"
                       href="${createLink(action: 'show', id: taskInstance?.id)}">Transcribe/Validate Task</a>
                    <cl:ifAdmin>
                        <a class="btn btn-small btn-warning"
                           href="${createLink(action: 'resetTranscribedStatus', id: taskInstance?.id)}">Reset transcribed status</a>
                        <a class="btn btn-small btn-warning"
                           href="${createLink(action: 'resetValidatedStatus', id: taskInstance?.id)}">Reset validated status</a>
                    </cl:ifAdmin>
                </div>
            </div>

            <div class="span6">
                <div class="well well-small">
                    <table class="table">
                        <tr>
                            <td>ID</td>
                            <td>${taskInstance.id}</td>
                        </tr>
                        <tr>
                            <td>External Id</td>
                            <td>${taskInstance.externalIdentifier}</td>
                        </tr>
                        <tr>
                            <td>Project</td>
                            <td>${taskInstance.project?.name}</td>
                        </tr>
                        <tr>
                            <td>Created Date</td>
                            <td>${taskInstance.created?.format("yyyy-MM-dd HH:mm:ss")}</td>
                        </tr>
                        <tr>
                            <td>Transcribed</td>
                            <td>
                                <g:if test="${taskInstance.dateFullyTranscribed}">
                                    ${taskInstance.dateFullyTranscribed?.format("yyyy-MM-dd HH:mm:ss")} by ${cl.emailForUserId(id: taskInstance.fullyTranscribedBy) ?: "<span class='muted'>unknown</span>"}
                                </g:if>
                                <g:else>
                                    <span class="muted">
                                        Not transcribed
                                    </span>
                                </g:else>
                            </td>
                        </tr>
                        <tr>

                            <td>Validated</td>
                            <td>
                                <g:if test="${taskInstance.dateFullyValidated}">
                                    ${taskInstance.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")} by ${cl.emailForUserId(id: taskInstance.fullyValidatedBy) ?: "<span class='muted'>unknown</span>"}
                                </g:if>
                                <g:else>
                                    <span class="muted">
                                        Not validated
                                    </span>
                                </g:else>

                            </td>
                        </tr>
                        <tr>
                            <td>Date last updated</td>
                            <td>${taskInstance.dateLastUpdated?.format("yyyy-MM-dd HH:mm:ss")}</td>
                        </tr>

                        <tr>
                            <td>External URL</td>
                            <td>${taskInstance.externalUrl}</td>
                        </tr>

                        <tr>
                            <td>Is Valid</td>
                            <td>
                                <g:if test="${taskInstance.isValid != null}">
                                    ${taskInstance.isValid}
                                </g:if>
                                <g:else>
                                    <span class="muted">
                                        Not set
                                    </span>
                                </g:else>

                            </td>
                        </tr>
                        <tr>
                            <td>Views</td>
                            <td>
                                <ul>
                                    <g:each in="${taskInstance.viewedTasks?.sort({ it.lastView })}" var="view">
                                        <li>Viewed by <cl:userDisplayString
                                                id="${view.userId}"/> ${view.numberOfViews > 1 ? "(" + view.numberOfViews + " times) " : ""} on ${view.lastUpdated?.format("yyyy-MM-dd HH:mm:ss")})</li>
                                    </g:each>
                                </ul>
                            </td>
                        </tr>
                        <tr>
                            <td>Comments</td>
                            <td>
                                <ul>
                                    <g:each in="${taskInstance.comments}" var="comment">
                                        <li>
                                            <i><cl:userDetails id="${comment.user?.userId}"
                                                               displayName="true"/></i> on ${comment.date?.format("yyyy-MM-dd HH:mm:ss")}
                                            <br/>
                                            ${comment.comment}
                                        </li>
                                    </g:each>
                                </ul>
                            </td>
                        </tr>
                    </table>
                    <cl:validationStatus task="${taskInstance}"/>
                </div>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span12">
                <h3>Fields</h3>
                <table class="table table-bordered table-condensed">
                    <thead>
                    <g:sortableColumn property="id" title="Id"/>
                    <g:sortableColumn property="name" title="Field"/>
                    <g:sortableColumn property="recordIdx" title="Index"/>
                    <g:sortableColumn property="superceded" title="Superceded"/>
                    <g:sortableColumn property="value" title="Value"/>
                    <g:sortableColumn property="created" title="Date created"/>
                    <g:sortableColumn property="updated" title="Date updated"/>
                    <g:sortableColumn property="transcribedByUserId" title="Transcriber"/>
                    <g:sortableColumn property="validatedByUserId" title="Validator"/>
                    </thead>
                    <tbody>
                    <g:each in="${fields}" var="field">
                        <tr class="fieldrow" superceded="${field.superceded}">
                            <td>${field.id}</td>
                            <td>${field.name}</td>
                            <td>${field.recordIdx}</td>
                            <td>${field.superceded}</td>
                            <td>${field.value}</td>
                            <td>${field.created?.format("yyyy-MM-dd HH:mm:ss")}</td>
                            <td>${field.updated?.format("yyyy-MM-dd HH:mm:ss")}</td>
                            <td><cl:emailForUserId id="${field.transcribedByUserId}"/></td>
                            <td><cl:emailForUserId id="${field.validatedByUserId}"/></td>
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</g:else>
</body>
<r:script>

        $(document).ready(function() {

            $("#showImageWindow").click(function(e) {
                e.preventDefault();
                window.open("${createLink(controller: 'task', action: "showImage", id: taskInstance?.id)}", "imageViewer", 'directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=600');
            });

        });

</r:script>
</html>
