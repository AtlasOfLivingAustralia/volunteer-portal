<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Create a new Expedition - Success!</title>

    <r:script type="text/javascript">

        $(document).ready(function () {
        });

    </r:script>

    <style type="text/css">
    </style>
</head>

<body class="content">

<cl:headerContent title="Create a new Expedition - Expedition created" selectedNavItem="expeditions">
    <%
        pageScope.crumbs = [
        ]
    %>
</cl:headerContent>

<div class="well well-small">
    <g:form>
        <h3>Your expedition has been created!</h3>

        <p>
            <strong>Note:</strong> Your expedition is currently inactive, and transcribers will not be able to see it in the expeditions list until you mark it as active,
        which you should only do once your tasks are loaded.
        </p>

        <p>
            You can now go to the task staging area and upload the images for each of your tasks <g:link
                    controller="task" action="staging" params="${[projectId: projectId]}">here</g:link>
        </p>

        <p>
            OR
        </p>

        <p>
            You can edit it's settings <g:link controller="project" action="edit" id="${projectId}">here</g:link>.
        </p>

        <g:link class="btn" event="finish">Done</g:link>
        <g:link class="btn" event="createAnother">Create a another project</g:link>
    </g:form>
</div>

</body>
</html>
