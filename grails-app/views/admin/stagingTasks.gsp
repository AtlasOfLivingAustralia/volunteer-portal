<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.stagingQueue.title" default="Administration - Staging Tasks"/></title>
</head>

<body class="admin">

<cl:headerContent title="${message(code: 'admin.stagingQueue.label', default: 'Staging Queue')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'admin', action: 'tools'), label: message(code: 'default.tools.label', default: 'Tools')]
        ]
    %>
</cl:headerContent>
<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <div id="button-bar" class="well well-small">
                        <button id="cancel" data-href="${createLink(action: 'cancelStagingQueue')}"
                                data-message="send a cancel request to the staging queue" data-confirm="Send Cancel Message"
                                data-cancel="Dismiss" class="btn btn-danger"><g:message code="admin.staging_tasks.cancel" /></button>
                        <button id="clear" data-href="${createLink(action: 'clearStagingQueue')}"
                                data-message="clear the staging queue (this is highly risky)" data-confirm="Clear Queue"
                                data-cancel="Dismiss" class="btn btn-danger"><g:message code="admin.staging_tasks.clear" /></button>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <h3><g:message code="admin.staging_tasks.staging_queue" /></h3>
                    <table class="table">
                        <thead>
                        <th>
                        <td><g:message code="admin.staging_tasks.project" /></td>
                        <td><g:message code="admin.staging_tasks.external_id" /></td>
                        <td><g:message code="admin.staging_tasks.image_url" /></td>
                        </th>
                        </thead>
                        <tbody>
                        <g:each in="${queueItems}" status="i" var="taskDescriptor">
                            <tr>
                                <td>$taskDescriptor?.project?.name</td>
                                <td>$taskDescriptor?.externalIdentifier</td>
                                <td>$taskDescriptor?.imageUrl</td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="well">
                        <dl class="inline">
                            <dt><g:message code="admin.staging_tasks.start_time" /></dt>
                            <dd>${status.startTime}</dd>
                            <dt><g:message code="admin.staging_tasks.total_tasks" /></dt>
                            <dd>${status.totalTasks}</dd>
                            <dt><g:message code="admin.staging_tasks.current_item" /></dt>
                            <dd>${status.currentItem}</dd>
                            <dt><g:message code="admin.staging_tasks.queue_length" /></dt>
                            <dd>${status.queueLength}</dd>
                            <dt><g:message code="admin.staging_tasks.tasks_loaded" /></dt>
                            <dd>${status.tasksLoaded}</dd>
                            <dt><g:message code="admin.staging_tasks.started_by" /></dt>
                            <dd>${status.startedBy}</dd>
                            <dt><g:message code="admin.staging_tasks.time_remaining" /></dt>
                            <dd>${status.timeRemaining}</dd>
                            <dt><g:message code="admin.staging_tasks.error_count" /></dt>
                            <dd>${status.errorCount}</dd>
                        </dl>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="bootbox" asset-defer=""/>
<asset:script type='text/javascript'>

    jQuery(function ($) {
        $('#button-bar').find('button.btn-danger').click(function (e) {
            bootbox.confirm("Are you sure you want to " + e.target.dataset.message + "?", e.target.dataset.cancel, e.target.dataset.confirm, function (result) {
                if (result) {
                    window.open(e.target.dataset.href, "_self");
                }
            })
        })
    })

</asset:script>
</body>
</html>
