<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title><g:message code="validate.noTask.thank_you_were_done" /></title>
    <asset:javascript src="amplify" asset-defer=""/>
    <asset:script type="text/javascript">
            $(document).ready(function () {
                // clear the temporarily saved state, now that it is known that the task was saved
                amplify.store("bvp_task_${taskInstance.id}", null);
            });
    </asset:script>

</head>

<body class="admin">
<cl:navbar selected="expeditions"/>

<header id="page-header">
    <div class="inner">
        <cl:messages/>
        <nav id="breadcrumb">
            <ol>
                <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                <li class="last"><g:message code="validate.noTask.thank_you_were_done" /></li>
            </ol>
        </nav>
        <hgroup>
            <h1><g:message code="validate.noTask.thank_you_were_done" /></h1>
        </hgroup>
    </div>
</header>

<div class="inner">
    <p><g:message code="validate.noTask.no_new_tasks_ready" /></p>

    <p><g:message code="validate.noTask.please_check_back_later" /></p>
</div>
</body>
</html>
