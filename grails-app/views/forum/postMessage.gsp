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

            function getSelectedText() {
                var t = '';
                if (window.getSelection) {
                    t = window.getSelection();
                } else if (document.getSelection) {
                    t = document.getSelection();
                } else if (document.selection) {
                    t = document.selection.createRange().text;
                }
                return t;
            }

            $(document).ready(function () {

                $("#btnInsertQuote").click(function (e) {
                    e.preventDefault();

                    var selection = getSelectedText().toString();
                    if (selection && selection.length > 0) {
                        var message = "\n";
                        if ($("#insertTagLine").is(":checked")) {
                            message += "> *${replyTo.user.displayName} wrote:*  \n";
                        }
                        message += "> " + selection + "  ";

                        var txt = $("#messageText")
                        txt.val(txt.val() + message);
                    }

                });

                $("#btnCancel").click(function (e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'forum', action:'viewForumTopic', id: topic.id)}";
                });

            });

        </script>

        <cl:navbar selected=""/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <vpf:forumNavItems topic="${topic}" lastLabel="${message(code:'forum.project.newMessage', default:'New Message')}" />
                <h1>Post Message - ${topic.title}</h1>
            </div>
        </header>

        <div>
            <div class="inner">
                <h3>Replying to ${replyTo.user.displayName}, who wrote on ${formatDate(date: replyTo.date, format: 'dd MMM yyyy')}:</h3>
                <blockquote><markdown:renderHtml>${replyTo.text}</markdown:renderHtml></blockquote>

                <div class="originalMessageButtons">
                    <button id="btnInsertQuote" class="button">Insert quote</button>
                    <label for="insertTagLine">Insert tag line</label>
                    <g:checkBox name="insertTagline" id="insertTagLine" checked="true"/>
                </div>

                <h2>Your message:</h2>
                <g:form id="messageForm" controller="forum">

                    <g:hiddenField name="topicId" value="${topic.id}"/>
                    <g:hiddenField name="replyTo" value="${replyTo?.id}"/>
                    <g:textArea id="messageText" name="messageText" rows="12" cols="120" value="${params.messageText}"/>
                    <g:checkBox name="watchTopic" checked="${isWatched}"/>
                    <label for="watchTopic">Watch this topic</label>

                    <div>
                        <g:actionSubmit class="button" value="Preview" action="previewMessage"/>
                        <g:actionSubmit class="button" value="Post message" action="saveNewTopicMessage"/>
                        <button class="button" id="btnCancel">Cancel</button>
                    </div>

                </g:form>

                <g:if test="${params.messageText}">
                    <div class="messagePreview">
                        <h3>Message preview</h3>
                        <markdown:renderHtml>${params.messageText}</markdown:renderHtml>
                    </div>
                </g:if>
            </div>
        </div>
    </body>
</html>
