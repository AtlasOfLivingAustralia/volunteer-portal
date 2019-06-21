<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.label" default="Administration"/></title>
</head>

<body class="admin">

<cl:headerContent title="${message(code: 'task.loadTaskData.load_task_data', default: 'Load Task Data')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.i18nName],
                [link: createLink(controller: 'project', action: 'editTaskSettings', id: projectInstance.id), label: "${message(code: 'task.load.edit_project', default: 'Edit project')}"]
        ]
    %>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">

                    <div id="fieldDataSection" class="section">
                        <h4><g:message code="task.loadTaskData.upload_csv"/></h4>
                        <g:if test="${hasDataFile}">
                            <g:message code="task.loadTaskData.data_file_has_been_uploaded"/>
                            <a class="button"
                               href="${createLink(action: 'clearTaskDataFile', params: [projectId: projectInstance.id])}"><g:message code="task.loadTaskData.clear_file"/></a>
                            &nbsp;
                            <a href="${dataFileUrl}"><g:message code="task.loadTaskData.view_file"/></a>
                        </g:if>
                        <g:else>
                            <g:form controller="task" action="uploadTaskDataFile" method="post" enctype="multipart/form-data">
                                <input type="file" name="dataFile" id="dataFile"  data-filename-placement="inside"/>
                                <g:hiddenField name="projectId" value="${projectInstance.id}"/>
                                <g:submitButton class="btn btn-success" name="${message(code:'task.loadTaskData.upload')}"/>
                            </g:form>
                        </g:else>
                    </div>

                    <hr/>

                    <div id="fieldValuesSection" class="section">

                        <h4>
                            <g:message code="task.loadTaskData.task_data_to_load"/> <a class="btn btn-primary"
                                                         href="${createLink(action: 'processTaskDataLoad', params: [projectId: projectInstance.id])}"><g:message code="task.loadTaskData.load_task_data"/></a>
                        </h4>
                        <table class="table table-striped table-hover">
                            <thead>
                            <tr>
                                <th style="text-align: left"><g:message code="task.loadTaskData.task_id"/></th>
                                <th style="text-align: left"><g:message code="task.loadTaskData.external_id"/></th>
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
                                            <g:message code="task.loadTaskData.no_task_found"/>
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
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:script>
    $(function() {
        // Initialize input type file
        $('input[type=file]').bootstrapFileInput();
    });
</asset:script>
</body>
</html>
