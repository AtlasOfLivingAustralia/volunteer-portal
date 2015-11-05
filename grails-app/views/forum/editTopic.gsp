<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>
</head>

<body class="forum">

<cl:headerContent title="${message(code: 'forum.editTopic.label', default: "Edit Topic")}" selectedNavItem="forum" hideTitle="${true}">
    <vpf:forumNavItems topic="${topic}"
                       lastLabel="true"/>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:form controller="forum" action="updateTopic" params="${[topicId: topic.id]}" class="form-horizontal">
                        <div class="form-group">
                            <label for="title" class="col-md-3 control-label"><g:message code="forum.newProjectTopicTitle.label" default="New topic title"/></label>
                            <div class="col-md-4">
                                <g:textField id="title" name="title" class="form-control" value="${topic.title}"/>
                            </div>
                        </div>

                        <vpf:ifModerator>
                            <h3><g:message code="forum.moderatorOptions.label" default="Moderator Options:"/></h3>

                            <div class="form-group">
                                <label for="priority" class="col-md-3 control-label"><g:message code="forum.priority.label" default="Priority"/></label>
                                <div class="col-md-4">
                                    <g:select class="form-control" from="${au.org.ala.volunteer.ForumTopicPriority.values()}" name="priority"
                                              value="${topic.priority}"/>
                                </div>
                            </div>

                            <div class="form-group">
                                <div class="col-md-offset-3 col-md-9">
                                    <label for="sticky">
                                        <g:checkBox name="sticky" checked="${topic.sticky}"/>
                                        <g:message code="forum.sticky.label" default="Sticky"/>
                                    </label>
                                </div>
                                <div class="col-md-offset-3 col-md-9">
                                    <label for="locked">
                                        <g:checkBox name="locked" checked="${topic.locked}"/>
                                        <g:message code="forum.locked.label" default="Locked"/>
                                    </label>
                                </div>
                                <div class="col-md-offset-3 col-md-9">
                                    <label for="featured">
                                        <g:checkBox name="featured" checked="${topic.featured}"/>
                                        <g:message code="forum.featured.label" default="Featured topic"/> (<span>will be displayed on the Forum entry page if ticked</span>)
                                    </label>
                                </div>
                            </div>
                        </vpf:ifModerator>
                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <button class="btn btn-primary" type="submit">Update</button>
                            </div>
                        </div>
                    </g:form>
            </div>
        </div>
    </div>
</div>
</body>
</html>