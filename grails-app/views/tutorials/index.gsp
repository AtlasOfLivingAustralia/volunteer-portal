<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title><g:message code="default.application.name" /> - Atlas of Living Australia</title>
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
                    <g:if test="${tutorials[group]}">
                    <h3>${group == '-' ? 'Generic Tutorials' : group}</h3>
                    <ul class="nav nav-tabs nav-stacked">
                        <g:each in="${tutorials[group]?.sort({it.title})}" var="tute">
                            <li>
                                <a href="${tute.url}">${tute.title}</a>
                            </li>
                        </g:each>
                    </ul>
                    </g:if>
                </g:each>
            </div>

        </div>
    </body>
</html>
