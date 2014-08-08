
<%@ page import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
	<head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}" />
        <title><g:message code="default.create.label" args="[entityName]" /></title>
	</head>
	<body>
        <cl:headerContent title="${message(code:'default.show.label', args:[entityName])}">
            <%
                pageScope.crumbs = [
                        [link:createLink(controller:'admin'),label:message(code:'default.admin.label', default:'Admin')],
                        [link:createLink(controller:'institution'), label:message(code:'default.institutions.label', default:'Manage Institutions')]
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
		<div id="show-institution" class="content scaffold-show" role="main">
            <ol class="property-list institution">

                <g:if test="${institutionInstance?.name}">
                    <li class="fieldcontain">
                        <span id="name-label" class="property-label"><g:message code="institution.name.label" default="Name" /></span>

                        <span class="property-value" aria-labelledby="name-label"><g:fieldValue bean="${institutionInstance}" field="name"/></span>

                    </li>
                </g:if>

                <g:if test="${institutionInstance?.acronym}">
                    <li class="fieldcontain">
                        <span id="acronym-label" class="property-label"><g:message code="institution.acronym.label" default="Acronym" /></span>

                        <span class="property-value" aria-labelledby="acronym-label"><g:fieldValue bean="${institutionInstance}" field="acronym"/></span>

                    </li>
                </g:if>

                <g:if test="${institutionInstance?.description}">
                    <li class="fieldcontain">
                        <span id="description-label" class="property-label"><g:message code="institution.description.label" default="Description" /></span>

                        <span class="property-value" aria-labelledby="description-label"><markdown:renderHtml text="${institutionInstance.description}" /></span>

                    </li>
                </g:if>

                <g:if test="${institutionInstance?.contactName}">
                    <li class="fieldcontain">
                        <span id="contactName-label" class="property-label"><g:message code="institution.contactName.label" default="Contact Name" /></span>

                        <span class="property-value" aria-labelledby="contactName-label"><g:fieldValue bean="${institutionInstance}" field="contactName"/></span>

                    </li>
                </g:if>

                <g:if test="${institutionInstance?.contactEmail}">
                    <li class="fieldcontain">
                        <span id="contactEmail-label" class="property-label"><g:message code="institution.contactEmail.label" default="Contact Email" /></span>

                        <span class="property-value" aria-labelledby="contactEmail-label"><g:fieldValue bean="${institutionInstance}" field="contactEmail"/></span>

                    </li>
                </g:if>

                <g:if test="${institutionInstance?.contactPhone}">
                    <li class="fieldcontain">
                        <span id="contactPhone-label" class="property-label"><g:message code="institution.contactPhone.label" default="Contact Phone" /></span>

                        <span class="property-value" aria-labelledby="contactPhone-label"><g:fieldValue bean="${institutionInstance}" field="contactPhone"/></span>

                    </li>
                </g:if>

                <g:if test="${institutionInstance?.websiteUrl}">
                    <li class="fieldcontain">
                        <span id="websiteUrl-label" class="property-label"><g:message code="institution.websiteUrl.label" default="Website URL" /></span>
                        <span class="property-value" aria-labelledby="websiteUrl-label"><g:fieldValue bean="${institutionInstance}" field="websiteUrl"/></span>

                    </li>
                </g:if>


                <g:if test="${institutionInstance?.collectoryUid}">
                    <li class="fieldcontain">
                        <span id="collectoryId-label" class="property-label"><g:message code="institution.collectoryId.label" default="Collectory Uid" /></span>

                        <span class="property-value" aria-labelledby="collectoryId-label"><g:fieldValue bean="${institutionInstance}" field="collectoryUid"/></span>

                    </li>
                </g:if>

                <g:if test="${institutionInstance?.dateCreated}">
                    <li class="fieldcontain">
                        <span id="dateCreated-label" class="property-label"><g:message code="institution.dateCreated.label" default="Date Created" /></span>

                        <span class="property-value" aria-labelledby="dateCreated-label"><g:formatDate date="${institutionInstance?.dateCreated}" /></span>

                    </li>
                </g:if>

                <g:if test="${institutionInstance?.lastUpdated}">
                    <li class="fieldcontain">
                        <span id="lastUpdated-label" class="property-label"><g:message code="institution.lastUpdated.label" default="Last Updated" /></span>

                        <span class="property-value" aria-labelledby="lastUpdated-label"><g:formatDate date="${institutionInstance?.lastUpdated}" /></span>

                    </li>
                </g:if>



            </ol>
			<g:form url="[resource:institutionInstance, action:'delete']" method="DELETE">
				<fieldset class="buttons">
					<g:link class="edit" action="edit" resource="${institutionInstance}"><g:message code="default.button.edit.label" default="Edit" /></g:link>
					<g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />
				</fieldset>
			</g:form>
		</div>
	</body>
</html>
