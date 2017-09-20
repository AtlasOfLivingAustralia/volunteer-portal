<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.UserService; au.org.ala.volunteer.ViewedTask; au.org.ala.volunteer.Task" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title><cl:pageTitle title="${message(code: 'transcribe.nextAction.task_saved')}"/></title>
    <asset:javascript src="amplify" asset-defer=""/>
    <asset:script type="text/javascript">
            $(document).ready(function () {
                $("li#goBack button").click(function (e) {
                    e.preventDefault();
                    window.location.href = "${createLink(action: 'task', id: id, controller: 'transcribe')}";
                });

                $("li#projectHome button").click(function (e) {
                    e.preventDefault();
                    window.location.href = "${createLink(action: 'index', controller: 'project', id: taskInstance?.project?.id)}";
                });

                $("li#viewTask button").click(function (e) {
                    e.preventDefault();
                    window.location.href = "${createLink(controller: 'transcribe', action: 'showNextFromProject', id: taskInstance?.project?.id, params: [prevId: taskInstance?.id])}";
                });

                $("li#viewStats button").click(function (e) {
                    e.preventDefault();
                    window.location.href = "${createLink(action: 'myStats', controller: 'user')}";
                });

                // clear the temporarily saved state, now that it is known that the task was saved
                amplify.store("bvp_task_${taskInstance.id}", null);
            });
    </asset:script>
</head>

<body class="admin">

<cl:headerContent title="Transcription Saved" crumbLabel="What next?"/>
<div class="container">
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="lead"><g:message code="transcribe.nextAction.thank_you" args="${[formatDate(date: taskInstance.dateLastUpdated, format: 'h:mm:ss a z d MMMM yyyy')]}"/>
                    </div>

                    <ul>
                        <li id="viewTask"><button class="btn btn-primary" role="button" autofocus tabindex="1"><g:message code="transcribe.nextAction.transcribe_another"/></button></li>
                        <li id="goBack"><button class="btn btn-link" tabindex="2"><g:message code="transcribe.nextAction.return_to_the_saved_task"/></button></li>
                        <li id="projectHome"><button class="btn btn-link" tabindex="3"><g:message code="transcribe.nextAction.go_to_landing_page"/></button></li>
                        <li id="viewStats"><button class="btn btn-link" tabindex="3"><g:message code="transcribe.nextAction.view_stats"/></button></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
