<%@ page import="org.springframework.validation.FieldError; au.org.ala.volunteer.Institution" %>
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
    <content tag="pageTitle">General Settings</content>
    <content tag="adminButtonBar">
        <g:if test="${institutionInstance?.isApproved}">
            <a class="btn btn-default" href="${createLink(controller: 'institution', action: 'index', id: institutionInstance.id)}"><i
                    class="icon-eye-open"></i> View client page</a>
        </g:if>
    </content>

    <div id="edit-institution" class="content scaffold-edit" role="main">
        <g:hasErrors bean="${institutionInstance}">
            <ul class="errors" role="alert">
                <g:eachError bean="${institutionInstance}" var="error">
                    <li <g:if test="${error in FieldError}">data-field-id="${error.field}"</g:if>><g:message
                            error="${error}"/></li>
                </g:eachError>
            </ul>
        </g:hasErrors>

        <g:form class="form-horizontal" controller="institutionAdmin" action="update" id="${institutionInstance?.id}" method="PUT">
            <g:hiddenField name="version" value="${institutionInstance?.version}"/>
            <g:render template="form" model="[mode: 'edit']"/>
            <div class="form-group">
                <div class="col-md-offset-3 col-md-9">
                <g:if test="${!institutionInstance?.isApproved && !institutionInstance.createdBy}">
                    <b>Note:</b> This institution's contact/admin does not have an ALA account. You will be assigned
                    Institution Admin when approving this institution.<br /><br />
                </g:if>
                    <g:submitButton class="save btn btn-primary" name="update"
                                    value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                    <g:if test="${!institutionInstance?.isApproved}">
                        <g:actionSubmit class="save btn btn-success" name="approve"
                                        value="${message(code: 'default.button.approve.label', default: 'Approve')}"/>
                    </g:if>
                </div>
            </div>
        </g:form>

        <g:if test="${institutionInstance?.isApproved}">
        <div>
            <h3>Logo</h3>

            <div class="alert alert-info">
                For best results a centered square image between <strong>200px and 150px</strong> for width and height
                is recommended. The logo will appear in the list of institutions, as well as on the institution index
                (home) page
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
        </g:if>
    </div>
    <asset:javascript src="bootstrap-file-input" asset-defer=""/>
    <asset:script>

        $(function() {
            $("#btnUploadLogoImage").click(function(e) {
                e.preventDefault();
                bvp.showModal({
                    url: "${createLink(action: "uploadLogoImageFragment", id: institutionInstance.id)}",
                    title: "Upload institution logo"
                });
            });
        });

    </asset:script>
</body>
</html>
