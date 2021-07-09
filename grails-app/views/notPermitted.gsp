<html>
<head>
    <title><cl:pageTitle title="An error has occured" /></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <style type="text/css">
    .message {
        border: 1px solid black;
        padding: 5px;
        background-color: #E9E9E9;
    }

    .stack {
        border: 1px solid black;
        padding: 5px;
        overflow: auto;
        height: 300px;
    }

    .snippet {
        padding: 5px;
        background-color: white;
        border: 1px solid black;
        margin: 3px;
        font-family: courier;
    }
    </style>
</head>

<body>
<div class="container">
<div class="row">
    <div class="col-sm-12">
        <h1><g:message code="error.title" default="Not authorised" /></h1>

        <div>
            The page you have just requested requires permission or authorisation to access.<br /><br />
            If you have followed a bookmark and/or this is unexpected, please contact the <a href="mailto:digivol@australian.museum?subject=DigiVol%20Website%20Error">DigiVol team</a>
            and provide the below information.
        </div>

        <h4 style="padding-top:20px;">Details:</h4>
        <div class="message" style="margin-bottom: 100px;">
            <strong>Error Status Code:</strong> ${request.'javax.servlet.error.status_code'} ${request.'javax.servlet.error.message'.encodeAsHTML()}<br/>
            <strong>URL:</strong> ${grailsApplication.config.server.url}${request.'javax.servlet.error.request_uri'}<br/>

            <g:if test="${exception}">
                <strong>Exception Message:</strong> <g:if test="${exception.message}">${exception.message?.encodeAsHTML()}</g:if> <g:else>None, see cause below.</g:else><br/>
                <strong>Caused by:</strong> ${exception.cause?.encodeAsHTML()} <br/>
                <strong>Class:</strong> ${content.className} <br/>
                <strong>At Line:</strong> [${content.lineNumber}] <br/>
            </g:if>

        </div>
    </div>
</div>
</div>
</body>
</html>