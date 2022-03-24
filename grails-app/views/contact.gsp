<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><cl:pageTitle title="Contact Details" /></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
</head>

<body class="contact">

<cl:headerContent title="${message(code: 'default.contact.label', default: 'Contact Us')}" selectedNavItem="contact"/>
<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <h3>Help in using <g:message code="default.application.name"/> and reporting issues</h3>
                    <b>E</b> <a href="mailto:${grailsApplication.config.grails.contact.emailAddress}">${grailsApplication.config.grails.contact.emailAddress}</a><br/>
                    Australian Museum<br/>
                    Sydney NSW 2010
                    <p/>

                    <h3>Help in using the Atlas of Living Australia</h3>
                    <b>E</b> <a href="mailto:support@ala.org.au">support@ala.org.au</a><br/>
                    GPO Box 1700<br/>
                    Canberra ACT 2601
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
