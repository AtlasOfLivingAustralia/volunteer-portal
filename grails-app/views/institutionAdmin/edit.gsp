<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-institutionSettings"/>
    <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <g:setProvider library="jquery"/>
    <r:require modules="bootstrap-file-input"/>
</head>

<body>

<content tag="pageTitle">General Settings</content>

<content tag="adminButtonBar">
    <a class="btn btn-default" href="${createLink(controller: 'institution', action: 'index', id: institutionInstance.id)}"><i
            class="icon-eye-open"></i> View client page</a>
</content>

<div id="edit-institution" class="content scaffold-edit" role="main">
    <g:hasErrors bean="${institutionInstance}">
        <ul class="errors" role="alert">
            <g:eachError bean="${institutionInstance}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </g:hasErrors>

    <g:form class="form-horizontal" url="[controller: 'institutionAdmin', id: institutionInstance?.id, action: 'update']" method="PUT">
        <g:hiddenField name="version" value="${institutionInstance?.version}"/>
        <g:render template="form"/>
        <div class="form-group">
            <div class="col-md-offset-3 col-md-9">
                <g:actionSubmit class="save btn btn-primary" action="update"
                                value="${message(code: 'default.button.update.label', default: 'Update')}"/>
            </div>
        </div>
    </g:form>

    <div>
        <h3>Logo</h3>

        <div class="alert alert-info">
            For best results a centered square image between <strong>200px and 150px</strong> for width and height is recommended. The logo will appear in the list of institutions, as well as on the institution index (home) page
        </div>

        <div class="text-center">
            <div class="thumbnail display-inline-block">
                <img class="img-responsive" src="<cl:institutionLogoUrl id="${institutionInstance.id}"/>"/>
            </div>

            <div>
            <button class="btn btn-default" type="button" id="btnUploadLogoImage">Upload logo</button>
            <cl:ifInstitutionHasLogo institution="${institutionInstance}">
                <a href="${createLink(action: 'clearLogoImage', id: institutionInstance.id)}"
                   class="btn btn-danger">Clear logo</a>
            </cl:ifInstitutionHasLogo>
            </div>
        </div>
    </div>
</div>
<r:script>

            $(function() {
                $("#btnUploadLogoImage").click(function(e) {
                    e.preventDefault();
                    bvp.showModal({
                        url: "${createLink(action: "uploadLogoImageFragment", id: institutionInstance.id)}",
                        title: "Upload institution logo"
                    });
                });
            });

</r:script>
</body>
</html>
