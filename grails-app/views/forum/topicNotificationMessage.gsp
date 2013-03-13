<%@ page import="au.org.ala.volunteer.DateConstants" %>
Someone has replied to one or more of the forum topics that you are interested in:

<g:each in="${messages}" var="message" status="messageNo">
  ----------------------
  Message: ${messageNo+1}
  Topic: ${message.topic.title} [ ${createLink(controller:'forum', action:'viewForumTopic', id:message.topic.id)} ]
  On ${formatDate(date: message.date, format: DateConstants.DATE_TIME_FORMAT)}, ${message.user.displayName} wrote:
  <markdown:renderHtml text="${message.text}" />
  s
</g:each>



