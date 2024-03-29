<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>

</head>

<body class="admin">

<cl:headerContent title="${message(code: "default.progress.label", default: "Task Loading Progress")}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.name ?: 'Project'],
                [link: createLink(controller: 'project', action: 'editTaskSettings', id: projectInstance.id), label: 'Tasks']
        ]
    %>
</cl:headerContent>

<div class="container task-staging">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <div class="alert alert-info">
                        <p>Staged tasks are loaded in batches of ${grailsApplication.config.getProperty('digivol.ingest.queue.size', Integer, 200)} at a time and share a queue with all other projects.  If there are
                        other projects loading at the same time you may not see any progress on your project for a while.</p>
                    </div>
                    <div id="load-progress">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script id="load-progress-template" type="text/x-handlebars">
    <div id="load-progress">
        <h2>Task load progress</h2>
        <table class="table">
            <tr>
                <td>Queued tasks remaining</td>
                <td><b><span id="total_records">{{count}}</span></b></td>
            </tr>
            <tr>
                <td>Time started</td>
                <td><b><span id="time_started">{{timeStarted}}</span></b></td>
            </tr>
            <tr>
                <td>Estimated time of completion</td>
                <td><b><span id="estimated_time_end">{{#finishEstimate}}{{finishEstimate}}{{/finishEstimate}}{{^finishEstimate}}Calculating...{{/finishEstimate}}</span></b></td>
            <tr>
                <td>Tasks being retried</td>
                <td><b><span id="error_count">{{retryCount}}</span></b></td>
            </tr>
            <tr>
                <td>Errors</td>
                <td><b><span id="error_count">{{errorCount}}</span></b></td>
            </tr>
        </table>

        {{^count}}
        <g:link controller="project" action="edit" id="${projectInstance.id}">Back to settings</g:link>
        {{/count}}

</script>

<asset:javascript src="load-progress" asset-defer="" />
<asset:script  type='text/javascript'>
    loadProgress({
        loadProgressUrl: "${createLink(controller: 'ajax', action: 'loadProgress', id: projectInstance.id)}"
    });
</asset:script>
</body>
</html>
