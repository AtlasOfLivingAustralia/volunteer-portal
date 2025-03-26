<%@ page import="au.org.ala.volunteer.ForumTopicType" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>

    <title><cl:pageTitle title="Add Forum Message"/></title>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="forum-2.scss"/>
    <asset:stylesheet src="image-viewer"/>

</head>

<body>
<g:if test="${taskInstance}">
    <g:set var="topicTitle" value="${taskInstance?.externalIdentifier ?: (catalogNumber ?: taskInstance.id)}"/>
</g:if>
<g:else>
    <g:set var="topicTitle" value="${message(code: 'forum.newpost.label', default: 'New forum message')}"/>
</g:else>

<cl:headerContent title="New forum message" selectedNavItem="forum" hideTitle="${true}">
%{-- Breadcrumps and title --}%
    <vpf:forumNavItems title="${topicTitle}" projectInstance="${projectInstance}" taskInstance="${taskInstance}"
                       lastLabel="true"/>
</cl:headerContent>

<main>
    <section class="topic-view-section">

        <g:if test="${taskInstance}">
            <g:render template="taskSummary" model="${[taskInstance: taskInstance]}"/>
        </g:if>

        <ol>
            <g:form controller="forum" action="insertForumTopic" class="form-horizontal forum-post__form">
                <g:hiddenField name="taskId" value="${taskInstance?.id}"/>
                <g:hiddenField name="projectId" value="${projectInstance?.id}"/>
                <g:hiddenField name="topicType" id="form-data-topictype" value="${ForumTopicType.Question.ordinal()}" />
                <g:hiddenField name="watched" id="form-data-watched" value="false"/>

                <g:if test="${taskInstance}">
                    <g:hiddenField name="title" value="${topicTitle}"/>
                </g:if>
                <g:else>
                    <li class="forum-post__list-item hr-spacer">
                        <article>
                            <div class="forum-post__header forum-post__header-title">
                                <div class="filter-nav__label">
                                    <label for="title" class="forum-post__title_label"><g:message code="forum.newProjectTopicTitle.label" default="New topic title"/></label>
                                </div>
                                <g:textField id="title" name="title" class="form-control" value="${params.title}"/>
                            </div>
                        </article>
                    </li>
                </g:else>

                <vpf:topicReplyBox newPost="true" user="${userInstance}" />
            </g:form>

%{--            <g:if test="${params.messageText}">--}%
%{--                <vpf:messagePreview user="${userInstance}" isEdit="true" messageText="${params.messageText}" />--}%
%{--            </g:if>--}%
        </ol>
    </section>
</main>

<asset:script type="text/javascript">
    $(document).ready(function() {
        $('.toggleWatch').click(function() {
            let iconSpan = $(this).find('span');
            let watched = $(this).attr("data-watched") === "true";
            console.log("Watched: " + watched);

            // Toggle watched flag
            watched = !watched;
            console.log("Toggle watched: " + watched);
            $('#form-data-watched').val(watched);
            $(this).attr('data-watched', watched);

            if (watched) {
                $(iconSpan).removeClass('fa-star-o').removeClass('forum-post-not-watched')
                    .addClass('fa-star')
                    .attr('title', "${message(code: 'forumTopic.watched.stopwatching', default: 'Click to unwatch')}");
            } else {
                $(iconSpan).removeClass('fa-star')
                    .addClass('fa-star-o').addClass('forum-post-not-watched')
                    .attr('title', "${message(code: 'forumTopic.watched.watch', default: 'Click to watch')}");
            }
        });

        $('.filter-topic-link').click(function() {
            let selectedPill = $(this).find('span');
            let parentDiv = $(this).closest('.forum-post-buttons--new-post-type');
            let oldSelectedPill = $(parentDiv).find('.pill--bg-selected');
            let oldSelectedType = $(oldSelectedPill).attr('data-topic-type');
            let selectedType = $(selectedPill).attr('data-topic-type');

            if (oldSelectedType !== selectedType) {
                $('#form-data-topictype').val(selectedType);
                $(oldSelectedPill).removeClass('pill--bg-selected');
                $(selectedPill).addClass('pill--bg-selected');
            }
        });

    });
</asset:script>

</body>
</html>