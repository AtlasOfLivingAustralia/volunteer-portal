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
        <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.mousewheel.min.js')}"></script>
        <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery-panZoom.js')}"></script>

        <style type="text/css">

        .buttonBar {
            margin-bottom: 10px;
        }

        .button {
            height: 30px;
        }

        .pan-image {
          height: 400px;
          width: 600px;
          overflow: hidden;
          background-color: #808080;
          float: left;
          cursor: move;
          /* margin: 10px auto;*/
        }

        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">

            $(document).ready(function () {

                $("#btnReply").click(function (e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'forum', action:'postMessage', params: [topicId:topic.id])}";
                });

                $("#btnReturnToForum").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'forum', action:'redirectTopicParent', id: topic.id)}";
                });

                $("#chkWatchTopic").click(function(e) {
                    e.preventDefault();
                    var checked = $("#chkWatchTopic").is(':checked');
                    $.ajax("${createLink(controller: 'forum', action:'ajaxWatchTopic', params:[topicId: topic.id])}&watch=" + checked).done(function(result) {
                        $('#chkWatchTopic').prop('checked', checked);
                    });
                });

                $(".editMessageButton").click(function(e) {
                    var messageId = $(this).parents("tr[messageId]").attr("messageId");
                    if (messageId) {
                        window.location = "${createLink(action:'editMessage')}?messageId=" + messageId;
                    }
                });

                $(".deleteMessageButton").click(function(e) {
                    var messageId = $(this).parents("tr[messageId]").attr("messageId");
                    if (messageId) {
                        if (confirm("Are you sure you wish to permanently delete this message?")) {
                            window.location = "${createLink(action:'deleteTopicMessage')}?messageId=" + messageId;
                        }
                    }
                });

                <g:if test="${taskInstance}">

                $("#btnViewTask").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'task', action:'show', id: taskInstance.id)}";
                });

                $(".pan-image img").panZoom({
                  pan_step: 10,
                  zoom_step: 5,
                  min_width: 200,
                  min_height: 200,
                  mousewheel:true,
                  mousewheel_delta: 2,
                  'zoomIn'    :  $('#zoomin'),
                  'zoomOut'   :  $('#zoomout'),
                  'panUp'     :  $('#pandown'),
                  'panDown'   :  $('#panup'),
                  'panLeft'   :  $('#panright'),
                  'panRight'  :  $('#panleft')
                });

                $(".pan-image img").panZoom('fit');

                </g:if>

            });

        </script>

        <cl:navbar selected=""/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <vpf:forumNavItems topic="${topic}" />
            </div>
        </header>

        <div>
            <div class="inner">
                <div class="buttonBar">
                    <button id="btnReturnToForum" class="button"><img src="${resource(dir: 'images', file: 'left_arrow.png')}"/>&nbsp;Return to forum</button>
                    <g:if test="${!topic.locked}">
                        <button id="btnReply" class="button"><img src="${resource(dir: 'images', file: 'reply.png')}"/>&nbsp;Post Reply</button>
                    </g:if>
                    <g:if test="${taskInstance}">
                        <button id="btnViewTask" class="button">View Task</button>
                    </g:if>
                </div>
                <g:if test="${taskInstance}">
                    <section class="taskSummary">
                        <vpf:taskSummary task="${taskInstance}" />
                    </section>
                </g:if>
                <div>
                    <g:checkBox id="chkWatchTopic" name="watchTopic" checked="${isWatched}" />&nbsp; Watch this topic?
                </div>
                <vpf:topicMessagesTable topic="${topic}"/>
            </div>
        </div>
    </body>
</html>
