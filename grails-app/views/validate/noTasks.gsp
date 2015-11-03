<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title>Thank you - we are done for now!</title>
    <r:require module="amplify"/>
    <r:script type="text/javascript">
            $(document).ready(function () {
                // clear the temporarily saved state, now that it is known that the task was saved
                amplify.store("bvp_task_${taskInstance.id}", null);
            });
    </r:script>

</head>

<body class="admin">
<cl:navbar selected="expeditions"/>

<header id="page-header">
    <div class="inner">
        <cl:messages/>
        <nav id="breadcrumb">
            <ol>
                <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                <li class="last">Thanks - we're done!</li>
            </ol>
        </nav>
        <hgroup>
            <h1>Thank you - we are done for now !</h1>
        </hgroup>
    </div>
</header>

<div class="inner">
    <p>There are currently no new tasks ready to be validated.</p>

    <p>Please check back later for more validation tasks.</p>
</div>
</body>
</html>
