<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title>Create a new Expedition - Success!</title>

        <r:script type="text/javascript">

            $(document).ready(function() {
            });

        </r:script>

        <style type="text/css">
        </style>
    </head>
    <body class="content">

        <cl:headerContent title="Create a new Expedition - Expedition Details" selectedNavItem="expeditions">
            <%
                pageScope.crumbs = [
                ]
            %>
        </cl:headerContent>

        <div class="well well-small">
            <g:form>
                <h3>Your project has been created!</h3>
                <p>
                    <strong>Note:</strong> Your project is currently inactive, and transcribers will not be able to see it in the expeditions list until you mark it as active,
                    which you should only do once your tasks are loaded.
                </p>
                <p>
                    You can now go to the task staging area and upload the images for each of your tasks <g:link controller="task" action="staging" params="${[projectId: projectId]}">here</g:link>
                </p>
                <p>
                    OR
                </p>
                <ul>
                    <li>
                        You can visit the project landing page <g:link controller="project" action="index" id="${projectId}">here</g:link>.
                    </li>
                    <li>
                        You can edit it's settings <g:link controller="project" action="edit" id="${projectId}">here</g:link>.
                    </li>
                    <li>
                        You can view the the administration/validation area <g:link controller="task" action="projectAdmin" id="${projectId}">here</g:link>.
                    </li>
                </ul>

                <g:link class="btn btn-small" event="finish">Done</g:link>
                <g:link class="btn btn-small" event="createAnother">Create a another project</g:link>
            </g:form>
        </div>

    </body>
</html>
