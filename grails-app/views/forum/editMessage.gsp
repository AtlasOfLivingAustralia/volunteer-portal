<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="Edit Forum Message: ${forumMessage.topic.title}"/></title>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="forum-2.scss"/>
    <asset:stylesheet src="image-viewer"/>

</head>

<body>
<cl:headerContent title="${forumMessage.topic.title}" selectedNavItem="forum" hideTitle="${true}">
%{-- Breadcrumps and title --}%
    <vpf:forumNavItems topic="${forumMessage.topic}"/>
    <div class="forum-post-page-header__status-and-nav">
        <g:set var="topicTypeName" value="${forumMessage.topic.topicType.name()}" />
        <div class="pill pill--bg-${topicTypeName.toLowerCase()}">${topicTypeName}</div>
        <g:if test="${forumMessage.topic.isAnswered}">
            <div class="pill pill--bg-answered">Answered</div>
        </g:if>
    </div>
</cl:headerContent>

<main>
    <section class="topic-view-section">
        <g:if test="${taskInstance}">
            <g:render template="taskSummary" model="${[taskInstance: taskInstance]}"/>
        </g:if>

        <ol>
            <g:form id="messageForm" controller="forum" class="forum-post__form">
                <g:hiddenField name="messageId" value="${forumMessage?.id}"/>
                <vpf:topicReplyBox topic="${forumMessage.topic}" forumMessage="${forumMessage}" isEdit="true" user="${userInstance}" />
            </g:form>

            <g:if test="${params.messageText}">
                <vpf:messagePreview user="${userInstance}" isEdit="true" messageText="${params.messageText}" forumMessage="${forumMessage}" />
            </g:if>
        </ol>
    </section>
</main>

</body>
</html>
