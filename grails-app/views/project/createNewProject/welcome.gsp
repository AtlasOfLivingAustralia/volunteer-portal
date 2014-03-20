<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title>Create a new Expedition</title>

        <r:script type="text/javascript">

            $(document).ready(function() {
            });

        </r:script>

        <style type="text/css">
        </style>

    </head>
    <body>

        <cl:headerContent title="Create a new Expedition" selectedNavItem="expeditions">
            <%
                pageScope.crumbs = [
                ]
            %>
        </cl:headerContent>

        <div class="well well-small">
            <h3>Welcome to the New Expedition Wizard</h3>
            <div>
                Before you start you will need the following:
                <ul>
                    <li>A name and other details for your expedition</li>
                    <li>A collection of images, each representing a task to be transcribed</li>
                    <li>(optional) A csv data file containing additional data for each task (keyed by image filename)</li>
                </ul>
                <p>
                    Click 'Continue' to start the process of creating a new Expedition in the Volunteer Portal.
                </p>
            </div>
            <g:link class="btn btn-small" event="cancel">Cancel</g:link>
            <g:link class="btn btn-small btn-primary" event="continue">Continue&nbsp;<i class="icon-chevron-right icon-white"></i></g:link>
        </div>

    </body>
</html>
