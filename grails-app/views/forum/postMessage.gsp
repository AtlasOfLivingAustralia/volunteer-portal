<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>

    <style type="text/css">

    h2 {
        padding-top: 10px;
    }

    textarea {
        width: 100%;
    }

    </style>

</head>

<body class="forum">

<r:script type="text/javascript">

            var replyTo = "<cl:userDetails id="${replyTo?.user?.userId}" displayName="true"/>";

            function getSelectedText() {
                var t = '';
                if (window.getSelection) {
                    t = window.getSelection();
                } else if (document.getSelection) {
                    t = document.getSelection();
                } else if (document.selection) {
                    t = document.selection.createRange().text;
                }
                if (t.anchorNode) {
                    var author = $(t.anchorNode).parents("div[author]").attr("author")
                    replyTo = author;
                }
                return t;
            }

            $(function () {

                $("#btnInsertQuote").mousedown(function(e) {
                    e.preventDefault();

                    var selection = getSelectedText().toString();
                    if (selection && selection.length > 0) {
                        var message = "\n";
                        if ($("#insertTagLine").is(":checked")) {
                            message += "> *" + replyTo + " wrote:*  \n";
                        }
                        message += "> " + selection + "  ";

                        var txt = $("#messageText")
                        txt.val(txt.val() + message);
                    }

                });

                $("#btnCancel").click(function (e) {
                    e.preventDefault();
                    window.location = "${createLink(controller: 'forum', action: 'viewForumTopic', id: topic.id)}";
                });

            });

</r:script>

<cl:headerContent title="${message(code: 'forum.project.newMessage', default: 'New Message')}" selectedNavItem="forum" hideTitle="${true}">
    <vpf:forumNavItems topic="${topic}"
                       lastLabel="true"/>
</cl:headerContent>


<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:if test="${taskInstance}">
                        <g:render template="taskSummary" model="${[taskInstance: taskInstance]}"/>
                    </g:if>

                    <h3>Conversation history:</h3>

                    <div style="height: 300px; overflow-y: scroll; border: 1px solid #a9a9a9">
                        <g:each in="${topic.messages?.sort { it.date }}" var="reply">
                            <div class="messageReply" author="<cl:userDetails id="${reply?.user?.userId}" displayName="true"/>"
                                 style="border: 1px solid #a9a9a9; margin: 3px; padding: 3px; background: white">
                                <div style="background-color: #3a5c83; color: white">
                                    <img src="${resource(dir: '/images', file: 'reply.png')}" style="vertical-align: bottom"/>
                                    On ${formatDate(date: reply.date, format: 'dd MMM yyyy')} at ${formatDate(date: reply.date, format: 'HH:mm:ss')} <strong><cl:userDetails
                                        id="${reply?.user?.userId}" displayName="true"/></strong> wrote:
                                </div>
                                <markdown:renderHtml>${reply.text}</markdown:renderHtml>
                            </div>
                        </g:each>

                    </div>

                    <div class="originalMessageButtons" class="form-inline">
                        <button class="btn btn-default" id="btnInsertQuote" class="button">Insert quote</button>
                        <label for="insertTagLine">
                            <g:checkBox name="insertTagline" id="insertTagLine" checked="true"/>
                            Insert tag line
                        </label>
                    </div>

                    <h2>Your message:</h2>
                    <small>* Note: To see help on how to format your messages, including bold and italics, see <a
                            href="${createLink(action: 'markdownHelp')}" target="popup">here</a></small>
                    <g:form id="messageForm" controller="forum">

                        <g:hiddenField name="topicId" value="${topic.id}"/>
                        <g:hiddenField name="replyTo" value="${replyTo?.id}"/>
                        <g:textArea id="messageText" name="messageText" rows="12" cols="120" value="${params.messageText}"/>

                        <label for="watchTopic">
                            <g:checkBox name="watchTopic" checked="${isWatched}"/>
                            Watch this topic
                        </label>

                        <div>
                            <g:actionSubmit class="btn btn-success" value="Preview" action="previewMessage"/>
                            <g:actionSubmit class="btn btn-primary" value="Post message" action="saveNewTopicMessage"/>
                            <button class="btn btn-default" id="btnCancel">Cancel</button>
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
        </div>
    </div>
</div>
</body>
</html>
