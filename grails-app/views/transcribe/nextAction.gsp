<%@ page import="au.org.ala.volunteer.UserService; au.org.ala.volunteer.ViewedTask; au.org.ala.volunteer.Task" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title><cl:pageTitle title="Task saved"/></title>
    <r:require module="amplify"/>
    <r:script type="text/javascript">
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
    </r:script>
</head>

<body class="admin">

<cl:headerContent title="Transcription Saved" crumbLabel="What next?"/>
<div class="container">
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="lead">Thank you - your transcription was saved
                        <span id="dateSaved">at <g:formatDate date="${taskInstance.dateLastUpdated}"
                                                              format="h:mm:ss a z 'on' d MMMM yyyy"/>
                    </div>

                    <ul>
                        <li id="viewTask"><button class="btn btn-primary" role="button" autofocus tabindex="1">Transcribe another task</button></li>
                        <li id="goBack"><button class="btn btn-link" tabindex="2">Return to the saved task</button></li>
                        <li id="projectHome"><button class="btn btn-link" tabindex="3">Go to project landing page</button></li>
                        <li id="viewStats"><button class="btn btn-link" tabindex="3">View My Stats</button></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
