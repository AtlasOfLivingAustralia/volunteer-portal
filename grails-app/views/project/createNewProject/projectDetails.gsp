<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title>Create a new Expedition - Details</title>

    <r:script type="text/javascript">

        $(document).ready(function () {
            bvp.bindTooltips();
            bvp.suppressEnterSubmit();

            $("#btnNext").click(function (e) {
                e.preventDefault();
                bvp.submitWithWebflowEvent($(this));
            });

        });


    </r:script>

    <style type="text/css">
    </style>
</head>

<body class="content">

<cl:headerContent title="Create a new Expedition - Details" selectedNavItem="expeditions">
    <%
        pageScope.crumbs = [
        ]
    %>
</cl:headerContent>

<g:if test="${errorMessages}">
    <div class="alert alert-error">
        Please correct the following before proceeding:
        <ul>
            <g:each in="${errorMessages}" var="errorMessage">
                <li>
                    ${errorMessage}
                </li>
            </g:each>
        </ul>
    </div>
</g:if>

<div class="well well-small">
    <g:form>
        <div class="form-horizontal">

            <div class="control-group">
                <label class="control-label" for="projectName">Expedition name</label>

                <div class="controls">
                    <g:textField class="input-xlarge" name="projectName" id="projectName" value="${project.name}"/>
                    <cl:helpText>Will be displayed on the front page and in the expeditions list</cl:helpText>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="shortDescription">Short description</label>

                <div class="controls">
                    <g:textField class="input-xxlarge" name="shortDescription" value="${project.shortDescription}"/>
                    <cl:helpText>Used on the front page if your expedition is Expedition Of The Day</cl:helpText>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="longDescription">Long description</label>

                <div class="controls">
                    <g:textArea rows="8" class="input-xxlarge" name="longDescription"
                                value="${project.longDescription}"/>
                    <cl:helpText>Displayed on the expedition front page</cl:helpText>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="templateId">Template</label>

                <div class="controls">
                    <g:select name="templateId" from="${templates}" value="${project.templateId}" optionKey="id"/>
                    <cl:helpText>The template determines what fields are transcribed</cl:helpText>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="projectTypeId">Expedition type</label>

                <div class="controls">
                    <g:select name="projectTypeId" from="${projectTypes}" value="${project.projectTypeId}"
                              optionValue="label" optionKey="id"/>
                </div>
            </div>

            <div class="control-group">
                <div class="controls">
                    <g:link class="btn" event="cancel">Cancel</g:link>
                    <g:link class="btn" event="back"><i class="icon-chevron-left"></i>&nbsp;Back</g:link>
                    <button id="btnNext" event="continue" class="btn btn-primary">Next&nbsp;<i
                            class="icon-chevron-right icon-white"></i></button>
                </div>
            </div>

        </div>
    </g:form>
</div>

</body>
</html>
