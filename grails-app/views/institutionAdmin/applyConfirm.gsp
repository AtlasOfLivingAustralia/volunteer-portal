<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}"/>
    <g:set var="entry" value="APPLY"/>
    <title><g:message code="institution.apply.confirm.title" args="[entityName]"/></title>
    <asset:stylesheet src="bootstrap-colorpicker"/>
</head>

<pre><%=params%></pre>

<body class="admin">
<cl:headerContent title="${message(code: 'institution.apply.confirm.title', args: [entityName])}" selectedNavItem="bvpadmin">

</cl:headerContent>
<div id="create-institution" class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <p>
                <b>Institution Name:</b> ${institutionInstance.name} <br />
                <b>Contact: </b>
                    <g:if test="${institutionInstance.contactEmail}">
                        <a href="mailto:${institutionInstance.contactEmail}">${institutionInstance.contactName}</a>
                    </g:if>
                    <g:elseif test="${institutionInstance.contactName}">
                        ${institutionInstance.contactName}
                    </g:elseif>
                    <g:if test="${institutionInstance.contactPhone}">(Ph: ${institutionInstance.contactPhone})</g:if><br/>
                <b>Website:</b> <a href="${(institutionInstance.websiteUrl?.startsWith("http")) ? "" : "http://"}${institutionInstance.websiteUrl}" target="_blank">${(institutionInstance.websiteUrl?.startsWith("http")) ? institutionInstance.websiteUrl?.substring(7) : institutionInstance.websiteUrl}</a>
            </p>
            <p style="margin-top: 2em;">
                <b>Institution Description:</b> <br />
                <%=institutionInstance.description%></p>
            <p style="margin-top: 2em;">
                Thank you for submitting your application. The DigiVol Admin team will review and respond if and when your application
                has been reviewed.
            </p>
        </div>
    </div>


</div>
</body>
</html>
