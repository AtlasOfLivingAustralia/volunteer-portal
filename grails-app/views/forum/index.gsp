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

        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">

            $(document).ready(function() {


                var tabOptions = {
                    selected: ${params.selectedTab ?: 0},
                    show: function (e) {
                        var $tabs = $('#tabControl').tabs();
                        var newIndex = $tabs.tabs('option', 'selected');
                        if (newIndex == 0) {
                            $("#tabRecentTopics").html('<div>Retrieving list of featured and recently modified topics... <img src="${resource(dir:'images', file:'spinner.gif')}"/> </div>');
                            $.ajax("${createLink(controller: 'forum',action:'ajaxRecentTopicsList', params: params)}").done(function(content) {
                                $("#tabRecentTopics").html(content);
                            });
                        } else if (newIndex == 2) {
                            $("#tabProjectForums").html('<div>Retrieving list of project forums... <img src="${resource(dir:'images', file:'spinner.gif')}"/> </div>');
                            $.ajax("${createLink(controller: 'forum',action:'ajaxProjectForumsList', params: params)}").done(function(content) {
                                $("#tabProjectForums").html(content);
                            });
                        } else if (newIndex == 3) {
                            $("#tabWatchedTopics").html('<div>Searching for the topics that you are currently watching... <img src="${resource(dir:'images', file:'spinner.gif')}"/> </div>');
                            $.ajax("${createLink(controller: 'forum',action:'ajaxWatchedTopicsList', params:params)}").done(function(content) {
                                $("#tabWatchedTopics").html(content);
                            });
                        }
                        return 0;
                    },
                    beforeActivate: function (e) {
                    },
                    hide: false

                };

                $("#tabControl").tabs(tabOptions);
                $("#tabControl").css("display", "block");

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
                <small><a href="${createLink(action:'generalDiscussion')}" class="button orange">Browse General Discussion Topics</a></small>
                <br/>
                This section is for comments and queries about the Biodiversity Volunteer Portal in general
            </section>

            <div id="tabControl" style="display:none">
                <ul>
                    <li><a href="#tabRecentTopics">Featured and recent topics</a></li>
                    <li><a href="#tabForumTopics">Find Forum Topics</a></li>
                    <li><a href="#tabProjectForums">Project Forums</a></li>
                    <li><a href="#tabWatchedTopics">Your watched topics</a></li>
                </ul>

                <div id="tabRecentTopics" class="tabContent" style="display:none">
                    <g:include action="ajaxRecentTopicsList" />
                </div>

                <div id="tabForumTopics" class="tabContent" style="display:none">

                        <h3>Find forum topics</h3>
                        <g:form controller="forum" action="searchForums">
                            <g:textField id="search-input" class="filled" placeholder="Search the forums..." name="query"/>
                            <button class="button" type="submit">Search</button>
                        </g:form>

                </div>

                <div id="tabProjectForums" class="tabContent" style="display:none"></div>
                <div id="tabWatchedTopics" class="tabContent" style="display:none"></div>
        </div>
    </body>
</html>
