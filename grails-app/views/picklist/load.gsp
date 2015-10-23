<%@ page import="au.org.ala.volunteer.Project" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'record.label', default: 'Record')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body class="two-column-right">
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
</div>

<div>
    <h1>Load Picklist</h1>
    <g:form method="post" controller="picklist">
        <div class="dialog">
            <table>
                <tbody>
                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="name"><g:message code="picklist.name.label" default="Name"/></label>
                    </td>
                    <td valign="top" class="value">
                        <g:textField name="name" id="name" maxlength="200" size="80"/>
                    </td>
                </tr>

                <tr class="prop">
                    <td valign="top" class="name">
                        <label for="picklist"><g:message code="picklist.paste.here.label"
                                                         default="Paste list here"/></label>
                    </td>
                    <td valign="top" class="value">
                        <g:textArea name="picklist" value="" cols="100" rows="50"/>
                    </td>
                </tr>

                </tbody>
            </table>
        </div>

        <div class="buttons">
            <span class="button"><g:actionSubmit class="submit" action="upload"
                                                 value="${message(code: 'default.button.submit.label', default: 'Submit')}"/></span>
            <span class="button"><g:actionSubmit class="cancel" action="list"
                                                 value="${message(code: 'default.button.cancel.label', default: 'Cancel')}"/></span>
        </div>
    </g:form>
</div>
</body>
</html>
