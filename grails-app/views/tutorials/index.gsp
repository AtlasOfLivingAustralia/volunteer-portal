<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.tutorials.label', default:'Tutorials')}" selectedNavItem="tutorials">
            <cl:ifAdmin>
                <a class="btn" href="${createLink(controller:'admin', action:'tutorialManagement')}">Manage</a>
            </cl:ifAdmin>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <g:each in="${tutorials.keySet().sort()}" var="group">
                    <h3>${group == '-' ? 'Generic Tutorials' : group}</h3>
                    <ul>
                        <g:if test="${group == '-'}">
                            <li>
                                <a href="${createLink(controller:'tutorials', action:'transcribingSpecimenLabels')}">Transcribing Specimen Labels</a>
                            </li>
                        </g:if>
                        <g:each in="${tutorials[group]?.sort({it.title})}" var="tute">
                            <li>
                                <a href="${tute.url}">${tute.title}</a>
                            </li>
                        </g:each>
                    </ul>
                </g:each>
            </div>

        </div>
    </body>
</html>
