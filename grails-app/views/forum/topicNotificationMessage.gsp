<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.DateConstants" %>
<%@page defaultCodec="none" %>
<g:message code="forum.notification.auto_generated"/>

<g:each in="${messages}" var="message" status="messageNo">

    <g:message code="forum.new_topic_notification.message"/> ${messageNo + 1}
    <g:message code="forum.new_topic_notification.topic"/> ${message.topic.title} [ ${createLink(controller: 'forum', action: 'viewForumTopic', id: message.topic.id, absolute: true)} ]
    <g:message code="forum.new_topic_notification.on"/> ${formatDate(date: message.date, format: DateConstants.DATE_TIME_FORMAT)}, ${message.user.displayName} <g:message code="forum.new_topic_notification.wrote"/>

    ${message.text}

</g:each>



