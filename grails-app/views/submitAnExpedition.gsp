<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    </head>

    <body>
        <sitemesh:parameter name="selectedNavItem" value="submitexpedition"/>
        <content tag="page-header">
            <nav id="breadcrumb">
                <ol>
                    <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                    <li class="last"><g:message code="default.submit.label" default="Submit an Expedition"/></li>
                </ol>
            </nav>

            <h1>Submit an Expedition</h1>
        </content>

        <div class="row">
            <div class="span12">
                <p style="font-size: 1.2em">
                    The Biodiversity Volunteer Portal is open to any institution or individual who has suitable biodiversity
                    information that needs transcribing, whether that be in the form of specimen labels, field notes, survey sheets
                    or something similar.
                </p>

                <p>
                    Any proposed expedition will need to conform to an existing transcription task template, be suitable for an
                    existing template with some minor adjustment, or have sufficient funds to enable the development of a new
                    transcription task template.
                </p>
                So if you think you have some material that would be suitable for creating an expedition in the Biodiversity
                Volunteer Portal please get in touch with me: <strong>paul.flemons at austmus.gov.au</strong>
            </div>
        </div>
    </body>
</html>
