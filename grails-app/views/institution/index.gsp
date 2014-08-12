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

<body>

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

            <div class="institution-logo">
                <img src="<cl:institutionLogoUrl id="${institutionInstance.id}" />" height="100px" width="100px" />
            </div>
        </div>
    </div>

    <div class="row">
        <div class="span12">
            <h3>${institutionInstance.acronym} Expeditions</h3>
            <g:render template="../project/ProjectListDetailsView" />
        </div>
    </div>

</body>
</html>