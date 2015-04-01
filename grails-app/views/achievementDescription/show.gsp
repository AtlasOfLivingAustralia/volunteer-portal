<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.ala.skin}">
    <g:set var="entityName"
           value="${message(code: 'achievementDescription.label', default: 'AchievementDescription')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body>
<a href="#show-achievementDescription" class="skip" tabindex="-1"><g:message code="default.link.skip.label"
                                                                             default="Skip to content&hellip;"/></a>

<div class="nav" role="navigation">
    <ul>
        <li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
        <li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]"/></g:link></li>
        <li><g:link class="create" action="create"><g:message code="default.new.label"
                                                              args="[entityName]"/></g:link></li>
    </ul>
</div>

<div id="show-achievementDescription" class="content scaffold-show" role="main">
    <h1><g:message code="default.show.label" args="[entityName]"/></h1>
    <g:if test="${flash.message}">
        <div class="message" role="status">${flash.message}</div>
    </g:if>
    <ol class="property-list achievementDescription">

        <g:if test="${achievementDescriptionInstance?.badge}">
            <li class="fieldcontain">
                <span id="badge-label" class="property-label"><g:message code="achievementDescription.badge.label"
                                                                         default="Badge"/></span>

                <span class="property-value" aria-labelledby="badge-label"><g:fieldValue
                        bean="${achievementDescriptionInstance}" field="badge"/></span>

            </li>
        </g:if>

        <g:if test="${achievementDescriptionInstance?.dateCreated}">
            <li class="fieldcontain">
                <span id="dateCreated-label" class="property-label"><g:message
                        code="achievementDescription.dateCreated.label" default="Date Created"/></span>

                <span class="property-value" aria-labelledby="dateCreated-label"><g:formatDate
                        date="${achievementDescriptionInstance?.dateCreated}"/></span>

            </li>
        </g:if>

        <g:if test="${achievementDescriptionInstance?.lastUpdated}">
            <li class="fieldcontain">
                <span id="lastUpdated-label" class="property-label"><g:message
                        code="achievementDescription.lastUpdated.label" default="Last Updated"/></span>

                <span class="property-value" aria-labelledby="lastUpdated-label"><g:formatDate
                        date="${achievementDescriptionInstance?.lastUpdated}"/></span>

            </li>
        </g:if>

        <g:if test="${achievementDescriptionInstance?.name}">
            <li class="fieldcontain">
                <span id="name-label" class="property-label"><g:message code="achievementDescription.name.label"
                                                                        default="Name"/></span>

                <span class="property-value" aria-labelledby="name-label"><g:fieldValue
                        bean="${achievementDescriptionInstance}" field="name"/></span>

            </li>
        </g:if>

    </ol>
    <g:form url="[resource: achievementDescriptionInstance, action: 'delete']" method="DELETE">
        <fieldset class="buttons">
            <g:link class="edit" action="edit" resource="${achievementDescriptionInstance}"><g:message
                    code="default.button.edit.label" default="Edit"/></g:link>
            <g:actionSubmit class="delete" action="delete"
                            value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                            onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
        </fieldset>
    </g:form>
</div>
</body>
</html>
