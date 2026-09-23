<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-landingPage"/>
    <g:set var="entityName" value="${message(code: 'landingPage.label', default: 'Landing Page')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body>

<content tag="pageTitle">Upload Image</content>

<div class="text-center">

    <g:uploadForm controller="landingPageAdmin" action="uploadImage" method="post">
        <g:hiddenField name="id" value="${landingPageInstance.id}" />

        <div>
            <g:if test="${landingPageInstance.landingPageImage}">
                <div class="thumbnail display-inline-block">
                    <img class="img-fluid"
                         src="${grailsApplication.config.getProperty('server.url', String)}/${grailsApplication.config.getProperty('images.urlPrefix', String)}/landingPage/${landingPageInstance.landingPageImage}"/>
                </div>
                <div>
                    ${landingPageInstance.landingPageImage}
                </div>
            </g:if>

            <br>

            <div class="row justify-content-center">
                <div class="col-md-6 text-start">
                    <label class="form-label" for="heroImage">Select file</label>
                    <input id="heroImage" name="heroImage" type="file" class="form-control"/>
                </div>
            </div>

            <div class="display-inline-block">
                <g:submitButton name="clear-hero" class="clear-hero btn btn-sm btn-outline-secondary"
                                value="${message(code: 'default.button.reset.label', default: 'Reset')}"/>
            </div>
        </div>

    </g:uploadForm>

</div>



<asset:script type="text/javascript" asset-defer="">

    $(function() {

        $('#heroImage').change(function(e){
            // submit the forms after the file is selected
            e.target.form.submit();
        });
    });

</asset:script>

</body>
</html>
