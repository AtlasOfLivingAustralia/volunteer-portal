<%@ page import="org.springframework.validation.FieldError" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}"/>
    <g:set var="entry" value="APPLY"/>
    <title><cl:pageTitle title="${g.message(code: "institution.apply.title", args: [entityName], default:"Apply for an Institution")}" /></title>
    <asset:stylesheet src="bootstrap-colorpicker"/>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'institution.apply.title', args: [entityName])}" selectedNavItem="bvpadmin">

</cl:headerContent>
<div id="create-institution" class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <p>You can apply for an Institution within DigiVol! An Insitution can create Expeditions that utilise the
            volunteer power of Citizen Science to transcribe your digital assets for your research.</p>
            <p>Complete the form below and it will be reviewed by the DigiVol admin team. You will be notified when
            it's approved.</p>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${institutionInstance}">
                        <ul class="errors" role="alert">
                            <g:eachError bean="${institutionInstance}" var="error">
                                <li <g:if test="${error in FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                        error="${error}"/></li>
                            </g:eachError>
                        </ul>
                    </g:hasErrors>

                    <g:form action="save" class="form-horizontal">
                        <input type="hidden" name="isApproved" value="false" />
                            <g:render template="form"/>
                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:submitButton name="create" class="save btn btn-primary"
                                                value="${message(code: 'institution.apply.submit.label', default: 'Submit')}"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
