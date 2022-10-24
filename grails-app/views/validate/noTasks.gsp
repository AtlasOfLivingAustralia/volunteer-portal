<%@ page import="au.org.ala.volunteer.Task" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
    <title>Thank you - we are done for now!</title>
    <asset:javascript src="amplify" asset-defer=""/>
    <asset:script type="text/javascript">
            $(document).ready(function () {
                // clear the temporarily saved state, now that it is known that the task was saved
                amplify.store("bvp_task_${taskInstance?.id}", null);
            });
    </asset:script>

</head>
<body class="admin  ">

<cl:headerContent title="Thank you - we are done for now !" crumbLabel="Thanks - we're done!"/>

<div class="container">
    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">

                <div class="panel-body">
                    <p style="text-align: center">There are currently no new tasks ready to validate, please check back later</p>

                    <p style="text-align: center"><g:link controller="task" action="projectAdmin" id="${projectId}">Click here to return to the Expedition admin menu</g:link>.</p>
                </div>
            </div>

        </div>
    </div>
</div>
</body>

</html>
