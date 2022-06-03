<html>
<head>
    <title><cl:pageTitle title="Opting Out of Institution Communications" /></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
</head>

<body>
<div class="container">
<div class="row">
    <div class="col-sm-12">
        <h2><g:message code="institutionMessage.optout.title" default="Opt out of Institution Communications" /></h2>

        <div style="padding-bottom: 20px;">
            <g:if test="${success}">
                Success! You have chosen to opt-out of DigiVol Institution Communications.<br>
                <br>
                You will no longer receive email from Institutions within DigiVol.<br>
                If you wish to undo this action, please contact the
                <a href="mailto:digivol@australian.museum?subject=DigiVol%20Website%20Error">DigiVol team</a>.
            </g:if>
            <g:else>
                Unfortunately, we were not able to process your request successfully.<br>
                <br>
                If you still wish to opt-out of the Institution communication, please forward your request to the
                <a href="mailto:digivol@australian.museum?subject=DigiVol%20Website%20Error">DigiVol team</a>.
            </g:else>
        </div>

    </div>
</div>
</div>
</body>
</html>