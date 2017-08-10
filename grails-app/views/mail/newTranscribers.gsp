<%@ page contentType="text/html"%>
<!DOCTYPE HTML>
<html>
<head>
    <title><g:message code="mail.newTranscribers.title"/></title>
</head>

<body>
<p><g:message code="mail.newTranscribers.description"/></p>
<ul>
    <g:each in="${newTranscribers}" var="t">
        <li><g:link absolute="true" controller="user" action="show" id="${t.userId}">${t.displayName}</g:link></li>
    </g:each>
</ul>
</body>
</html>