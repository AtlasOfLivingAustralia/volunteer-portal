<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="Tutorials"/></title>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="tutorials-2.scss"/>
</head>
<body>

<cl:headerContent title="${message(code: 'default.tutorials.label', default: 'Tutorials')}" selectedNavItem="tutorials">

</cl:headerContent>

<main>
    <section class="tutorial-groups-section">
        <ul class="tutorial-library-list">
            <li class="tutorial-library-list-item tutorial-library-list-item--bg-digivol-orange">
                <a href="${createLink(controller: 'tutorials', action: 'groupList', params: [admin: true])}" class="tutorial-library-list-item__inner">
                        <asset:image src="digivol-logo-email.png" class="tutorial-library-list-item__logo" alt="DigiVol Administration Tutorials"/>
                    <div>
                        <h2 class="tutorial-library-list-item__heading">DigiVol Administration</h2>
                        <p class="tutorial-library-list-item__tutorial-count">${tutorialAdminCount} tutorials</p>
                    </div>
                </a>
            </li>
            <g:each in="${tutorialGroups}" var="institution">
            <li class="tutorial-library-list-item">
                <a href="${createLink(controller: 'tutorials', action: 'groupList', params: [institution: institution.id])}" class="tutorial-library-list-item__inner">
                    <img class="tutorial-library-list-item__logo" src="<cl:institutionLogoUrl id="${institution.id}"/>" alt="${institution.name}"/>
                    <div>
                        <h2 class="tutorial-library-list-item__heading">${institution.name}</h2>
                        <p class="tutorial-library-list-item__tutorial-count">
                            ${institution.tutorials.size()} tutorial<g:if test="${institution.tutorials.size() > 1}">s</g:if>
                        </p>
                    </div>
                </a>
            </li>
            </g:each>
        </ul>
    </section>
</main>

</body>
</html>