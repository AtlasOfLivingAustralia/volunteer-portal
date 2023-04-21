<html>
<head>
    <title><cl:pageTitle title="An error has occured" /></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
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

        <div style="padding-bottom: 4em;">
            The page you have just requested requires permission or authorisation to access.<br /><br />
            If you have followed a bookmark and/or this is unexpected, please contact the
            <a href="mailto:digivol@australian.museum?subject=DigiVol%20Website%20Error">DigiVol team</a>.
        </div>

    </div>
</div>
</div>
</body>
</html>