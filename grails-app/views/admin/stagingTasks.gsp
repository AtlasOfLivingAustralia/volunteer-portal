<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.stagingQueue.label" default="Administration - Staging Tasks"/></title>
    <r:require module="bootbox"/>
    <r:script type='text/javascript'>

        jQuery(function ($) {
            $('#button-bar').find('button.btn-danger').click(function (e) {
                bootbox.confirm("Are you sure you want to " + e.target.dataset.message + "?", e.target.dataset.cancel, e.target.dataset.confirm, function (result) {
                    if (result) {
                        window.open(e.target.dataset.href, "_self");
                    }
                })
            })
        })

    </r:script>
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
                                data-cancel="Dismiss" class="btn btn-danger">Cancel Staging Queue</button>
                        <button id="clear" data-href="${createLink(action: 'clearStagingQueue')}"
                                data-message="clear the staging queue (this is highly risky)" data-confirm="Clear Queue"
                                data-cancel="Dismiss" class="btn btn-danger">Clear Staging Queue</button>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <h3>Staging Queue:</h3>
                    <table class="table">
                        <thead>
                        <th>
                        <td>Project</td>
                        <td>External identifier</td>
                        <td>Image URL</td>
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
                            <dt>Start Time</dt>
                            <dd>${status.startTime}</dd>
                            <dt>Total Tasks</dt>
                            <dd>${status.totalTasks}</dd>
                            <dt>Current Item</dt>
                            <dd>${status.currentItem}</dd>
                            <dt>Queue Length</dt>
                            <dd>${status.queueLength}</dd>
                            <dt>Tasks Loaded</dt>
                            <dd>${status.tasksLoaded}</dd>
                            <dt>Started By</dt>
                            <dd>${status.startedBy}</dd>
                            <dt>Time Remaining</dt>
                            <dd>${status.timeRemaining}</dd>
                            <dt>Error Count</dt>
                            <dd>${status.errorCount}</dd>
                        </dl>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
