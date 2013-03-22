<%@ page import="au.org.ala.volunteer.Task" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <style type="text/css">

        .bvp-expeditions td button {
            margin-top: 5px;
        }

        .section {
            border: 1px solid #a9a9a9;
            padding: 10px;
            margin-bottom: 10px;
        }
        .section h4 {
            margin-bottom: 5px;
        }

        tr.noExistingTask {
            background-color: rosybrown;
        }

        </style>
        <script type='text/javascript'>

            $(document).ready(function () {
            });

        </script>
    </head>

    <body class="sublevel sub-site volunteerportal">

        <cl:navbar/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a class="home" href="${createLink(controller: 'project', action: 'index', id: projectInstance.id)}">${projectInstance.featuredLabel}</a>
                        <li><a class="home" href="${createLink(controller: 'project', action: 'edit', id: projectInstance.id)}">Edit Project</a>
                        </li>
                        <li class="last">Load Task Data</li>
                    </ol>
                </nav>
                <hgroup>
                    <h1>Load Task Data</h1>
                </hgroup>
            </div>
        </header>

        <div>
            <div class="inner">

                <div id="fieldDataSection" class="section">
                    <h4>Upload a csv data file for field values</h4>
                    <g:if test="${hasDataFile}">
                        A data file has been uploaded for this project.
                        <a class="button" href="${createLink(action:'clearTaskDataFile', params:[projectId:projectInstance.id])}">Clear data file</a>
                        &nbsp;
                        <a href="${dataFileUrl}">View data file</a>
                    </g:if>
                    <g:else>
                        <g:form controller="task" action="uploadTaskDataFile" method="post" enctype="multipart/form-data">
                            <input type="file" name="dataFile" id="dataFile" />
                            <g:hiddenField name="projectId" value="${projectInstance.id}"/>
                            <g:submitButton name="Upload Data File"/>
                        </g:form>
                    </g:else>
                </div>

                <div id="fieldValuesSection" class="section">

                    <div>
                        <small><a class="button orange" href="${createLink(action:'processTaskDataLoad',params:[projectId: projectInstance.id])}">Load Task Data</a></small>
                    </div>

                    <hr/>

                    <h4>Task Data to load preview</h4>
                    <table class="bvp-expeditions">
                        <thead>
                            <tr>
                                <th style="text-align: left">Task Id</th>
                                <th style="text-align: left">External Id</th>
                                <g:each in="${columnNames}" var="columnName">
                                    <th style="text-align: left">${columnName}</th>
                                </g:each>
                            </tr>
                        </thead>
                        <tbody>
                            <g:each in="${fieldValues.keySet()}" var="externalId">
                                <g:set var="valueMap" value="${fieldValues[externalId]}" />
                                <g:set var="taskInstance" value="${Task.findByExternalIdentifierAndProject(externalId, projectInstance)}"/>
                                <tr class="${taskInstance ? 'existingTask' : 'noExistingTask'}">
                                    <td>
                                        <g:set var="taskInstance" value="${Task.findByExternalIdentifierAndProject(externalId, projectInstance)}"/>
                                        <g:if test="${taskInstance}">
                                            <a href="${createLink(controller: 'task', action:'show', id:taskInstance.id)}">${taskInstance.id}</a>
                                        </g:if>
                                        <g:else>
                                            No task found!
                                        </g:else>
                                    </td>
                                    <td>${externalId}</td>
                                    <g:each in="${columnNames}" var="columnName">
                                        <td>${valueMap[columnName]}</td>
                                    </g:each>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </body>
</html>
