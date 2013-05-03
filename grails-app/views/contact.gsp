<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    </head>

    <body>

        <sitemesh:parameter name="selectedNavItem" value="contact"/>
        <content tag="page-header">
            <nav id="breadcrumb">
                <ol>
                    <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                    <li class="last"><g:message code="default.contact.label" default="Contact Us"/></li>
                </ol>
            </nav>

            <h1>Contact Us</h1>
        </content>


        <div class="row">
            <div class="span12">
                <h2>Help in using the BVP and reporting issues</h2>
                <b>E</b> paul.flemons at austmus.gov.au<br/>
                <b>T</b> (02) 9320 6343<br/>
                Australian Museum<br/>
                Sydney NSW 2010
                <p/>

                <h2>Help in using the Atlas</h2>
                <b>E</b> <a href="mailto:support@ala.org.au">support@ala.org.au</a><br/>
                <b>T</b> (02) 6246 4108<br/>
                GPO Box 1700<br/>
                Canberra ACT 2601
            </div>
        </div>
    </body>
</html>
