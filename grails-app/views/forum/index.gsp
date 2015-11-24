<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><cl:pageTitle title="Forum"/></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    %{--<link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>--}%

    <style type="text/css">

    /*.forumSection {*/
        /*border: 1px solid #a9a9a9;*/
        /*margin-top: 5px;*/
        /*margin-bottom: 5px;*/
        /*padding: 10px;*/
    /*}*/

    </style>

</head>

<body>

<r:script type="text/javascript">

            function renderTab(tabIndex, q, offset, max, sort, order) {
                // var $tabs = $('#tabControl').tabs();
                var selector = "";
                var baseUrl = "";
                if (tabIndex == 0 || !tabIndex) {
                    selector = "#tabRecentTopics";
                    baseUrl = "${createLink(action: 'ajaxRecentTopicsList')}";
                } else if (tabIndex == 1) {
                    selector = "#tabGeneralTopics";
                    baseUrl = "${createLink(action: 'ajaxGeneralTopicsList')}";
                } else if (tabIndex == 2) {
                    selector = "#tabProjectForums";
                    baseUrl = "${createLink(action: 'ajaxProjectForumsList')}";
                } else if (tabIndex == 3) {
                    selector = "#tabWatchedTopics";
                    baseUrl = "${createLink(action: 'ajaxWatchedTopicsList')}";
                }

                if (baseUrl && selector) {
                    $(selector).html('<div>Retrieving list of topics... <img src="${resource(dir: 'images', file: 'spinner.gif')}"/></div>');
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
                        $("th > a").addClass("btn")
                        $("th.sorted > a").addClass("active")
                    });
                }

            }

            $(document).ready(function() {

                $('a[data-toggle="tab"]').on('click', function (e) {
                    var tabIndex = $(this).attr("tabIndex");
                    if (tabIndex) {
                        renderTab(tabIndex);
                    }
                });

                <g:applyCodec encodeAs="none">
                renderTab(${params.selectedTab ?: 0}, ${params.q ? '"' + params.q + '"' : 'null'}, ${params.offset ?: "null"}, ${params.max ?: "null"}, ${raw(params.sort ? '"' + params.sort + '"' : "null")}, ${params.order ? '"' + params.order + '"' : "null"});
                </g:applyCodec>

            });

</r:script>

<cl:headerContent title="${message(code: 'default.forum.label', default: 'DigiVol Forum')}" selectedNavItem="forum">
</cl:headerContent>

<section id="main-content">
    <div class="container">
        <div class="row" id="content">
            <div class="col-sm-12">

                <g:form controller="forum" action="searchForums">
                    <div class="card-filter">
                        <div class="custom-search-input body">
                            <div class="input-group">
                                <g:textField id="search-input" class="form-control input-lg"
                                             placeholder="Search forums" name="query"/>
                                <span class="input-group-btn">
                                    <button class="btn btn-info btn-lg" type="submit"><i class="glyphicon glyphicon-search"></i></button>
                                </span>
                            </div>
                        </div>
                    </div>
                </g:form>
                <h2 class="heading">Find forum topics</h2>

                <div id="tabControl" class="tabbable">
                    <ul class="nav nav-tabs">
                        <li class="${!params.selectedTab || params.selectedTab == '0' ? 'active' : ''}"><a
                                href="#tabRecentTopics" class="forum-tab-title" data-toggle="tab"
                                tabIndex="0">Featured and recent topics</a></li>
                        <li class="${params.selectedTab == '1' ? 'active' : ''}"><a href="#tabGeneralTopics"
                                                                                    class="forum-tab-title"
                                                                                    data-toggle="tab"
                                                                                    tabIndex="1">Browse General Discussion Topics</a>
                        </li>
                        <li class="${params.selectedTab == '2' ? 'active' : ''}"><a href="#tabProjectForums"
                                                                                    class="forum-tab-title"
                                                                                    data-toggle="tab"
                                                                                    tabIndex="2">Expedition Forums</a>
                        </li>
                        <li class="${params.selectedTab == '3' ? 'active' : ''}"><a href="#tabWatchedTopics"
                                                                                    class="forum-tab-title"
                                                                                    data-toggle="tab"
                                                                                    tabIndex="3">Your watched topics</a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <div class="tab-content-bg">
        <div class="container">
            <div class="row">
                <div class="col-sm-12">
                    <div class="tab-content">
                        <div id="tabRecentTopics"
                             class="tab-pane ${!params.selectedTab || params.selectedTab == '0' ? 'active' : ''}"></div>
                        <div id="tabGeneralTopics" class="tab-pane ${params.selectedTab == '1' ? 'active' : ''}"></div>
                        <div id="tabProjectForums" class="tab-pane ${params.selectedTab == '2' ? 'active' : ''}"></div>
                        <div id="tabWatchedTopics" class="tab-pane ${params.selectedTab == '3' ? 'active' : ''}"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
</body>
</html>
