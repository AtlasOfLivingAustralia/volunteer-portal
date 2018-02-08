<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title><g:message code="default.application.name"/></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <asset:stylesheet src="forum.css"/>
    <asset:stylesheet src="image-viewer"/>

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

<asset:script type="text/javascript">

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

</asset:script>

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

                    <h3><g:message code="forum.post_message.history"/></h3>

                    <div style="height: 300px; overflow-y: scroll; border: 1px solid #a9a9a9">
                        <g:each in="${topic.messages?.sort { it.date }}" var="reply">
                            <div class="messageReply" author="<cl:userDetails id="${reply?.user?.userId}" displayName="true"/>"
                                 style="border: 1px solid #a9a9a9; margin: 3px; padding: 3px; background: white">
                                <div style="background-color: #3a5c83; color: white">
                                    <asset:image src="reply.png" style="vertical-align: bottom"/>
                                    <g:message code="forum.new_topic_notification.on"/> ${formatDate(date: reply.date, format: 'dd MMM yyyy')} at ${formatDate(date: reply.date, format: 'HH:mm:ss')} <strong><cl:userDetails
                                        id="${reply?.user?.userId}" displayName="true"/></strong> <g:message code="forum.new_topic_notification.wrote"/>
                                </div>
                                <markdown:renderHtml>${reply.text}</markdown:renderHtml>
                            </div>
                        </g:each>

                    </div>

                    <div class="originalMessageButtons" class="form-inline">
                        <button class="btn btn-default" id="btnInsertQuote" class="button"><g:message code="forum.post_message.insert_quote"/></button>
                        <label for="insertTagLine">
                            <g:checkBox name="insertTagline" id="insertTagLine" checked="true"/>
                            <g:message code="forum.post_message.insert_tag_line"/>
                        </label>
                    </div>

                    <h2><g:message code="forum.post_message.your_message"/></h2>
                    <small><g:message code="forum.post_message.message.description"/> <a
                            href="${createLink(action: 'markdownHelp')}" target="popup"><g:message code="forum.post_message.description.here"/></a></small>
                    <g:form id="messageForm" controller="forum">

                        <g:hiddenField name="topicId" value="${topic.id}"/>
                        <g:hiddenField name="replyTo" value="${replyTo?.id}"/>
                        <g:textArea id="messageText" name="messageText" rows="12" cols="120" value="${params.messageText}"/>

                        <label for="watchTopic">
                            <g:checkBox name="watchTopic" checked="${isWatched}"/>
                            <g:message code="forum.post_message.watch"/>
                        </label>

                        <div>
                            <g:actionSubmit class="btn btn-success" value="${message(code: 'forum.post_message.preview')}" action="previewMessage"/>
                            <g:actionSubmit class="btn btn-primary" value="${message(code: 'forum.post_message.post')}" action="saveNewTopicMessage"/>
                            <button class="btn btn-default" id="btnCancel"><g:message code="default.cancel"/></button>
                        </div>

                    </g:form>

                    <g:if test="${params.messageText}">
                        <div class="messagePreview">
                            <h3><g:message code="forum.post_message.message_preview"/></h3>
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
