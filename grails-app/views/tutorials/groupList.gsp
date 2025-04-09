<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <title><cl:pageTitle title="${message(code: 'tutorials.groupList.label', default: 'Tutorial Library')}"/></title>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="tutorials-2.scss"/>
    <g:set var="admin" value="${params.admin == true || params.admin == 'true'}" />
    <g:set var="groupTitle" value="${admin ? 'DigiVol Administration' : institution.name}" />
</head>
<body>

<cl:headerContent title="${message(code: 'tutorials.groupList.label', default: 'Tutorial Library')}" selectedNavItem="tutorials">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'tutorials', action: 'index'), label: message(code: 'default.tutorials.label', default: 'Tutorials')]
        ]
    %>
    <h2 class="tutorial-groups-heading">${groupTitle}</h2>
</cl:headerContent>

<main>
    <section class="tutorial-groups-section">
        <ol>
            <g:each in="${tutorialList}" var="tutorial">
                <li class="tutorial-library-group-list__list-item">
                    <div class="tutorial-library-group-list__list-item-text">
                        <cl:tutorialLink tutorial="${tutorial}" hideLinkIcon="true">${tutorial.name}</cl:tutorialLink>
                    </div>
                </li>
            </g:each>
        </ol>
    </section>
</main>

</body>
</html>