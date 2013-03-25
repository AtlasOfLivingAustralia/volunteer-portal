<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>
        <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
        <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>

        <style type="text/css">

            .forumSection {
                border: 1px solid #a9a9a9;
                margin-top: 5px;
                margin-bottom: 5px;
                padding: 10px;
            }

            #search-input {
                width: 200px;
                height: 27px;
                position: relative;
                outline: none;
                font: normal 1.2em/27px Arial, Helvetica, sans-serif;
                padding: 0 6px;
                margin: 0 7px 6px 0!important;
                border: 1px #a5acb2 solid;
                color: #000;
            }

            .ui-widget {
                font-family: inherit !important;
                font-size: inherit !important;
            }

            .ui-widget-content, .ui-state-active, .ui-tabs-anchor {
                background-color: inherit !important;
            }

            .ui-widget-content .ui-state-active {
                background-color: #FFFEF7 !important;
            }

            .ui-tabs, .ui-tabs-panel, .ui-tabs-nav {
                background-color: #FFFEF7 !important;
            }

            h3 {
                background-color: #FFFEF7 !important;
            }

            [inactive=true] {
                background-color: #d3d3d3;
                opacity: 0.5;
            }

            tr[inactive=true] h3 {
                background-color: #d3d3d3 !important;
            }


            tr[inactive=true] .adminLink {
                color: black;
                opacity: 1;
            }

        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">

            function renderTab(tabIndex, q, offset, max, sort, order) {
                var $tabs = $('#tabControl').tabs();
                var selector = ""
                var baseUrl = ""
                if (tabIndex == 0) {
                    selector = "#tabRecentTopics";
                    baseUrl = "${createLink(action:'ajaxRecentTopicsList')}";
                } else if (tabIndex == 1) {
                    selector = "#tabGeneralTopics";
                    baseUrl = "${createLink(action:'ajaxGeneralTopicsList')}";
                } else if (tabIndex == 2) {
                    selector = "#tabProjectForums";
                    baseUrl = "${createLink(action:'ajaxProjectForumsList')}";
                } else if (tabIndex == 3) {
                    selector = "#tabWatchedTopics";
                    baseUrl = "${createLink(action:'ajaxWatchedTopicsList')}";
                }

                if (baseUrl && selector) {
                    $(selector).html('<div>Retrieving list of topics... <img src="${resource(dir:'images', file:'spinner.gif')}"/> </div>');
                    baseUrl += "?selectedTab=" + tabIndex;
                    if (q) {
                        baseUrl += "&q=" + q;
                    }
                    if (offset) {
                        baseUrl += "&offset=" + offset;
                    }
                    if (max) {
                        baseUrl += "&max=" + max;
                    }
                    if (sort) {
                        baseUrl += "&sort=" + sort;
                    }
                    if (order) {
                        baseUrl += "&order=" + order;
                    }

                    $.ajax(baseUrl).done(function(content) {
                        $(selector).html(content);
                        $("th > a").addClass("button")
                        $("th.sorted > a").addClass("current")
                    });
                }

            }

            $(document).ready(function() {
                var tabOptions = {
                    selected: ${params.selectedTab ?: 0},
                    activate: function (e, ui) {
                        renderTab(ui.newTab.index());
                    },
                    hide: false

                };
                $("#tabControl").tabs(tabOptions);
                $("#tabControl").css("display", "block");
                renderTab(${params.selectedTab ?: 0}, ${params.q ? '"' + params.q + '"': 'null'}, ${params.offset ?: "null"}, ${params.max ?: "null"}, ${params.sort ? '"' + params.sort + '"': "null"}, ${params.order ? '"' + params.order + '"' : "null"});
            });

        </script>

        <cl:navbar selected="forum"/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li class="last"><g:message code="default.forum.label" default="Forum"/></li>
                    </ol>
                </nav>

                <h1><g:message code="default.forum.label" default="Biodiversity Volunteer Portal Forum"/></h1>
            </div>
        </header>

        <div class="inner">

            <section class="forumSection" id="generalDiscussion">
                <h3>Find forum topics</h3>
                <g:form controller="forum" action="searchForums">
                    <g:textField id="search-input" class="filled" placeholder="Search the forums..." name="query"/>
                    <button class="button orange" style="font-size:1.3em" type="submit">Search</button>
                </g:form>
            </section>

            <div id="tabControl" style="display:none">
                <ul>
                    <li><a href="#tabRecentTopics" class="forum-tab-title">Featured and recent topics</a></li>
                    <li><a href="#tabGeneralTopics" class="forum-tab-title">Browse General Discussion Topics</a></li>
                    <li><a href="#tabProjectForums" class="forum-tab-title">Expedition Forums</a></li>
                    <li><a href="#tabWatchedTopics" class="forum-tab-title">Your watched topics</a></li>
                </ul>

                <div id="tabRecentTopics" class="tabContent" style="display:none"></div>
                <div id="tabGeneralTopics" class="tabContent" style="display:none"></div>
                <div id="tabProjectForums" class="tabContent" style="display:none"></div>
                <div id="tabWatchedTopics" class="tabContent" style="display:none"></div>
            </div>
        </div>
    </body>
</html>
