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
            <h3>Welcome to the New Expedition wizard</h3>
            <div>
                Before you start you will need the following:
                <ul>
                    <li>A name for your expedition, and a description</li>
                    <li>An image that represents your expedition (JPEG sized 254 x 158 pixels)</li>
                    <li>A collection of images, each representing a task to be transcribed</li>
                    <li>A template for transcribing each task. These are created from the Admin page</li>
                    <li>(Optional) Picklists for fields on your template. These can be uploaded through the Admin page</li>
                    <li>(Optional) Tutorials or helpful web links. Tutorial files can be uploaded from the Admin page</li>
                    <li>(Optional) A csv data file containing additional data for each task</li>
                </ul>
                <p>
                    Click 'Continue' to start the process of creating a new Expedition in the Volunteer Portal.
                </p>
            </div>
            <g:link class="btn" event="cancel">Cancel</g:link>
            <g:link class="btn btn-primary" event="continue">Start&nbsp;<i class="icon-chevron-right icon-white"></i></g:link>
        </div>

    </body>
</html>
