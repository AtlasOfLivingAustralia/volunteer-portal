<%@ page import="au.org.ala.volunteer.Task" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'task.label', default: 'Task')}"/>
        <title>Thank you - we are done for now!</title>
    </head>

    <body>

        <cl:headerContent title="Thank you - we are done for now !" crumbLabel="Thanks - we're done!"/>

        <div class="row">
            <div class="span12">
                <p style="text-align: center">There are currently no new tasks ready to transcribe.</p>
                <p style="text-align: center">Please check back later for more transcription tasks.</p>
            </div>
        </div>
    </body>
</html>
