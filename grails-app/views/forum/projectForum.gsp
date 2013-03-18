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

            .buttonBar {
                margin-bottom: 10px;
            }

        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">

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

                var tabOptions = {
                    selected: ${params.selectedTab ?: 0},
                    show: function (e) {
                        var $tabs = $('#projectForumTabs').tabs();
                        var newIndex = $tabs.tabs('option', 'selected');
                        if (newIndex != ${params.selectedTab ?: 0}) {
                            $("#tabTaskTopics").html('<div>Searching for task topics in this project... <img src="${resource(dir:'images', file:'spinner.gif')}"/> </div>');
                            $.ajax("${createLink(controller: 'forum',action:'ajaxProjectTaskTopicList', params: [projectId: projectInstance.id])}").done(function(content) {
                                $("#tabTaskTopics").html(content);
                                $("th > a").addClass("button")
                                $("th.sorted > a").addClass("current")
                            });
                        }
                    },
                    beforeActivate: function (e) {
                    }
                };

                $("#projectForumTabs").tabs(tabOptions);
                $("#projectForumTabs").css("display", "block");

                $("th > a").addClass("button")
                $("th.sorted > a").addClass("current")

            });

        </script>

        <cl:navbar selected=""/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a href="${createLink(controller: 'project', action: 'index', id: projectInstance.id)}">${projectInstance.featuredLabel}</a>
                        </li>
                        <li class="last"><g:message code="default.projectforum.label" default="Project Forum"/></li>
                    </ol>
                </nav>

                <h1>Project Forum - ${projectInstance.featuredLabel}</h1>
            </div>
        </header>

        <div>
            <div class="inner">
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
                </div>
                <div id="projectForumTabs" style="display:none">
                    <ul>
                        <li><a href="#tabProjectTopics">Project Topics</a></li>
                        <li><a href="#tabTaskTopics">Task Topics</a></li>
                    </ul>
                    <div id="tabProjectTopics" class="tabContent" style="display:none">
                        <div class="buttonBar">
                            <button id="btnNewProjectTopic" class="button">Create a new topic&nbsp;<img src="${resource(dir: 'images', file: 'newTopic.png')}"/>
                            </button>
                        </div>

                        <vpf:topicTable topics="${topics.topics}" totalCount="${topics.totalCount}" paginateAction="projectForum"/>

                    </div>
                    <div id="tabTaskTopics" style="display:none">
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
