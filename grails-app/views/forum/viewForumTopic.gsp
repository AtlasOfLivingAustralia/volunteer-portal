<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><cl:pageTitle title="Forum Topic: ${topic.title}"/></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>
    <r:require module="panZoom"/>

    <style type="text/css">

    .buttonBar {
        margin-bottom: 10px;
    }

    .button {
        height: 30px;
    }

    </style>

</head>

<body class="forum">
<cl:headerContent title="${topic.title}" selectedNavItem="forum" hideTitle="${true}">
    <vpf:forumNavItems topic="${topic}"/>
    <div class="buttonBar">
        <button class="btn btn-default" id="btnReturnToForum" class="button"><img
                src="${resource(dir: 'images', file: 'left_arrow.png')}"/>&nbsp;Return to forum</button>
        <g:if test="${taskInstance}">
            <button id="btnViewTask" class="btn btn-success">View Task</button>
        </g:if>
    </div>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:if test="${taskInstance}">
                        <g:render template="taskSummary" model="${[taskInstance: taskInstance]}"/>
                    </g:if>
                    <div class="alert alert-success">
                        <g:checkBox id="chkWatchTopic" name="watchTopic" checked="${isWatched}"/>&nbsp; Watch this topic?
                    </div>
                    <vpf:topicMessagesTable topic="${topic}"/>
                </div>
            </div>
        </div>
    </div>
</div>
<r:script type="text/javascript">

    $(function () {

        $("#btnReply").click(function (e) {
            e.preventDefault();
            window.location = "${createLink(controller: 'forum', action: 'postMessage', params: [topicId: topic.id])}";
        });

        $("#btnReturnToForum").click(function(e) {
            e.preventDefault();
            window.location = "${createLink(controller: 'forum', action: 'redirectTopicParent', id: topic.id)}";
        });

        $("#chkWatchTopic").click(function(e) {
            e.preventDefault();
            var checked = $("#chkWatchTopic").is(':checked');
            $.ajax("${createLink(controller: 'forum', action: 'ajaxWatchTopic', params: [topicId: topic.id])}&watch=" + checked).done(function(result) {
                $('#chkWatchTopic').prop('checked', checked);
            });
        });

        $(".editMessageButton").click(function(e) {
            var messageId = $(this).parents("tr[messageId]").attr("messageId");
            if (messageId) {
                window.location = "${createLink(action: 'editMessage')}?messageId=" + messageId;
            }
        });

        $(".deleteMessageButton").click(function(e) {
            var messageId = $(this).parents("tr[messageId]").attr("messageId");
            if (messageId) {
                if (confirm("Are you sure you wish to permanently delete this message?")) {
                    window.location = "${createLink(action: 'deleteTopicMessage')}?messageId=" + messageId;
                }
            }
        });

    <g:if test="${taskInstance}">

        $("#btnViewTask").click(function(e) {
            e.preventDefault();
            window.location = "${createLink(controller: 'task', action: 'show', id: taskInstance.id)}";
                });

    </g:if>

    });

</r:script>
</body>
</html>
