<%@ page contentType="text/html;charset=UTF-8" %>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="default.application.name" /> - ${institutionInstance.name ?: 'unknown'}</title>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>

    <r:script>

        $(document).ready(function () {

        });

    </r:script>

    <style type="text/css">
    </style>

</head>

<body class="content">

    <cl:headerContent title="${institutionInstance.name}" selectedNavItem="institutions">
        <%
            pageScope.crumbs = [
                [link: createLink(controller: 'institution', action: 'list'), label: message(code: 'default.institutions.label', default: 'Institutions')]
            ]
        %>

        <div>
            <cl:isLoggedIn>
                <cl:ifAdmin>
                    <g:link style="margin-right: 5px; color: white" class="btn btn-warning pull-right" controller="institutionAdmin" action="edit" id="${institutionInstance.id}">Edit</g:link>&nbsp;
                </cl:ifAdmin>
            </cl:isLoggedIn>
        </div>
    </cl:headerContent>

    <div class="row">
        <div class="span4">
            <img src="<cl:institutionBannerUrl id="${institutionInstance.id}"/>" />
        </div>
        <div class="span8">
            <div class="institution-description">
                <markdown:renderHtml>${institutionInstance.description}</markdown:renderHtml>
            </div>

            <small>
                <g:if test="${institutionInstance.contactEmail || institutionInstance.contactName}" >
                    <div class="contactEmail"><strong>Contact: </strong><cl:contactLink email="${institutionInstance.contactEmail}" name="${institutionInstance.contactName}" /></div>
                </g:if>
                <g:if test="${institutionInstance.contactPhone}">
                    <div class="contactPhone"><strong>Phone: </strong>${institutionInstance.contactPhone}</div>
                </g:if>
                <g:if test="${institutionInstance.websiteUrl}">
                    <div class="institutionWebsiteLink"><strong>Website: </strong><a class="external" href="${institutionInstance.websiteUrl}">${institutionInstance.websiteUrl}</a></div>
                </g:if>
                <g:if test="${institutionInstance.collectoryUid}">
                    <g:set var="collectoryUrl" value="http://collections.ala.org.au/public/show/${institutionInstance.collectoryUid}" />
                    <div class="institutionCollectoryLink"><strong>${institutionInstance.acronym} in the ALA Collectory: </strong><a class="external" href="${collectoryUrl}">${collectoryUrl}</a></div>
                </g:if>

            </small>


            <cl:ifInstitutionHasLogo institution="${institutionInstance}">
                <div class="institution-logo">
                    <img src="<cl:institutionLogoUrl id="${institutionInstance.id}" />" height="100px" width="100px" />
                </div>
            </cl:ifInstitutionHasLogo>
        </div>
    </div>

    <div class="row">
        <div class="span12">
            <h3>${institutionInstance.acronym} Expeditions</h3>
            <g:render template="../project/ProjectListDetailsView" model="${[extraParams:[id:institutionInstance.id]]}" />
        </div>
    </div>

</body>
</html>