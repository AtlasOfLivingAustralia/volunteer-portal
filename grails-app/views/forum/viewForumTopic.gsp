<%@ page import="au.org.ala.volunteer.ForumController; au.org.ala.volunteer.DateConstants; au.org.ala.volunteer.User; au.org.ala.volunteer.ForumTopicType; au.org.ala.volunteer.ForumTopic" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <content tag="pageType">forum</content>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="Forum Topic: ${topic.title}"/></title>
    <link href="https://cdn.jsdelivr.net/npm/tom-select@2.6.2/dist/css/tom-select.css" rel="stylesheet">
    <asset:stylesheet src="image-viewer"/>
</head>

<body class="forum">
<cl:headerContent title="${topic.title}" selectedNavItem="forum" hideTitle="${true}">
    %{-- Breadcrumps and title --}%
    <vpf:forumTopicHeader topic="${topic}"/>
</cl:headerContent>

<main>
    <div class="container">
        <g:set var="projectId" value="${session[ForumController.SESSION_KEY_PROJECT_ID]}" />

        <g:if test="${taskInstance}">

        <div class="card border-0 shadow-sm bg-dark overflow-hidden text-center mb-4 position-relative group">
            <!-- Main Subject Image Asset View -->
        <g:set var="multimedia" value="${taskInstance.multimedia.first()}"/>
        <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('audio/')}">
            <g:audioWaveViewer multimedia="${multimedia}" waveColour="${taskInstance.project.institution?.themeColour}"/>
        </g:if>
        <g:else>
            <g:imageViewer multimedia="${multimedia}" preserveWidthWhenPinned="true" hideShowInOtherWindow="${true}"/>
        </g:else>
        </div>

        </g:if>

        <!-- FORUM STREAM TIMELINE POSTS -->
        <div class="d-flex flex-column gap-3 mb-4">
            <vpf:topicMessageList topic="${topic}" />

            <g:if test="${!topic.locked}">
                <g:if test="${params.messageText}">
                    <vpf:messagePreview user="${userInstance}" messageText="${params.messageText}" isQuotedReply="${isQuotedReply ?: params.isQuotedReply}" />
                </g:if>

                <g:form id="messageForm" controller="forum" class="forum-post__form">
                    <g:hiddenField name="topicId" value="${topic.id}"/>
                    <g:hiddenField name="replyTo" value="${replyTo?.id}"/>
                    <g:hiddenField name="isQuotedReply" id="isQuotedReply" value="${isQuotedReply ?: params.isQuotedReply ?: 'false'}"/>
                    <vpf:topicReplyBox topic="${topic}" user="${userInstance}" />
                </g:form>
            </g:if>
        </div>

    </div>
</main>

<g:if test="${taskInstance}">
<asset:javascript src="image-viewer.js" asset-defer=""/>
    <g:if test="${!multimedia?.mimeType || multimedia?.mimeType?.startsWith('audio/')}">
<script src="https://unpkg.com/wavesurfer.js@6.1.0/dist/wavesurfer.js"></script>
    </g:if>
</g:if>

<asset:script type="text/javascript">
    $(document).ready(function () {

        function initPanZoom() {
            // Check if the image viewer div is present
            const imageViewerDiv = document.querySelector('#image-parent-container');
            if (imageViewerDiv) {
                // Initialize PanZoom or any other functionality here
                setupPanZoom();
            }
        }

        initPanZoom();

        $('#toggleWatch').click(function() {
            // If button is disabled, stop processing
            if ($(this).hasClass('disabled')) {
                console.log("Watch button is disabled, ignoring click event.");
                return;
            }
            let iconSpan = $('.watchIcon');
            let div = $('#forumTopicFooterActions');
            let watched = $(div).attr("data-watched") === "true";
            let topicId = $(div).attr("data-topic-id");

            if (topicId) {
                // Toggle watched flag
                watched = !watched;

                $.ajax("${createLink(controller: 'forum', action:'ajaxWatchTopic')}?watch="+ watched +"&topicId=" + topicId).done(function (results) {
                    $(div).attr('data-watched', watched);
                    console.log("Watch topic result: " + results);
                    if (watched) {
                        console.log("Watching topic");
                        $(iconSpan).removeClass('fa-star-o')
                            .addClass('fa-star');
                        $('.watch-button-label').text("Unwatch Topic");
                    } else {
                        console.log("Unwatching topic");
                        $(iconSpan).removeClass('fa-star')
                            .addClass('fa-star-o');
                        $('.watch-button-label').text("Watch Topic");
                    }
                });
            }
        });

        $('.message-quote').click(function(e) {
            let messageText = $(this).closest('.card').find('.message-text').html();
            const author = $(this).closest('.card').find('.author-name').text();
            const textArea = $('#messageText');

            if (messageText && messageText.length > 0) {
                let newLine = "\n";

                messageText = author + " wrote: " + "\n\n" + messageText;
                let formattedString = messageText.replace(/<blockquote>.*?<\/blockquote>/gis, "")
                    .replace(/<\/p>/gi, newLine)
                    .replace(/<\/?[^>]+(>|$)/g, "")
                    .split(newLine)
                    .map(function(line) {
                        return '> ' + line.trim();
                    })
                    .filter(line => line.trim() !== "") // Remove empty lines
                    .join(newLine); // Join with single newlines

                textArea.val(textArea.val() + formattedString + newLine).focus();
                $('#isQuotedReply').val('true');

            }
        });

        $('#messageText').on('input', function() {
            $('#isQuotedReply').val('false');
        });

        $('.edit-message').click(function() {
            const parentDiv = $(this).closest('.card-footer');
            const messageId = $(parentDiv).attr('data-message-id');
            if (messageId) {
                window.location = "${createLink(action: 'editMessage')}?messageId=" + messageId;
            }
        });

        $('.delete-message').click(function(e) {
            e.preventDefault();
            const parentDiv = $(this).closest('.card-footer');
            const messageId = $(parentDiv).attr('data-message-id');
            if (messageId) {
                bvp.confirm("${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?', args: ["message"])}", function() {
                    window.location = "${createLink(action: 'deleteTopicMessage')}?messageId=" + messageId;
                });
            }
        });

        $('.delete-topic').click(function(e) {
            e.preventDefault();
            const parentDiv = $(this).closest('.card');
            const topicId = $(parentDiv).attr('data-topic-id');
            if (topicId) {
                bvp.confirm("${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?', args: ["topic and ALL replies"])}", function() {
                    window.location = "${createLink(action: 'deleteTopic')}?topicId=" + topicId;
                });
            }
        });
    });
</asset:script>

</body>
</html>