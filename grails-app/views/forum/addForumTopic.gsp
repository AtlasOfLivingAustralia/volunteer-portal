<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>
        <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
        <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>
        <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.mousewheel.min.js')}"></script>
        <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery-panZoom.js')}"></script>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>

        <style type="text/css">

        #title {
            width: 400px;
        }

        .pan-image {
          height: 400px;
          width: 600px;
          overflow: hidden;
          background-color: #808080;
          float: left;
          cursor: move;
          /* margin: 10px auto;*/
        }


        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <r:script type="text/javascript">

            $(document).ready(function () {

                <g:if test="${taskInstance}">

                $("#btnViewTask").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'task', action:'show', id: taskInstance.id)}";
                });

                $(".pan-image img").panZoom({
                  pan_step: 10,
                  zoom_step: 5,
                  min_width: 200,
                  min_height: 200,
                  mousewheel:true,
                  mousewheel_delta: 2,
                  'zoomIn'    :  $('#zoomin'),
                  'zoomOut'   :  $('#zoomout'),
                  'panUp'     :  $('#pandown'),
                  'panDown'   :  $('#panup'),
                  'panLeft'   :  $('#panright'),
                  'panRight'  :  $('#panleft')
                });

                $(".pan-image img").panZoom('fit');

                </g:if>

            });

        </r:script>

        <cl:navbar selected=""/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <vpf:forumNavItems projectInstance="${projectInstance}" taskInstance="${taskInstance}" lastLabel="${message(code:'forum.newprojecttopic.label', default: 'New Topic')}" />
            </div>
        </header>

        <div>
            <div class="inner">
                <g:form controller="forum" action="insertForumTopic">
                    <g:hiddenField name="taskId" value="${taskInstance?.id}" />
                    <g:hiddenField name="projectId" value="${projectInstance?.id}" />
                    <div class="newTopicFields">

                        <g:if test="${taskInstance}">
                            <g:set var="topicTitle" value="${taskInstance.externalIdentifier ?: (catalogNumber ?: taskInstance.id) }" />

                            <h1>New forum topic for task ${topicTitle}</h1>
                            <g:hiddenField name="title" value="${topicTitle}" />
                            <section class="taskSummary">
                                <vpf:taskSummary task="${taskInstance}" />
                            </section>
                            <h2>Message:</h2>
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
                                <br/>
                                <label for="featured"><g:message code="forum.featured.label" default="Featured topic"/></label>
                                <g:checkBox name="featured" checked="${params.featured}"/>
                                <span>Will be displayed on the Forum entry page if ticked</span>
                            </div>
                        </vpf:ifModerator>
                        <button type="submit">Save</button>
                    </div>
                </g:form>
            </div>
        </div>
    </body>
</html>