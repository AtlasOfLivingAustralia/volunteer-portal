<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title><g:message code="default.application.name"/></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <asset:stylesheet src="forum.css"/>

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

            $(function () {

                $("#btnCancel").click(function (e) {
                    e.preventDefault();
                    window.location = "${createLink(controller: 'forum', action: 'viewForumTopic', id: forumMessage?.topic?.id)}";
                });

            });

</asset:script>

<cl:headerContent title="${message(code: 'forum.project.editMessage', default: 'Edit Message')}" selectedNavItem="forum" hideTitle="${true}">
    <vpf:forumNavItems topic="${forumMessage?.topic}"
                       lastLabel="true"/>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <h2><g:message code="forum.edit_message.your_message"/>Your message:</h2>
                    <small><g:message code="forum.edit_message.note" /> <a
                            href="${createLink(action: 'markdownHelp')}" target="popup"><g:message code="forum.edit_message.note.here"/></a></small>
                    <g:form id="messageForm" controller="forum">
                        <g:hiddenField name="messageId" value="${forumMessage?.id}"/>
                        <g:textArea id="messageText" name="messageText" rows="12" cols="120" value="${messageText}"/>
                        <label for="watchTopic">
                            <g:checkBox name="watchTopic" checked="${isWatched}"/>
                            <g:message code="forum.edit_message.watch"/>
                        </label>

                        <div>
                            <g:actionSubmit class="btn btn-success" value="${message(code: 'forum.edit_message.preview')}" action="previewMessageEdit"/>
                            <g:actionSubmit class="btn btn-primary" value="${message(code: 'forum.edit_message.save')}" action="updateTopicMessage"/>
                            <button class="btn btn-default" id="btnCancel"><g:message code="forum.edit_message.cancel"/></button>
                        </div>

                    </g:form>

                    <g:if test="${messageText}">
                        <div class="messagePreview">
                            <h3><g:message code="forum.edit_message.message_preview"/></h3>
                            <markdown:renderHtml>${messageText}</markdown:renderHtml>
                        </div>
                    </g:if>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
