<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title><g:message code="validate.noTask.thank_you_were_done"/></title>
    <asset:javascript src="amplify" asset-defer=""/>
    <asset:script type="text/javascript">
            $(document).ready(function () {
                // clear the temporarily saved state, now that it is known that the task was saved
                amplify.store("bvp_task_${taskInstance?.id}", null);
        <g:if test="${complete}">
            amplify.store("bvp_task_${complete}", null);
        </g:if>
        });
    </asset:script>

</head>

<body class="admin  ">

<cl:headerContent title="${message(code: 'validate.noTask.thank_you_were_done')}" crumbLabel="${message(code: 'validate.noTask.thank_you_were_done')}"/>

<div class="container">
    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">

                <div class="panel-body">
                    <p style="text-align: center"><g:message code="transcribe.noTask.no_new_tasks_to_transcribe"/></p>

                    <p style="text-align: center"><g:message code="transcribe.noTask.please_check_back_later"/></p>
                </div>
            </div>

        </div>
    </div>
</div>
</body>
</html>
