<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
</head>

<body>

<cl:headerContent title="${message(code: 'default.contact.label', default: 'Contact Us')}" selectedNavItem="contact"/>

<div class="row">
    <div class="span12">
        <h3>Help in using <g:message code="default.application.name"/> and reporting issues</h3>
        <b>E</b> paul.flemons at austmus.gov.au<br/>
        <b>T</b> (02) 9320 6343<br/>
        Australian Museum<br/>
        Sydney NSW 2010
        <p/>

        <h3>Help in using the Atlas of Living Australia</h3>
        <b>E</b> <a href="mailto:support@ala.org.au">support@ala.org.au</a><br/>
        <b>T</b> (02) 6246 4108<br/>
        GPO Box 1700<br/>
        Canberra ACT 2601
    </div>
</div>
</body>
</html>
