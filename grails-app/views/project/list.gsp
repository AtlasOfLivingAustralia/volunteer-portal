<%@ page import="au.org.ala.volunteer.ProjectActiveFilterType; au.org.ala.volunteer.ProjectStatusFilterType; au.org.ala.volunteer.Project" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>

        <style type="text/css">
        </style>

        <r:script>

            $(document).ready(function() {

                $("#searchbox").keydown(function(e) {
                    if (e.keyCode ==13) {
                        doSearch();
                    }
                });

                $("#btnSearch").click(function(e) {
                    e.preventDefault();
                    doSearch();
                });

                $("a.fieldHelp").qtip({
                    tip: true,
                    position: {
                        corner: {
                            target: 'topMiddle',
                            tooltip: 'bottomLeft'
                        }
                    },
                    style: {
                        width: 400,
                        padding: 8,
                        background: 'white', //'#f0f0f0',
                        color: 'black',
                        textAlign: 'left',
                        border: {
                            width: 4,
                            radius: 5,
                            color: '#E66542'// '#E66542' '#DD3102'
                        },
                        tip: 'bottomLeft',
                        name: 'light' // Inherit the rest of the attributes from the preset light style
                    }
                }).bind('click', function(e) {
                    e.preventDefault();
                    return false;
                });

                $("#searchbox").focus();

            });

            function doSearch() {
                var q = $("#searchbox").val();
                var url = "${createLink(controller: 'project',action:'list')}?mode=${params.mode}&q=" + encodeURIComponent(q);
                window.location = url;
            }

        </r:script>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.projectlist.label', default: "Volunteer for a virtual expedition")}" selectedNavItem="expeditions"/>

        <div id="content">
            <div class="row">
                <div class="span6">
                    <h2>${numberOfUncompletedProjects} expeditions need your help. Join now!</h2>
                </div>
                <div class="span6">

                    <g:set var="statusFilterMode" value="${ params.statusFilter ?: ProjectStatusFilterType.showAll}" />
                    <g:set var="activeFilterMode" value="${ params.activeFilter ?: ProjectActiveFilterType.showAll}" />

                    <g:set var="urlParams" value="${[sort: params.sort ?: "", order: params.order ?: "", offset: 0, q: params.q ?: "", mode: params.mode ?: "", statusFilter:statusFilterMode, activeFilter: activeFilterMode]}" />

                    <div class="btn-group pull-right">
                        <a href="${createLink(action:'list')}" class="btn btn-small ${params.mode != 'thumbs' ? 'active' : ''}" title="View expedition list">
                            <i class="icon-th-list"></i>
                        </a>
                        <a href="${createLink(action:'list', params:[mode:'thumbs'])}" class="btn btn-small ${params.mode == 'thumbs' ? 'active' : ''}" title="View expedition thumbnails">
                            <i class="icon-th"></i>
                        </a>
                    </div>

                    <div class="btn-group pull-right" style="padding-right: 10px">
                        <g:each in="${ProjectStatusFilterType.values()}" var="mode">
                            <g:set var="href" value="?${(urlParams + [statusFilter: mode]).collect { it }.join('&')}" />
                            <a href="${href}" class="btn btn-small ${statusFilterMode == mode?.toString() ? "active" : ""}">${mode.description}</a>
                        </g:each>
                    </div>

                    <cl:ifAdmin>
                        <div class="btn-group pull-right" style="padding-right: 10px">
                            <g:each in="${ProjectActiveFilterType.values()}" var="mode">
                                <g:set var="href" value="?${(urlParams + [activeFilter: mode]).collect { it }.join('&')}" />
                                <a href="${href}" class="btn btn-warning btn-small ${activeFilterMode == mode?.toString() ? "active" : ""}">${mode.description}</a>
                            </g:each>
                        </div>
                    </cl:ifAdmin>

                </div>
            </div>

            <g:set var="model" value="${[extraParams:[statusFilter: statusFilterMode?.toString(), activeFilter: activeFilterMode?.toString()]]}" />

            <g:if test="${params.mode == 'thumbs'}">
                <g:render template="projectListThumbnailView" model="${model}"/>
            </g:if>
            <g:else>
                <g:render template="ProjectListDetailsView" model="${model}" />
            </g:else>
        </div>

    </body>
</html>
