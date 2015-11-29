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
                amplify.store("bvp_task_${taskInstance?.id}", null);
        <g:if test="${complete}">
            amplify.store("bvp_task_${complete}", null);
        </g:if>
        });
    </r:script>

</head>

<body class="admin  ">

<cl:headerContent title="Thank you - we are done for now !" crumbLabel="Thanks - we're done!"/>

<div class="container">
    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">

                <div class="panel-body">
                    <p style="text-align: center">There are currently no new tasks ready to transcribe.</p>

                    <p style="text-align: center">Please check back later for more transcription tasks.</p>
                </div>
            </div>

        </div>
    </div>
</div>
</body>
</html>
