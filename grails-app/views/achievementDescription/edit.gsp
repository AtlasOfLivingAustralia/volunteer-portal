<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="achievementSettingsLayout">
		<g:set var="entityName" value="${message(code: 'achievementDescription.label', default: 'AchievementDescription')}" />
		<title><g:message code="default.edit.label" args="[entityName]" /></title>
	</head>
	<body>
		<a href="#edit-achievementDescription" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
				<li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]" /></g:link></li>
				<li><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></li>
			</ul>
		</div>
		<div id="edit-achievementDescription" class="content scaffold-edit" role="main">
			<h1><g:message code="default.edit.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
			<div class="message" role="status">${flash.message}</div>
			</g:if>
			<g:hasErrors bean="${achievementDescriptionInstance}">
			<ul class="errors" role="alert">
				<g:eachError bean="${achievementDescriptionInstance}" var="error">
				<li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message error="${error}"/></li>
				</g:eachError>
			</ul>
			</g:hasErrors>
			<g:form url="[resource:achievementDescriptionInstance, action:'update']" method="PUT" >
				<g:hiddenField name="version" value="${achievementDescriptionInstance?.version}" />
				<fieldset class="form">
					<g:render template="form"/>
				</fieldset>
				<fieldset class="buttons">
					<g:actionSubmit class="save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" />
				</fieldset>
			</g:form>
            <g:if test="${achievementDescriptionInstance?.id > 0}">
                <hr />
                <h2>Images</h2>

                <table class="table">
                    <tr>
                        <td>
                            <img src="<cl:achievementBadgeUrl id="${achievementDescriptionInstance.id}" />">
                        </td>
                        <td>
                            <h3>Institution image</h3>
                            <div class="alert alert-info">
                                Institution images should be 300 x 150 pixels. They appear on the institution index (or home) page.
                            </div>
                            <div>
                                <button class="btn" type="button" id="btnUploadInstitutionImage">Upload image</button>
                            </div>
                        </td>
                    </tr>
                </table>
            </g:if>
		</div>
	</body>
</html>
