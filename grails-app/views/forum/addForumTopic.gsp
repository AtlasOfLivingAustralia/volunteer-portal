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

<body class="forum">

<cl:headerContent title="${message(code: 'forum.newprojecttopic.label', default: 'New Topic')}" selectedNavItem="forum">
    <vpf:forumNavItems projectInstance="${projectInstance}" taskInstance="${taskInstance}"
                       lastLabel="true"/>
</cl:headerContent>
<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:form controller="forum" action="insertForumTopic" class="form-horizontal">
                        <g:hiddenField name="taskId" value="${taskInstance?.id}"/>
                        <g:hiddenField name="projectId" value="${projectInstance?.id}"/>

                        <g:if test="${taskInstance}">
                            <g:set var="topicTitle" value="${taskInstance.externalIdentifier ?: (catalogNumber ?: taskInstance.id)}"/>
                            <g:hiddenField name="title" value="${topicTitle}"/>
                            <h1>New forum topic for task ${topicTitle}</h1>
                            <g:render template="taskSummary" model="${[taskInstance: taskInstance]}"/>
                            <div class="form-group">
                                <label for="text" class="col-md-3 control-label">Message:</label>
                                <div class="col-md-6">
                                    <g:textArea name="text" rows="6" class="form-control" value="${params.text}"/>
                                </div>
                            </div>
                        </g:if>
                        <g:else>
                            <div class="form-group">
                                <label for="title" class="col-md-3 control-label"><g:message code="forum.newProjectTopicTitle.label" default="New topic title"/></label>
                                <div class="col-md-4">
                                    <g:textField id="title" name="title" class="form-control" value="${params.title}"/>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="text" class="col-md-3 control-label"><g:message code="forum.newProjectTopicMessage.label" default="New topic message"/></label>
                                <div class="col-md-6">
                                    <g:textArea name="text" rows="6" class="form-control" value="${params.text}"/>
                                </div>
                            </div>
                        </g:else>

                        <br/>
                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <label for="watchTopic">
                                    <g:checkBox name="watchTopic" checked="checked"/>
                                    Watch this topic
                                </label>
                            </div>
                        </div>

                        <vpf:ifModerator>
                            <h3><g:message code="forum.moderatorOptions.label" default="Moderator Options:"/></h3>

                            <div class="form-group">
                                <label for="priority" class="col-md-3 control-label"><g:message code="forum.priority.label" default="Priority"/></label>
                                <div class="col-md-4">
                                    <g:select class="form-control" from="${au.org.ala.volunteer.ForumTopicPriority.values()}" name="priority"/>
                                </div>
                            </div>

                            <div class="form-group">
                                <div class="col-md-offset-3 col-md-9">
                                    <label for="sticky">
                                        <g:checkBox name="sticky" checked="${params.sticky}"/>
                                        <g:message code="forum.sticky.label" default="Sticky"/>
                                    </label>
                                </div>
                                <div class="col-md-offset-3 col-md-9">
                                    <label for="locked">
                                        <g:checkBox name="locked" checked="${params.locked}"/>
                                        <g:message code="forum.locked.label" default="Locked"/>
                                    </label>
                                </div>
                                <div class="col-md-offset-3 col-md-9">
                                    <label for="featured">
                                        <g:checkBox name="featured" checked="${params.featured}"/>
                                        <g:message code="forum.featured.label" default="Featured topic"/> (<span>will be displayed on the Forum entry page if ticked</span>)
                                    </label>
                                </div>
                            </div>
                        </vpf:ifModerator>
                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <button class="btn btn-primary" type="submit">Save</button>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>