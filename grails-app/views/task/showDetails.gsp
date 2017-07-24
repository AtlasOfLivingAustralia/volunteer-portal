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
            <span><g:message code="task.showDetails.image_sequence_number"/> ${sequenceNumber}</span>
        </g:if>
    </div>
</cl:headerContent>

<section id="main-content">
<g:if test="${!taskInstance}">
    <div class="alert alert-danger">
        <g:message code="task.showDetails.task_is_null"/>
    </div>
</g:if>
<g:else>
    <div class="container-fluid">
        <div class="row-fluid">
            <div class="col-sm-12 col-md-6">
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="imageDiv">
                            <g:set var="multimedia" value="${taskInstance?.multimedia?.first()}"/>
                            <g:imageViewer multimedia="${multimedia}"/>
                        </div>

                        <a class="btn btn-default btn-small"
                           href="${createLink(action: 'show', id: taskInstance?.id)}"><g:message code="task.showDetails.transcribe_validate"/></a>
                        <cl:ifAdmin>
                            <a class="btn btn-small btn-warning"
                               href="${createLink(action: 'resetTranscribedStatus', id: taskInstance?.id)}"><g:message code="task.showDetails.reset_transcribed_status"/></a>
                            <a class="btn btn-small btn-warning"
                               href="${createLink(action: 'resetValidatedStatus', id: taskInstance?.id)}"><g:message code="task.showDetails.reset_validated_status"/></a>
                        </cl:ifAdmin>
                    </div>
                </div>
            </div>

            <div class="col-sm-12 col-md-6">
                <div class="panel panel-default">
                    <table class="table">
                        <tr>
                            <td><g:message code="task.showDetails.ID"/></td>
                            <td>${taskInstance.id}</td>
                        </tr>
                        <tr>
                            <td><g:message code="task.showDetails.external_id"/></td>
                            <td>${taskInstance.externalIdentifier}</td>
                        </tr>
                        <tr>
                            <td><g:message code="task.showDetails.project"/></td>
                            <td>${taskInstance.project?.name}</td>
                        </tr>
                        <tr>
                            <td><g:message code="task.showDetails.created_date"/></td>
                            <td>${taskInstance.created?.format("yyyy-MM-dd HH:mm:ss")}</td>
                        </tr>
                        <tr>
                            <td><g:message code="task.showDetails.transcribed"/></td>
                            <td>
                                <g:if test="${taskInstance.dateFullyTranscribed}">
                                    ${taskInstance.dateFullyTranscribed?.format("yyyy-MM-dd HH:mm:ss")} by ${cl.emailForUserId(id: taskInstance.fullyTranscribedBy) ?: "<span class='muted'>unknown</span>"}
                                </g:if>
                                <g:else>
                                    <span class="muted">
                                        <g:message code="task.showDetails.not_transcribed"/>
                                    </span>
                                </g:else>
                            </td>
                        </tr>
                        <tr>

                            <td><g:message code="task.showDetails.validated"/></td>
                            <td>
                                <g:if test="${taskInstance.dateFullyValidated}">
                                    ${taskInstance.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")} by ${cl.emailForUserId(id: taskInstance.fullyValidatedBy) ?: "<span class='muted'>unknown</span>"}
                                </g:if>
                                <g:else>
                                    <span class="muted">
                                        <g:message code="task.showDetails.not_validated"/>
                                    </span>
                                </g:else>

                            </td>
                        </tr>
                        <tr>
                            <td><g:message code="task.showDetails.date_last_updated"/></td>
                            <td>${taskInstance.dateLastUpdated?.format("yyyy-MM-dd HH:mm:ss")}</td>
                        </tr>

                        <tr>
                            <td><g:message code="task.showDetails.external_url"/></td>
                            <td>${taskInstance.externalUrl}</td>
                        </tr>

                        <tr>
                            <td><g:message code="task.showDetails.is_valid"/></td>
                            <td>
                                <g:if test="${taskInstance.isValid != null}">
                                    ${taskInstance.isValid}
                                </g:if>
                                <g:else>
                                    <span class="muted">
                                        <g:message code="task.showDetails.not_set"/>
                                    </span>
                                </g:else>

                            </td>
                        </tr>
                        <tr>
                            <td><g:message code="task.showDetails.views"/></td>
                            <td>
                                <ul>
                                    <g:each in="${taskInstance.viewedTasks?.sort({ it.lastView })}" var="view">
                                        <li><g:message code="task.showDetails.viewed_by"/> <cl:userDisplayString
                                                id="${view.userId}"/> ${view.numberOfViews > 1 ? "(" + view.numberOfViews + " "+message(code:'task.showDetails.times')+")" : ""} <g:message code="task.showDetails.on"/> ${view.lastUpdated?.format("yyyy-MM-dd HH:mm:ss")})</li>
                                    </g:each>
                                </ul>
                            </td>
                        </tr>
                        <tr>
                            <td><g:message code="task.showDetails.comments"/></td>
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
            <div class="col-sm-12">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3><g:message code="task.showDetails.fields"/></h3>
                    </div>
                    <table class="table table-bordered table-condensed">
                    <thead>
                    <g:sortableColumn property="id" title="${message(code:'task.showDetails.id')}"/>
                    <g:sortableColumn property="name" title="${message(code:'task.showDetails.field')}"/>
                    <g:sortableColumn property="recordIdx" title="${message(code:'task.showDetails.index')}"/>
                    <g:sortableColumn property="superceded" title="${message(code:'task.showDetails.superceded')}"/>
                    <g:sortableColumn property="value" title="${message(code:'task.showDetails.value')}"/>
                    <g:sortableColumn property="created" title="${message(code:'task.showDetails.date_created')}"/>
                    <g:sortableColumn property="updated" title="${message(code:'task.showDetails.date_updated')}"/>
                    <g:sortableColumn property="transcribedByUserId" title="${message(code:'task.showDetails.transcriber')}"/>
                    <g:sortableColumn property="validatedByUserId" title="${message(code:'task.showDetails.validator')}"/>
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
    </div>
</g:else>
</section>
<asset:javascript src="bootstrap" asset-defer=""/>
<asset:javascript src="image-viewer" asset-defer=""/>

<asset:script type="text/javascript">


    $(document).ready(function () {
        setupPanZoom();
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
