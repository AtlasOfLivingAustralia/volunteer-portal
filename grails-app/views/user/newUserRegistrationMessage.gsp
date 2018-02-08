<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.DateConstants" %>
<%@page defaultCodec="none" %>

<g:message code="user.newUserRegistrationMessage.auto_generated_message"/>

<g:message code="user.newUserRegistrationMessage.a_new_user_has_registered"/>

<g:message code="user.newUserRegistrationMessage.name"/> ${user.displayName}
<g:message code="user.newUserRegistrationMessage.email"/> ${user.userId}
<g:message code="user.newUserRegistrationMessage.user_created"/> ${formatDate(date: user.created, format: DateConstants.DATE_TIME_FORMAT)}

<g:message code="user.newUserRegistrationMessage.you_are_receiving_this_email"/>