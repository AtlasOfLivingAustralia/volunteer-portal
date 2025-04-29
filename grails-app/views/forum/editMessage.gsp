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
</cl:headerContent>

<main>
    <section class="forum-nav-section">
        <g:set var="topicTypeName" value="${forumMessage.topic.topicType.name()}" />
        <div class="forum-nav-row">
            <nav class="forum-filter-nav">
                <div class="forum-nav-header">
                    <span class="pill pill--bg-${topicTypeName.toLowerCase()}">${topicTypeName}</span>
                    <g:if test="${forumMessage.topic.isAnswered}">
                        <span class="pill pill--bg-answered">Answered</span>
                    </g:if>
                </div>
            </nav>
            <nav class="forum-filter-nav">
                <div class="forum-nav-header">
                    <div class="forum-nav-return">
                        <g:link controller="forum" action="viewForumTopic" id="${forumMessage.topic.id}">Return to topic</g:link>
                    </div>
                </div>
            </nav>
        </div>
    </section>
    <section class="topic-view-section">
        <g:if test="${taskInstance}">
            <g:render template="taskSummary" model="${[taskInstance: taskInstance]}"/>
        </g:if>

        <ol>
            <g:form id="messageForm" controller="forum" class="forum-post__form">
            <g:hiddenField name="messageId" value="${forumMessage?.id}"/>
            <g:if test="${!taskInstance && isEditingTopic}">

            <g:hiddenField name="topicId" value="${forumMessage?.topic?.id}"/>
            <g:hiddenField name="isEditingTopic" value="${isEditingTopic}"/>

            <li class="forum-post__list-item hr-spacer">
                <article>
                    <div class="forum-post__header forum-post__header-title">
                        <div class="filter-nav__label">
                            <label for="title" class="forum-post__title_label"><g:message code="forum.topic.edit.title.label" default="Topic title"/></label>
                        </div>
                        <g:textField id="title" name="title" class="form-control" value="${(params.title ? params.title : forumMessage?.topic?.title)}"/>
                    </div>
                </article>
            </li>

            </g:if>



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
