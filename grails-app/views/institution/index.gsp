
<%@ page import="au.org.ala.volunteer.ProjectActiveFilterType; au.org.ala.volunteer.ProjectStatusFilterType" contentType="text/html;charset=UTF-8" %>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="default.application.name" /> - ${institutionInstance.name ?: 'unknown'}</title>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>

    <r:style>
        .pt-div {
            padding: 0 1em 0 0;
        }

        .pt-div dl {
            margin-left: 0.5em;
            margin-top: 0;
            margin-bottom: 0;
        }

        .pt-div dt {
            font-weight: normal;
        }

        .pt-div dt, .pt-div dd {
            display: inline;
            margin: 0;
        }

        .pt-div dt:after {
            content: ':';
        }

        .pt-div dd:after {
	        content: '\A';
	        white-space: pre;
        }
    </r:style>
    <r:script>

        $(document).ready(function () {

            $.ajax("${createLink(controller: 'leaderBoard', action:'leaderBoardFragment', params:[institutionId: institutionInstance.id])}").done(function (content) {
                $("#leaderBoardSection").html(content);
            });

            $("#searchbox").keydown(function(e) {
                if (e.keyCode ==13) {
                    doSearch();
                }
            });

            $("#btnSearch").click(function(e) {
                e.preventDefault();
                doSearch();
            });

            $("#searchbox").focus();
        });

        function doSearch() {
            var q = $("#searchbox").val();
            var url = "${createLink(controller: 'institution',action:'index', id: institutionInstance.id)}?mode=${params.mode}&q=" + encodeURIComponent(q) + "&statusMode=${statusFilterMode}&activeMode=${activeFilterMode}";
            window.location = url;
        }

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

        .image-caption {
            font-style: italic;
            font-size: 0.8em;
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
                <g:if test="${institutionInstance.imageCaption}">
                    <div class="image-caption">${institutionInstance.imageCaption}</div>
                </g:if>
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
            <div class="insitution-statistics">
                <table class="table table-condensed">
                    <tr>
                        <td><g:message code="institution.transcribers.label" default="Volunteers"/></td>
                        <td><strong>${transcriberCount}</strong></td>
                    </tr>
                    <tr>
                        <td>
                            <g:message code="institution.tasks.label" default="Tasks"/>
                        </td>
                        <td>
                            <strong>${taskCounts?.taskCount}</strong> in total (<strong>${taskCounts.percentTranscribed}%</strong> transcribed, <strong>${taskCounts.percentValidated}%</strong> validated)
                        </td>
                    </tr>
                    <tr>
                        <td>Expeditions</td>
                        <td>
                            <g:each in="${projectTypes}" var="pt">
                                <div class="pt-div" style="display:inline-block;">
                                    <span><strong>${pt.key}</strong> ${pt.value.total}</span>
                                    <dl>
                                        <dt>Underway</dt>
                                        <dd>${pt.value.started}</dd>
                                        <dt>Complete</dt>
                                        <dd>${pt.value.complete}</dd>
                                    </dl>
                                </div>
                            </g:each>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <div class="span3">
            <section id="leaderBoardSection">
            </section>
        </div>
    </div>

    <div class="row">
        <div class="span4">
            <h2 style="display:inline-block">${institutionInstance.acronym} Expeditions</h2>
        </div>
        <div class="span8">

            <g:set var="urlParams" value="${[sort: params.sort ?: "", order: params.order ?: "", offset: 0, q: params.q ?: "", mode: params.mode ?: "", statusFilter: statusFilterMode?.toString(), activeFilter: activeFilterMode?.toString()]}" />

            <div class="btn-group pull-right">
                <a href="${createLink(action:'index', id: institutionInstance.id, params: urlParams + [mode: 'list'] )}" class="btn btn-small ${params.mode != 'thumbs' ? 'active' : ''}" title="View expedition list">
                    <i class="icon-th-list"></i>
                </a>
                <a href="${createLink(action:'index', id: institutionInstance.id, params: urlParams + [mode:'thumbs'])}" class="btn btn-small ${params.mode == 'thumbs' ? 'active' : ''}" title="View expedition thumbnails">
                    <i class="icon-th"></i>
                </a>
            </div>

            <div class="btn-group pull-right" style="padding-right: 10px">
                <g:each in="${ProjectStatusFilterType.values()}" var="mode">
                    <g:set var="href" value="?${(urlParams + [statusFilter: mode]).collect { it }.join('&')}" />
                    <a href="${href}" class="btn btn-small ${statusFilterMode == mode ? "active" : ""}">${mode.description}</a>
                </g:each>
            </div>

            <cl:ifInstitutionAdmin institution="${institutionInstance}">
            <div class="btn-group pull-right" style="padding-right: 10px">
                <g:each in="${ProjectActiveFilterType.values()}" var="mode">
                    <g:set var="href" value="?${(urlParams + [activeFilter: mode]).collect { it }.join('&')}" />
                    %{--<g:set var="href" value="?sort=${params.sort ?: ""}&order=${params.order ?: ""}&offset=0&q=${params.q ?: ""}&mode=${params.mode ?: ""}&activeFilter=${mode.toString()}&statusFilter=${statusFilterMode?.toString()}" />--}%
                    <a href="${href}" class="btn btn-warning btn-small ${activeFilterMode == mode ? "active" : ""}">${mode.description}</a>
                </g:each>
            </div>
            </cl:ifInstitutionAdmin>
        </div>
    </div>

    <div class="row">
        <div class="span12">
            <g:set var="model" value="${[extraParams:[id:institutionInstance.id, statusFilter: statusFilterMode?.toString(), activeFilter: activeFilterMode?.toString()]]}" />

            <g:if test="${params.mode == 'thumbs'}">
                <g:render template="../project/projectListThumbnailView" model="${model}" />
            </g:if>
            <g:else>
                <g:render template="../project/ProjectListDetailsView" model="${model}" />
            </g:else>
        </div>
    </div>

</body>
</html>