<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title>Create a new Expedition - Expedition Details</title>

        <r:script type="text/javascript">

            $(document).ready(function() {
            });

        </r:script>

        <style type="text/css">
        </style>

    </head>
    <body>

        <cl:headerContent title="Create a new Expedition - Expedition Details" selectedNavItem="expeditions">
            <%
                pageScope.crumbs = [
                ]
            %>
        </cl:headerContent>

        <div class="well well-small">
            <g:form>
                <div class="horizontal-form">
                    <div class="control-group">
                        <label class="control-label" for="projectName">Expedition name</label>
                        <div class="controls">
                            <g:textField name="projectName" id="projectName" value="${projectName}" />
                        </div>
                    </div>
                </div>
                <g:link class="btn btn-small" event="cancel">Cancel</g:link>
                <g:link class="btn btn-small" event="back"><i class="icon-chevron-left"></i>&nbsp;Previous</g:link>
                <g:submitButton name="continue" class="btn btn-small btn-primary" value="Next" />
            </g:form>
        </div>

    </body>
</html>
