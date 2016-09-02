<%@ page contentType="text/html"%>
<!DOCTYPE HTML>
<html>
<head>
    <title>New Transcribers</title>
</head>

<body>
<p>The following users have completed their fifth transcription within the last 24 hours:</p>
<ul>
    <g:each in="${newTranscribers}" var="t">
        <li><g:link absolute="true" controller="user" action="show" id="${t.userId}">${t.displayName}</g:link></li>
    </g:each>
</ul>
</body>
</html>