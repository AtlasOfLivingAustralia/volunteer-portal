<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="main"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title>Thank you - we are done for now!</title>
    <script type="text/javascript">
        $(document).ready(function() {
            $("button#goBack").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'task', id: id, controller:'transcribe')}";
            });

            $("button#viewList").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'list', controller:'task')}";
            });

            $("button#viewTask").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'index', controller:'transcribe')}";
            });

            $("button#viewStats").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'myStats', controller:'user')}";
            });
        });
    </script>
</head>

<body class="two-column-right">
<div class="nav">
    <a class="crumb" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    <span>What next?</span>
</div>

<div class="body">
    <h1>Thank you - your transcription has been saved</h1>

    <div class="dialog">
        <p></p>
        <h3>What do you want to do next?</h3>
        <p></p>
        <p>
            <button id="goBack">Return to the task</button>
            <button id="viewTask">Transcribe another task</button>
            <button id="viewList">View list of Tasks</button>
            <button id="viewStats">View My Stats</button>
        </p>
    </div>
</div>
</body>
</html>
