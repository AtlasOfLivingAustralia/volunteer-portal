<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title><g:message code="default.application.name" /> - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>

        <style type="text/css">

            .buttonBar {
                margin-bottom: 10px;
            }

            .notifyMe {
                margin: 10px;
            }

            #watchUpdateMessage {
                display: none;
                background-color: lightblue;
                color: black;
                padding:5px;
                font-weight: bold;
            }

            .btn.btn-danger {
                color: white;
            }

        </style>

    </head>

    <body>

        <r:require module="url"/>
        <r:script type="text/javascript">

            $(document).ready(function () {

                $("#btnNewProjectTopic").click(function (e) {
                    e.preventDefault();
                    window.location = "${createLink(controller: 'forum', action:'addForumTopic', params:[projectId: projectInstance.id])}";
                });

                $(".deleteTopicLink").click(function (e) {

                    var topicId = $(this).parents("tr[topicId]").attr("topicId");

                    if (topicId) {
                        if (confirm("Are you sure you want to delete this topic?")) {
                            window.location = "${createLink(controller:'forum', action:'deleteProjectTopic')}?topicId=" + topicId;
                        }

                    }
                });

                $('a[data-toggle="tab"]').on('click', function (e) {
                    activateTaskTopics($(this));
                });

                $("th > a").addClass("btn");
                $("th.sorted > a").addClass("active");

                $("#watchProjectCheckbox").change(function(e) {
                    e.preventDefault();
                    var watchThisProject = $(this).is(":checked");
                    $.ajax("${createLink(controller:'forum', action:'ajaxWatchProject', params:[projectId: projectInstance.id])}&watch=" + watchThisProject).done(function(data) {
                        if (data.success) {
                            $("#watchUpdateMessage").css("display", "block").html(data.message);
                        }
                    });
                })

                var url = "${createLink(controller: 'forum',action:'ajaxProjectTaskTopicList', params: [projectId: projectInstance.id])}";

                function displayTaskTopicsSpinner() {
                    $("#tabTaskTopics").html('<div>Searching for task topics in this project... <img src="${resource(dir:'images', file:'spinner.gif')}"/> </div>');
                }

                function activateTaskTopics(jqElem, params) {
                    params = params || {};
                    var tabIndex = jqElem.attr("tabIndex");
                    if (tabIndex) {
                        displayTaskTopicsSpinner();

                        var b = URI(url);
                        for (var property in params) {
                            if (params.hasOwnProperty(property)) {
                                b.addSearch(property, params[property]);
                            }
                        }
                        $.ajax(b.toString()).done(updateTaskTopicsContent);

                    }
                }

                function updateTaskTopicsContent(content) {
                    $("#tabTaskTopics").html(content);
                    $("th > a").addClass("btn btn-small");
                    $("th.sorted > a").addClass("btn btn-small")
                    $("div.topicTable > div.pagination > a").on('click', function(e) {
                        e.preventDefault();
                        ajaxUpdateTaskTopics($(this));
                    });
                }

                function ajaxUpdateTaskTopics(jqElem) {
                    var b = new URI(url);
                    var r = new URI(jqElem.attr('href'));

                    b.search(r.search());

                    $("div.topicTable > div.pagination > a").off('click');
                    displayTaskTopicsSpinner();

                    $.ajax(b.toString()).done(updateTaskTopicsContent);
                }

            <g:if test="params.selectedTab == 1">
                var params = {};
                <g:if test="${params.max || params.offset}">
                    var max = parseInt("${params.max.encodeAsJavaScript()}");
                    var offset = parseInt("${params.offset.encodeAsJavaScript()}");
                    if (!isNaN(max)) params.max = max;
                    if (!isNaN(offset)) params.offset = offset;
                </g:if>
                activateTaskTopics($('#tabTasks'), params);
            </g:if>

            });

        </r:script>

        <cl:headerContent title="Expedition Forum - ${projectInstance.featuredLabel}" selectedNavItem="forum">
            <%
                pageScope.crumbs = [
                    [link:createLink(controller:'project', action:'index', id:projectInstance.id),label: projectInstance.featuredLabel]
                ]
            %>
        </cl:headerContent>

        <div id="content" class="row">
            <div class="span12">
                <div class="projectSummary">
                    <table style="margin-bottom: 0px; width: 100%">
                        <tr>
                            <td style="width:210px"><img src="${projectInstance.featuredImage}" alt="" title="${projectInstance.name}" width="200" height="124" /></td>
                            <td style="text-align: left">
                                <h2><a href="${createLink(controller:'project', action:'index', id:projectInstance.id)}">${projectInstance.featuredLabel}</a></h2>
                                <h3>${projectInstance.featuredOwner}</h3>
                                ${projectInstance.description}
                            </td>
                            <td style="text-align: right"></td>
                        </tr>
                        <g:if test="${projectInstance.featuredImageCopyright}">
                            <tr>
                                <td><span class="copyright-label">${projectInstance.featuredImageCopyright}</span></td>
                            </tr>
                        </g:if>
                    </table>
                    <div class="notifyMe">
                        <g:checkBox name="watchProject" id="watchProjectCheckbox" checked="${isWatching}" />&nbsp;Email me when messages are posted to this project
                        <span id="watchUpdateMessage"></span>
                    </div>
                </div>

                <div id="projectForumTabs" class="tabbable">
                    <ul class="nav nav-tabs">
                        <li class="${!params.selectedTab ? 'active' : ''}"><a id="tabProject" href="#tabProjectTopics" class="forum-tab-title" data-toggle="tab" tabIndex="0">Expedition Topics</a></li>
                        <li class="${params.selectedTab == '1' ? 'active' : ''}"><a id="tabTasks" href="#tabTaskTopics" class="forum-tab-title" data-toggle="tab" tabIndex="1">Task Topics</a></li>
                    </ul>
                    <div class="tab-content">
                        <div id="tabProjectTopics" class="tabContent tab-pane ${!params.selectedTab ? 'active' : ''}">
                            <div class="buttonBar">
                                <button id="btnNewProjectTopic" class="btn">
                                    Create a new topic&nbsp;<img src="${resource(dir: 'images', file: 'newTopic.png')}"/>
                                </button>
                            </div>

                            <vpf:topicTable topics="${topics.topics}" totalCount="${topics.totalCount}" paginateAction="projectForum"/>

                        </div>
                        <div id="tabTaskTopics" class="tab-pane ${params.selectedTab == '1' ? 'active' : ''}">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
