<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
	<head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}" />
        <title><g:message code="default.create.label" args="[entityName]" /></title>
        <g:setProvider library="jquery"/>
	</head>
	<body>
        <cl:headerContent title="${message(code:'default.edit.label', args:[entityName])}">
            <%
                pageScope.crumbs = [
                        [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')],
                        [link:createLink(controller:'institutionAdmin'), label:message(code:'default.institutions.label', default:'Manage Institutions')]
                ]
            %>
        </cl:headerContent>
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
				<li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]" /></g:link></li>
				<li><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></li>
			</ul>
		</div>
		<div id="edit-institution" class="content scaffold-edit" role="main">
			<h1><g:message code="default.edit.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
			<div class="message" role="status">${flash.message}</div>
			</g:if>
			<g:hasErrors bean="${institutionInstance}">
			<ul class="errors" role="alert">
				<g:eachError bean="${institutionInstance}" var="error">
				<li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message error="${error}"/></li>
				</g:eachError>
			</ul>
			</g:hasErrors>
            <div class="container-fluid">
                <div class="row-fluid">
                    <div class="span6">
                        <g:form url="[resource:institutionInstance, action:'update']" method="PUT" >
                            <g:hiddenField name="version" value="${institutionInstance?.version}" />
                            <fieldset class="form">
                                <g:render template="form"/>
                            </fieldset>
                            <fieldset class="buttons">
                                <g:actionSubmit class="save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" />
                            </fieldset>
                        </g:form>
                    </div>
                    <div class="span1">
                        <button type="button" id="pop-col-val" class="btn btn-primary" name="pop-col-val" data-loading-text="...">
                            <i id="pop-col-icon" class="icon-arrow-populate icon-white"></i>
                        </button>
                    </div>
                    <div class="span5">
                        <h2>Collectory Info</h2>
                        <g:render template="collectory_info"/>
                    </div>
                </div>
                <div class="row-fluid">
                    <div class="span12">
                        <hr />
                        <h2>Images</h2>
                        <h3>Banner</h3>
                        <img src="<cl:institutionBannerUrl id="${institutionInstance.id}" />">
                        <button class="btn" type="button" id="btnUploadBannerImage">Upload banner</button>
                        <h3>Logo</h3>
                        <img src="<cl:institutionLogoUrl id="${institutionInstance.id}" />">
                        <button class="btn" type="button" id="btnUploadLogoImage">Upload logo</button>
                    </div>
                </div>
            </div>
		</div>
        <r:script>

            $(document).ready(function() {
                $("#btnUploadBannerImage").click(function(e) {
                    e.preventDefault();
                    bvp.showModal({
                        url: "${createLink(action: "uploadBannerImageFragment", id: institutionInstance.id)}",
                        title: "Upload banner image"
                    });
                });

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
