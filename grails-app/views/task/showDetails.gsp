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

        <sitemesh:parameter name="useFluidLayout" value="${true}" />

        <r:require module="bootstrap-js" />
        <r:require module="panZoom" />
        <r:require module="imageViewerCss" />

        <r:script>


            $(document).ready(function () {
                setupPanZoom();
            });

            function setupPanZoom() {
                var target = $("#image-container img");
                if (target.length > 0) {
                    target.panZoom({
                        pan_step:10,
                        zoom_step:10,
                        min_width:200,
                        min_height:200,
                        mousewheel:true,
                        mousewheel_delta:5,
                        'zoomIn':$('#zoomin'),
                        'zoomOut':$('#zoomout'),
                        'panUp':$('#pandown'),
                        'panDown':$('#panup'),
                        'panLeft':$('#panright'),
                        'panRight':$('#panleft')
                    });

                    target.panZoom('fit');
                }
            }

        </r:script>

        <style type="text/css">

            #image-container, #image-parent-container {
                background-color: #a9a9a9;
            }

            tr.fieldrow[superceded="true"] td {
                background-color: palevioletred;
            }

        </style>

    </head>

    <body>

        <cl:headerContent title="Task Details - ${taskInstance.id}">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'list'), label: message(code: 'default.expeditions.label', default: 'Expeditions')],
                    [link: createLink(controller: 'project', action: 'index', id:taskInstance?.project?.id), label: taskInstance?.project.featuredLabel]
                ]
            %>

            <div>
                <g:if test="${sequenceNumber >= 0}">
                    <span>Image sequence number: ${sequenceNumber}</span>
                </g:if>
            </div>
        </cl:headerContent>

        <div class="container-fluid">
            <div class="row-fluid">
                <div class="span6">
                    <div>
                        <g:set var="multimedia" value="${taskInstance.multimedia.first()}" />
                        <g:imageViewer multimedia="${multimedia}" />
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
                                <td>${taskInstance.dateFullyTranscribed?.format("yyyy-MM-dd HH:mm:ss")} by ${taskInstance.fullyTranscribedBy}</td>
                            </tr>
                            <tr>

                                <td>Validated</td>
                                <td>${taskInstance.dateFullyValidated?.format("yyyy-MM-dd HH:mm:ss")} by ${taskInstance.fullyValidatedBy}</td>
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
                                <td>${taskInstance.isValid}</td>
                            </tr>
                            <tr>
                                <td>Views (${taskInstance.viewed})</td>
                                <td>
                                    <ul>
                                        <g:each in="${taskInstance.viewedTasks}" var="view">
                                            <li>${view.numberOfViews} times (last view by ${view.userId} on ${view.lastUpdated?.format("yyyy-MM-dd HH:mm:ss")})</li>
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
                                            <i>${comment.user?.displayName}</i> on ${comment.date?.format("yyyy-MM-dd HH:mm:ss")}
                                            <br/>
                                            ${comment.comment}
                                        </li>
                                    </g:each>
                                    </ul>
                                </td>
                            </tr>
                        </table>
                        <cl:validationStatus task="${taskInstance}" />
                    </div>
                </div>
            </div>
            <div class="row-fluid">
                <div class="span12">
                    <h3>Fields</h3>
                    <table class="table table-bordered table-condensed">
                        <thead>
                            <th>FieldID</th>
                            <th>Name</th>
                            <th>Record Index</th>
                            <th>Superceded</th>
                            <th>Value</th>
                            <th>Created</th>
                            <th>Updated</th>
                            <th>Transcriber</th>
                            <th>Validator</th>
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
                                    <td>${field.transcribedByUserId}</td>
                                    <td>${field.validatedByUserId}</td>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </body>
    <r:script>
        $(document).ready(function() {
        });
    </r:script>
</html>
