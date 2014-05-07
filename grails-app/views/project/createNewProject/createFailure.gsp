<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Create a new Expedition - Failure</title>

    <r:script type="text/javascript">

        $(document).ready(function() {
        });

    </r:script>

    <style type="text/css">
    </style>
</head>
<body class="content">

<cl:headerContent title="Create a new Expedition - Failed to create project" selectedNavItem="expeditions">
    <%
        pageScope.crumbs = [
        ]
    %>
</cl:headerContent>

<div class="well well-small">
    <g:form>
        <h3>Boo! Something went wrong</h3>

        <g:link class="btn btn-small" event="finish">Done</g:link>
        <g:link class="btn btn-small" event="createAnother">Create a another project</g:link>
    </g:form>
</div>

</body>
</html>
