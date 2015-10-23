<%@ page import="au.org.ala.volunteer.Label" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.ala.skin}">
    <g:set var="entityName" value="${message(code: 'label.label', default: 'Label')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body>
<a href="#show-label" class="skip" tabindex="-1"><g:message code="default.link.skip.label"
                                                            default="Skip to content&hellip;"/></a>

<div class="nav" role="navigation">
    <ul>
        <li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
        <li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]"/></g:link></li>
        <li><g:link class="create" action="create"><g:message code="default.new.label"
                                                              args="[entityName]"/></g:link></li>
    </ul>
</div>

<div id="show-label" class="content scaffold-show" role="main">
    <h1><g:message code="default.show.label" args="[entityName]"/></h1>
    <g:if test="${flash.message}">
        <div class="message" role="status">${flash.message}</div>
    </g:if>
    <ol class="property-list label">

        <g:if test="${labelInstance?.category}">
            <li class="fieldcontain">
                <span id="category-label" class="property-label"><g:message code="label.category.label"
                                                                            default="Category"/></span>

                <span class="property-value" aria-labelledby="category-label"><g:fieldValue bean="${labelInstance}"
                                                                                            field="category"/></span>

            </li>
        </g:if>

        <g:if test="${labelInstance?.value}">
            <li class="fieldcontain">
                <span id="value-label" class="property-label"><g:message code="label.value.label"
                                                                         default="Value"/></span>

                <span class="property-value" aria-labelledby="value-label"><g:fieldValue bean="${labelInstance}"
                                                                                         field="value"/></span>

            </li>
        </g:if>

    </ol>
    <g:form url="[resource: labelInstance, action: 'delete']" method="DELETE">
        <fieldset class="buttons">
            <g:link class="edit" action="edit" resource="${labelInstance}"><g:message code="default.button.edit.label"
                                                                                      default="Edit"/></g:link>
            <g:actionSubmit class="delete" action="delete"
                            value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                            onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
        </fieldset>
    </g:form>
</div>
</body>
</html>
