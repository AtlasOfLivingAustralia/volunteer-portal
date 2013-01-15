<%@ page import="au.org.ala.volunteer.DateConstants" %>
The following messages have been posted on the Atlas of Living Australia Biodivirsity Volunteer Portal forum:

<g:each in="${messages}" var="message" status="messageNo">
  ----------------------
  Message: ${messageNo+1}
  Topic: ${message.message.topic.title}
  On ${formatDate(date: message.message.date, format: DateConstants.DATE_TIME_FORMAT)}, ${message.message.user.displayName} wrote:
  ${message.message.text}
</g:each>

You have received this message because you are subscribed to updates to forum topics on the Biodivirsity Volunteer Portal forum.
If you would like to unsubcribe please visit http://volunteer.ala.org.au/