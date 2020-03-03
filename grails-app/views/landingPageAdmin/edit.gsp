<%@ page import="au.org.ala.volunteer.LandingPage" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-landingPage"/>
    <g:set var="entityName" value="${message(code: 'landingPage.label', default: 'Landing Page')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
   %{-- <asset:stylesheet src="bootstrap-colorpicker"/>--}%
</head>

<body>

<content tag="pageTitle">General Settings</content>

<div id="edit-landingPage" class="content scaffold-edit" role="main">
    <g:hasErrors bean="${landingPageInstance}">
        <ul class="errors" role="alert">
            <g:eachError bean="${landingPageInstance}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </g:hasErrors>

    <g:render template="generalForm"/>

</div>

</body>
</html>
