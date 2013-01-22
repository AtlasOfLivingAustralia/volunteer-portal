<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>
        <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
        <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>

        <style type="text/css">

        #title {
            width: 400px;
        }

        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">

            $(document).ready(function () {
            });

        </script>

        <cl:navbar selected=""/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <vpf:forumNavItems projectInstance="${projectInstance}" taskInstance="${taskInstance}" lastLabel="${message(code:'forum.newprojecttopic.label', default: 'New Topic')}" />
            </div>
        </header>

        <div>
            <div class="inner">
                <g:form controller="forum" action="insertForumTopic" params="${[projectId: projectInstance?.id]}">
                    <g:hiddenField name="taskId" value="${taskInstance?.id}" />
                    <g:hiddenField name="projectId" value="${projectInstance?.id}" />
                    <div class="newTopicFields">

                        <g:if test="${taskInstance}">
                            <h2>Enter a message to create a forum topic for task ${taskInstance.externalIdentifier}</h2>
                            <g:hiddenField name="title" value="${taskInstance.externalIdentifier}" />
                        </g:if>
                        <g:else>
                            <h2><g:message code="forum.newProjectTopicTitle.label" default="New topic title"/></h2>
                            <g:textField id="title" name="title" maxlength="200" value="${params.title}" />
                            <h2><g:message code="forum.newProjectTopicMessage.label" default="New topic message"/></h2>
                        </g:else>

                        <g:textArea name="text" rows="6" cols="80" value="${params.text}"/>

                        <g:checkBox name="watchTopic" checked="checked"/>
                        <label for="watchTopic">Watch this topic</label>

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
                            </div>
                        </vpf:ifModerator>
                        <button type="submit">Save</button>
                    </div>
                </g:form>
            </div>
        </div>
    </body>
</html>