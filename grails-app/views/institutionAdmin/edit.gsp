<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Institution" %>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-institutionSettings"/>
    <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <asset:stylesheet src="bootstrap-colorpicker"/>
</head>

<body>

<content tag="pageTitle"><g:message code="institutionAdmin.edit.general_settings"/></content>

<content tag="adminButtonBar">
    <a class="btn btn-default" href="${createLink(controller: 'institution', action: 'index', id: institutionInstance.id)}"><i
            class="icon-eye-open"></i> <g:message code="institutionAdmin.edit.view_client_page"/></a>
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

    <g:form class="form-horizontal" url="[controller: 'institutionAdmin', id: institutionInstance?.id, action: 'update']" method="PUT" accept-charset="UTF-8">
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
        <h3><g:message code="institutionAdmin.edit.logo"/></h3>

        <div class="alert alert-info">
            <g:message code="institutionAdmin.edit.logo.description"/>
        </div>

        <div class="text-center">
            <div class="thumbnail display-inline-block">
                <img class="img-responsive" src="<cl:institutionLogoUrl id="${institutionInstance.id}"/>"/>
            </div>

            <div>
            <button class="btn btn-default" type="button" id="btnUploadLogoImage">Upload logo</button>
            <cl:ifInstitutionHasLogo institution="${institutionInstance}">
                <a href="${createLink(action: 'clearLogoImage', id: institutionInstance.id)}"
                   class="btn btn-danger"><g:message code="institutionAdmin.edit.clear_logo"/></a>
            </cl:ifInstitutionHasLogo>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="bootstrap-file-input" asset-defer=""/>
<asset:script>

            $(function() {
                $("#btnUploadLogoImage").click(function(e) {
                    e.preventDefault();
                    bvp.showModal({
                        url: "${createLink(action: "uploadLogoImageFragment", id: institutionInstance.id)}",
                        title: "${message(code: 'institutionAdmin.edit.upload_logo')}"
                    });
                });
            });

</asset:script>
</body>
</html>
