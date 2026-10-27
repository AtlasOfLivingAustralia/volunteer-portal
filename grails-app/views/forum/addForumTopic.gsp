<%@ page import="au.org.ala.volunteer.ForumController; au.org.ala.volunteer.DateConstants; au.org.ala.volunteer.User; au.org.ala.volunteer.ForumTopicType; au.org.ala.volunteer.ForumTopic" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <content tag="pageType">forum</content>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="Add Forum Topic"/></title>
    <asset:stylesheet src="image-viewer"/>
</head>

<body class="forum">
<g:if test="${taskInstance}">
    <g:set var="topicTitle" value="${taskInstance?.externalIdentifier ?: (catalogNumber ?: taskInstance.id)}"/>
</g:if>
<g:else>
    <g:set var="topicTitle" value="${message(code: 'forum.newpost.label', default: 'New Forum topic')}"/>
    <g:if test="${params.projectId}">
        <g:set var="topicTitle" value="${message(code: 'forum.newpost.expedition.label', default: 'New Expedition Forum topic')}"/>
    </g:if>
</g:else>

<cl:headerContent title="${topicTitle}" selectedNavItem="forum" hideTitle="${true}">
    %{-- Breadcrumps and title --}%
    <vpf:forumTopicHeader title="${topicTitle}" lastLabel="true" projectInstance="${projectInstance}" taskInstance="${taskInstance}"/>
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

            <g:form controller="forum" action="insertForumTopic" class="">
                <g:set var="projectForumId" value=""/>
                <g:if test="${taskInstance || projectInstance}">
                    <g:if test="${taskInstance}">
                        <g:set var="projectForumId" value="${taskInstance.project.id}"/>
                        <g:hiddenField name="taskId" value="${taskInstance?.id}"/>
                    </g:if>
                    <g:if test="${projectInstance}">
                        <g:set var="projectForumId" value="${projectInstance.id}"/>
                        <g:hiddenField name="projectId" value="${projectInstance?.id}"/>
                    </g:if>
                </g:if>

                <g:hiddenField name="watched" id="form-data-watched" value="false"/>
                <g:if test="${params.linkToNewsItem}">
                    <g:hiddenField name="newsItemId" value="${params.linkToNewsItem}"/>
                </g:if>

                <g:set var="includeTopicTitle" value="${true}"/>
                <g:if test="${taskInstance}">
                    <g:hiddenField name="title" value="${topicTitle}"/>
                    <g:set var="includeTopicTitle" value="${false}"/>
                </g:if>
                <!-- include topic title: [${includeTopicTitle}] -->
                <vpf:topicReplyBox newPost="true" projectId="${projectForumId}" includeTopicTitle="${includeTopicTitle}" user="${userInstance}" />
            </g:form>

            <g:if test="${params.messageText}">
                <vpf:messagePreview user="${userInstance}" isEdit="true" messageText="${params.messageText}" forumMessage="${forumMessage}" />
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

        function hydrateTooltips() {
            const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
            const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
        }

        initPanZoom();
        hydrateTooltips();

        $('#toggleWatch').click(function() {
            // If button is disabled, stop processing
            if ($(this).hasClass('disabled')) {
                console.log("Watch button is disabled, ignoring click event.");
                return;
            }
            let iconSpan = $('.watchIcon');
            let div = $('#forumTopicFooterActions');
            let watched = $(div).attr("data-watched") === "true";

            // Toggle watched flag
            watched = !watched;
            // console.log("Toggle watched: " + watched);
            $('#form-data-watched').val(watched);
            $(div).attr('data-watched', watched);
            console.log("Watch topic result: " + watched);
            if (watched) {
                console.log("Watching topic");
                $(iconSpan).removeClass('fa-star-o').addClass('fa-star');
                $('.watch-button-label').text("Unwatch Topic");
            } else {
                console.log("Unwatching topic");
                $(iconSpan).removeClass('fa-star').addClass('fa-star-o');
                $('.watch-button-label').text("Watch Topic");
            }
        });
    });
</asset:script>

</body>
</html>