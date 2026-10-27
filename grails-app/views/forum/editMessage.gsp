<%@ page import="au.org.ala.volunteer.ForumController; au.org.ala.volunteer.DateConstants; au.org.ala.volunteer.User; au.org.ala.volunteer.ForumTopicType; au.org.ala.volunteer.ForumTopic" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <g:set var="topic" value="${forumMessage.topic}"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <content tag="pageType">forum</content>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="Edit Forum Message: ${topic.title}"/></title>
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

            <g:form id="messageForm" controller="forum" class="">
                <g:hiddenField name="messageId" value="${forumMessage?.id}"/>
                <g:hiddenField name="isQuotedReply" id="isQuotedReply" value="${isQuotedReply ?: params.isQuotedReply ?: 'false'}"/>

                <g:set var="includeTopicTitle" value="${!taskInstance && isEditingTopic}"/>
                <g:if test="${!taskInstance && isEditingTopic}">

                    <g:hiddenField name="topicId" value="${forumMessage?.topic?.id}"/>
                    <g:hiddenField name="isEditingTopic" value="${isEditingTopic}"/>

                </g:if>

                <vpf:topicReplyBox topic="${forumMessage.topic}" includeTopicTitle="${includeTopicTitle}" forumMessage="${forumMessage}" isEdit="true" user="${userInstance}" />
            </g:form>

            <g:if test="${params.messageText}">
                <vpf:messagePreview user="${userInstance}" isEdit="true" messageText="${params.messageText}" forumMessage="${forumMessage}" isQuotedReply="${isQuotedReply ?: params.isQuotedReply}" />
            </g:if>
        </div>

    </div>
</main>

<g:if test="${taskInstance}">
<asset:javascript src="image-viewer" asset-defer=""/>
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
    });
</asset:script>

</body>
</html>