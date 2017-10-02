<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title><cl:pageTitle title="${message(code: 'contact.title')}" /></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
</head>

<body class="contact">

<cl:headerContent title="${message(code: 'default.contact.label', default: 'Contact Us')}" selectedNavItem="contact"/>
<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <h3><g:message code="contact.help_in_using_digivol"/></h3>

                    <p>
                        <b>${message(code: 'contact.email_address.e')}</b> <a href="mailto:${message(code: 'contact.email_address')}">${message(code: 'contact.email_address')}</a><br/>
<!--                        <b>T</b> <g:message code="contact.phone"/><br/>-->
                        <g:message code="contact.address"/>
                    <p/>

                    <h3><g:message code="contact.help_in_using_ala"/></h3>
                    <p>
<!--                        <b>E</b> <a href="mailto:${message(code: 'contact.ala.email_address')}">${message(code: 'contact.ala.email_address')}</a>
                        <br/>
                        <b>T</b> <g:message code="contact.ala.phone"/>
                        <br/>
                        <g:message code="contact.ala.address"/>-->
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
