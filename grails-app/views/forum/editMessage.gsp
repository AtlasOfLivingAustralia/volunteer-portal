<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>
        <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
        <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>

        <style type="text/css">

        h2 {
            padding-top: 10px;
        }

        textarea {
            width: 100%;
        }

        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">

            $(document).ready(function () {

                $("#btnCancel").click(function (e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'forum', action:'viewForumTopic', id: forumMessage?.topic?.id)}";
                });

            });

        </script>

        <cl:navbar selected=""/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <vpf:forumNavItems topic="${forumMessage?.topic}" lastLabel="${message(code:'forum.project.editMessage', default:'Edit Message')}" />
            </div>
        </header>

        <div>
            <div class="inner">

                <h2>Your message:</h2>
                <g:form id="messageForm" controller="forum">
                    <g:hiddenField name="messageId" value="${forumMessage?.id}" />
                    <g:textArea id="messageText" name="messageText" rows="12" cols="120" value="${messageText}"/>
                    <g:checkBox name="watchTopic" checked="${isWatched}"/>
                    <label for="watchTopic">Watch this topic</label>
                    <div>
                        <g:actionSubmit class="button" value="Preview" action="previewMessageEdit"/>
                        <g:actionSubmit class="button" value="Save message" action="updateTopicMessage"/>
                        <button class="button" id="btnCancel">Cancel</button>
                    </div>

                </g:form>

                <g:if test="${messageText}">
                    <div class="messagePreview">
                        <h3>Message preview</h3>
                        <markdown:renderHtml>${messageText}</markdown:renderHtml>
                    </div>
                </g:if>
            </div>
        </div>
    </body>
</html>
