<%@ page import="org.apache.commons.lang.StringUtils; au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <style type="text/css">

            #buttonBar {
                margin-bottom: 10px;
            }

            .bvp-expeditions td button {
                margin-top: 5px;
            }

            li[selected=selected] {
                background-color: #98fb98;
            }

            ul {
           	    padding-bottom:3px;
            }

        </style>
        <script type='text/javascript'>

            $(document).ready(function() {

                $(".btnSelectEvent").click(function(e) {
                    e.preventDefault();
                    var fieldId=$(this).attr("fieldId");
                    var eventId=$(this).attr("eventId");
                    if (fieldId && eventId) {
                        var url = "${createLink(controller:'admin', action:'updateEventId')}?fieldId=" + fieldId + "&externalEventId=" + eventId;
                        $.ajax(url).done(function() {
                            $("#field_" + fieldId).html("Updated! Refresh to see current status");
                        });
                    }
                });

            });

        </script>
    </head>

    <body class="sublevel sub-site volunteerportal">

        <cl:navbar />

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li class="last"><g:message code="default.tutorials.label" default="Collection Event Fix"/></li>
                    </ol>
                </nav>
                <hgroup>
                    <h1>Fix Collection Events</h1>
                </hgroup>
            </div>
        </header>

        <div>
            <div class="inner">
                ${fields.size()} Records
                <table class="bvp-expeditions">
                    <thead>
                        <tr>
                            <th>Project</th>
                            <th>Task</th>
                            <th>Current Event</th>
                            <th>Events Code</th>
                            <th>Candidate Events</th>
                        </tr>
                    </thead>
                    <tbody>
                        <g:each in="${fields}" var="field">
                            <tr>
                                <td>${field.task.project.featuredLabel}</td>
                                <td>
                                    ${field.task.id}&nbsp;[&nbsp;<a href="${createLink(controller:'task', action:'showImage', id:field.taskId)}" target="taskImage">Image</a>&nbsp;]
                                    &nbsp;[&nbsp;<a href="${createLink(controller:'task', action:'show', id:field.taskId)}" target="task">Show</a>&nbsp;]
                                </td>
                                <td>${field.value}</td>
                                <td>${field.task.project.collectionEventLookupCollectionCode}</td>
                                <td>
                                    <div id="field_${field.id}">
                                        <g:each in="${candidateMap[field.task.id]}" var="candidate">
                                            <ul>
                                                <li selected="${StringUtils.equals(candidate.externalEventId?.toString(), field.value) ? 'selected' : ''}">
                                                    ${candidate.eventDate}, ${candidate.locality}, ${candidate.collector} [eventId:${candidate.externalEventId}, localityId:${candidate.externalLocalityId}]&nbsp;
                                                    <g:if test="${!StringUtils.equals(candidate.externalEventId?.toString(), field.value)}">
                                                        <a class="button btnSelectEvent" fieldId="${field.id}" eventId="${candidate.externalEventId}">Select</a>
                                                    </g:if>
                                                </li>
                                            </ul>
                                        </g:each>
                                    </div>
                                </td>
                            </tr>
                        </g:each>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>
