<%@ page contentType="text/html;charset=UTF-8" %>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="default.application.name" /> - ${institutionInstance.name ?: 'unknown'}</title>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>

    <r:script>

        $(document).ready(function () {

            $.ajax("${createLink(controller: 'leaderBoard', action:'leaderBoardFragment', params:[institutionId: institutionInstance.id])}").done(function (content) {
                $("#leaderBoardSection").html(content);
            });

        });

    </r:script>

    <style type="text/css">

        <cl:ifInstitutionHasBanner institution="${institutionInstance}">
        #page-header {
            background-image: url(<cl:institutionBannerUrl id="${institutionInstance.id}" />);
        }
        </cl:ifInstitutionHasBanner>

        .institution-image {
            margin-bottom: 10px;
            text-align: center;
        }

        [inactive=true] {
            background-color: #d3d3d3;
            opacity: 0.5;
        }

        tr .adminLink {
            color: #d3d3d3;
        }

        tr[inactive=true] .adminLink {
            color: black;
            opacity: 1;
        }

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
                    <g:link style="margin-right: 5px; color: white" class="btn btn-warning pull-right" controller="institutionAdmin" action="edit" id="${institutionInstance.id}"><i class="icon-cog icon-white"></i>&nbsp;Settings</g:link>&nbsp;
                </cl:ifAdmin>
            </cl:isLoggedIn>
        </div>
    </cl:headerContent>

    <div class="row">
        <div class="span3">
            <div class="institution-image">
                <img src="<cl:institutionImageUrl id="${institutionInstance.id}"/>" />
            </div>
            <div class="well well-small">
                <small>
                    <g:if test="${institutionInstance.contactEmail || institutionInstance.contactName}" >
                        <div class="contactEmail"><strong>Email:</strong><cl:contactLink email="${institutionInstance.contactEmail}" name="${institutionInstance.contactName}" /></div>
                    </g:if>
                    <g:if test="${institutionInstance.contactPhone}">
                        <div class="contactPhone"><strong>Phone:</strong>${institutionInstance.contactPhone}</div>
                    </g:if>
                    <div>
                        <g:if test="${institutionInstance.websiteUrl}">
                            <span class="institutionWebsiteLink"><strong><a class="external" href="${institutionInstance.websiteUrl}">Website</a></strong></span>
                        </g:if>
                        <g:if test="${institutionInstance.collectoryUid}">
                            <g:set var="collectoryUrl" value="http://collections.ala.org.au/public/show/${institutionInstance.collectoryUid}" />
                            <span class="institutionCollectoryLink"><strong><a class="external" href="${collectoryUrl}">Collectory page</a></strong></span>
                        </g:if>
                    </div>
                </small>
            </div>

        </div>
        <div class="span6">
            <div class="institution-description">
                <cl:ifInstitutionHasLogo institution="${institutionInstance}">
                    <img align="right" src="<cl:institutionLogoUrl id="${institutionInstance.id}" />" height="100" width="100"  style="max-height: 50px; max-width: 50px"/>
                </cl:ifInstitutionHasLogo>
                <markdown:renderHtml>${institutionInstance.description}</markdown:renderHtml>
            </div>
        </div>
        <div class="span3">
            <section id="leaderBoardSection">

            </section>
        </div>
    </div>

    <div class="row">
        <div class="span8">
            <h2>${institutionInstance.acronym} Expeditions</h2>
        </div>
        <div class="span4">
            <div class="btn-group pull-right">
                <a href="${createLink(action:'index', id: institutionInstance.id)}" class="btn btn-small ${params.mode != 'thumbs' ? 'active' : ''}" title="View expedition list">
                    <i class="icon-th-list"></i>
                </a>
                <a href="${createLink(action:'index', id: institutionInstance.id, params:[mode:'thumbs'])}" class="btn btn-small ${params.mode == 'thumbs' ? 'active' : ''}" title="View expedition thumbnails">
                    <i class="icon-th"></i>
                </a>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="span12">
            <g:if test="${params.mode == 'thumbs'}">
                <g:render template="../project/projectListThumbnailView" model="${[extraParams:[id:institutionInstance.id]]}" />
            </g:if>
            <g:else>
                <g:render template="../project/ProjectListDetailsView" model="${[extraParams:[id:institutionInstance.id]]}" />
            </g:else>


        </div>
    </div>

</body>
</html>