<%@ page import="au.org.ala.volunteer.Project" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>
        <style type="text/css">

        .ui-widget-header {
            border: 1px solid #3A5C83;
            background: white url(${resource(dir:'images/vp',file:'progress_1x100b.png')}) 50% 50% repeat-x;
        }

        .ui-widget-content {
            border: 1px solid #3A5C83;
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
                <div class="span8">
                    <h2>${numberOfUncompletedProjects} expeditions need your help. Join now!</h2>
                </div>
                <div class="span4">
                    <div class="btn-group pull-right">
                        <a href="${createLink(action:'list')}" class="btn btn-small ${params.mode != 'thumbs' ? 'active' : ''}" title="View expedition list">
                            <i class="icon-th-list"></i>
                        </a>
                        <a href="${createLink(action:'list', params:[mode:'thumbs'])}" class="btn btn-small ${params.mode == 'thumbs' ? 'active' : ''}" title="View expedition thumbnails">
                            <i class="icon-th"></i>
                        </a>
                    </div>
                </div>
            </div>

            <g:if test="${params.mode == 'thumbs'}">
                <g:render template="projectListThumbnailView" />
            </g:if>
            <g:else>
                <g:render template="ProjectListDetailsView" />
            </g:else>
        </div>

    </body>
</html>
