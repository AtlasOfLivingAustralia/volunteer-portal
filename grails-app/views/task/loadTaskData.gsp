<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.label" default="Administration"/></title>
    <r:require modules="bootstrap-file-input"/>
</head>

<body class="admin">

<cl:headerContent title="Load Task Data" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.featuredLabel],
                [link: createLink(controller: 'project', action: 'editTaskSettings', id: projectInstance.id), label: "Edit Project"]
        ]
    %>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">

                    <div id="fieldDataSection" class="section">
                        <h4>Upload a csv data file for field values</h4>
                        <g:if test="${hasDataFile}">
                            A data file has been uploaded for this project.
                            <a class="button"
                               href="${createLink(action: 'clearTaskDataFile', params: [projectId: projectInstance.id])}">Clear data file</a>
                            &nbsp;
                            <a href="${dataFileUrl}">View data file</a>
                        </g:if>
                        <g:else>
                            <g:form controller="task" action="uploadTaskDataFile" method="post" enctype="multipart/form-data">
                                <input type="file" name="dataFile" id="dataFile"  data-filename-placement="inside"/>
                                <g:hiddenField name="projectId" value="${projectInstance.id}"/>
                                <g:submitButton class="btn btn-success" name="Upload Data File"/>
                            </g:form>
                        </g:else>
                    </div>

                    <hr/>

                    <div id="fieldValuesSection" class="section">

                        <h4>
                            Task Data to load preview <a class="btn btn-primary"
                                                         href="${createLink(action: 'processTaskDataLoad', params: [projectId: projectInstance.id])}">Load Task Data</a>
                        </h4>
                        <table class="table table-striped table-hover">
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
                                <g:set var="valueMap" value="${fieldValues[externalId]}"/>
                                <g:set var="taskInstance"
                                       value="${Task.findByExternalIdentifierAndProject(externalId, projectInstance)}"/>
                                <tr class="${taskInstance ? 'existingTask' : 'noExistingTask'}">
                                    <td>
                                        <g:set var="taskInstance"
                                               value="${Task.findByExternalIdentifierAndProject(externalId, projectInstance)}"/>
                                        <g:if test="${taskInstance}">
                                            <a href="${createLink(controller: 'task', action: 'show', id: taskInstance.id)}">${taskInstance.id}</a>
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
        </div>
    </div>
</div>

<r:script>
    $(function() {
        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();
    });
</r:script>
</body>
</html>
