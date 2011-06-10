<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="main"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title>Thank you - we are done for now!</title>
    <script type="text/javascript">
        $(document).ready(function() {
            $("li#goBack a").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'task', id: id, controller:'transcribe')}";
            });

            $("li#viewList a").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'list', controller:'task')}";
            });

            $("li#viewTask a").click(function(e) {
                e.preventDefault();
                window.location.href = "${createLink(action:'index', controller:'transcribe')}";
            });

            $("li#viewStats a").click(function(e) {
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
        <ul>
            <li id="goBack"><a href="#">Return to the saved task</a></li>
            <li id="viewTask"><a href="#">Transcribe another task</a></li>
            <li id="viewList"><a href="#">View list of Tasks</a></li>
            <li id="viewStats"><a href="#">View My Stats</a></li>
        </ul>
    </div>
</div>
</body>
</html>
