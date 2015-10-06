<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>
    <r:require module="panZoom"/>

    <r:script type="text/javascript">

            $(document).ready(function () {

                <g:if test="${taskInstance}">

        $("#btnViewTask").click(function(e) {
            e.preventDefault();
            window.location = "${createLink(controller: 'task', action: 'show', id: taskInstance.id)}";
                });

    </g:if>

        });

    </r:script>

</head>

<body>

<cl:headerContent title="" selectedNavItem="forum" hideTitle="${true}" hideCrumbs="${true}">
    <vpf:forumNavItems topic="${topic}"
                       lastLabel="${message(code: 'forum.newprojecttopic.label', default: 'New Topic')}"/>
</cl:headerContent>

<g:form controller="forum" action="insertForumTopic">
    <g:hiddenField name="taskId" value="${taskInstance?.id}"/>
    <g:hiddenField name="projectId" value="${projectInstance?.id}"/>

    <g:if test="${taskInstance}">
        <g:set var="topicTitle" value="${taskInstance.externalIdentifier ?: (catalogNumber ?: taskInstance.id)}"/>
        <g:hiddenField name="title" value="${topicTitle}"/>
        <h1>New forum topic for task ${topicTitle}</h1>
        <g:render template="taskSummary" model="${[taskInstance: taskInstance]}"/>
        <h3>Message:</h3>
    </g:if>
    <g:else>
        <h3><g:message code="forum.newProjectTopicTitle.label" default="New topic title"/></h3>
        <g:textField id="title" name="title" maxlength="200" value="${params.title}"/>
        <h3><g:message code="forum.newProjectTopicMessage.label" default="New topic message"/></h3>
    </g:else>

    <div class="row">
        <div class="span12">
            <g:textArea class="span12" name="text" rows="6" cols="80" value="${params.text}"/>
        </div>
    </div>

    <div class="row">
        <div class="span12">
            <label for="watchTopic">
                <g:checkBox name="watchTopic" checked="checked"/>
                Watch this topic
            </label>
        </div>
    </div>

    <vpf:ifModerator>
        <div class="moderatorOptions">
            <h2><g:message code="forum.moderatorOptions.label" default="Moderator Options"/></h2>
            <label for="sticky"><g:message code="forum.sticky.label" default="Sticky"/></label>
            <g:checkBox name="sticky" checked="${params.sticky}"/>
            <br/>
            <label for="locked"><g:message code="forum.locked.label" default="Locked"/></label>
            <g:checkBox name="locked" checked="${params.locked}"/>
            <br/>
            <label for="priority"><g:message code="forum.priority.label" default="Priority"/></label>
            <g:select from="${au.org.ala.volunteer.ForumTopicPriority.values()}" name="priority"/>
            <br/>
            <label for="featured"><g:message code="forum.featured.label" default="Featured topic"/></label>
            <g:checkBox name="featured" checked="${params.featured}"/>
            <span>Will be displayed on the Forum entry page if ticked</span>
        </div>
    </vpf:ifModerator>
    <button class="btn btn-primary" type="submit">Save</button>
</g:form>
</body>
</html>