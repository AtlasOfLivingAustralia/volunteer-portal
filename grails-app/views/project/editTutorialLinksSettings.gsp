<%@ page import="au.org.ala.volunteer.WebUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
</head>

<body>

<content tag="pageTitle"><g:message code="project.edit_tutorial.label"/></content>

<content tag="adminButtonBar">
</content>

<g:form method="post" class="form-horizontal">
    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>

<!--    <div class="form-group">
        <div class="col-md-12">
            g:textArea nai18nTutorialLinksinks" class="mce form-control" rows="10" value="{projectInstani18nTutorialLinksinks}" />
        </div>

    </div>-->

    <!-- form language selector -->
    <g:render template="/layouts/formLanguageDropdown"/>

    <div class="form-group" >
        <div class="col-md-10" id="tutorialLinks">
            <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                <span class="i18n-field i18n-field-${it.toString()}">
                    <g:textArea class="mce form-control" name="i18nTutorialLinks.${it.toString()}" rows="10" value="${WebUtils.safeGet(projectInstance.i18nTutorialLinks, it.toString())}"/>
                </span>
            </g:each>
        </div>
    </div>


    <div class="form-group">
        <div class="col-md-12">
            <g:actionSubmit class="save btn btn-primary" action="updateTutorialLinksSettings"
                            value="${message(code: 'default.button.update.label', default: 'Update')}"/>
        </div>
    </div>

</g:form>

</body>
</html>
