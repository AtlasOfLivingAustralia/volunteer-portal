<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title><cl:pageTitle title="${topic.title}"/></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <asset:stylesheet src="forum.css"/>
    <asset:stylesheet src="image-viewer"/>

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
        <button class="btn btn-default" id="btnReturnToForum" class="button"><asset:image
                src="left_arrow.png"/>&nbsp;<g:message code="forum.return"/></button>
        <g:if test="${taskInstance}">
            <button id="btnViewTask" class="btn btn-success"><g:message code="forum.view_task"/></button>
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
                        <g:checkBox id="chkWatchTopic" name="watchTopic" checked="${isWatched}"/>&nbsp; <g:message code="forum.watch_this_topic"/>?
                    </div>
                    <vpf:topicMessagesTable topic="${topic}"/>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:script type="text/javascript">

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
                if (confirm("${message(code: 'forum.delete.confirmation')}")) {
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

</asset:script>
</body>
</html>
