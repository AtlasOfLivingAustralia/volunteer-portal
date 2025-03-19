<%@ page import="au.org.ala.volunteer.TaskForumTopic; au.org.ala.volunteer.DateConstants; au.org.ala.volunteer.User; au.org.ala.volunteer.ForumTopicType; au.org.ala.volunteer.ForumTopic" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="Forum Topic: ${topic.title}"/></title>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="forum-2.scss"/>
    <asset:stylesheet src="image-viewer"/>
</head>
<body>
<cl:headerContent title="${topic.title}" selectedNavItem="forum" hideTitle="${true}">
    %{-- Breadcrumps and title --}%
    <vpf:forumNavItems topic="${topic}"/>
    <div class="forum-post-page-header__status-and-nav">
        <g:set var="topicTypeName" value="${topic.topicType.name()}" />
        <div class="pill pill--bg-${topicTypeName.toLowerCase()}">${topicTypeName}</div>
        <g:if test="${topic.isAnswered}">
            <div class="pill pill--bg-answered">Answered</div>
        </g:if>
        <nav><a href="${createLink(controller: 'forum', action: 'index')}">Return to forum</a></nav>
    </div>
</cl:headerContent>

<main>
    <section class="topic-view-section">
        <g:if test="${taskInstance}">
            <g:render template="taskSummary" model="${[taskInstance: taskInstance]}"/>
        </g:if>

        <ol>
            <vpf:topicMessageList topic="${topic}" />
            <!-- ${params} -->

            <g:if test="${params.messageText}">
                <vpf:messagePreview user="${userInstance}" messageText="${params.messageText}" />
            </g:if>

            <g:form id="messageForm" controller="forum" class="forum-post__form">
                <g:hiddenField name="topicId" value="${topic.id}"/>
                <g:hiddenField name="replyTo" value="${replyTo?.id}"/>
            <vpf:topicReplyBox topic="${topic}" user="${userInstance}" />
            </g:form>
        </ol>
    </section>
</main>

<asset:script type="text/javascript">
    $(document).ready(function() {
        $('.message-quote').click(function(e) {
            const parentArticle = $(this).closest('article');
            const messageText = $(parentArticle).find('.message-text').html();
            const textArea = $('#messageText');

            if (messageText && messageText.length > 0) {
                let newLine = "\n";

                // Remove blockquote tags and their content
                let formattedString = messageText.replace(/<blockquote>.*?<\/blockquote>/gis, "")
                // Replace closing <p> tags with newline
                    .replace(/<\/p>/gi, newLine)
                // Remove all remaining HTML tags
                    .replace(/<\/?[^>]+(>|$)/g, "")
                // Split by newlines, trim, and filter out empty lines
                    .split(newLine)
                // Prepend '>' to each line
                    .map(function(line) {
                        return '> ' + line.trim();
                    })
                    .filter(line => line.trim() !== "") // Remove empty lines
                    .join(newLine); // Join with single newlines

                textArea.val(textArea.val() + formattedString + newLine).focus();

            }
        });
    });
</asset:script>

</body>
</html>