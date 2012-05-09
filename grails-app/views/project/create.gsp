<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
        <title><g:message code="default.create.label" args="[entityName]" /></title>
        <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
    </head>
    <body class="sublevel sub-site volunteerportal">
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
            <span class="menuButton"><g:message code="default.create.label" args="[entityName]" /></span>
        </div>
        <div>
            <h2><g:message code="default.create.label" args="[entityName]" /></h2>
            <cl:messages />
            <g:hasErrors bean="${projectInstance}">
              <div class="errors">
                <g:renderErrors bean="${projectInstance}" as="list" />
              </div>
            </g:hasErrors>
            <g:form action="save" >
                <div class="inner">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="name"><g:message code="project.name.label" default="Name" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'name', 'errors')}">
                                    <g:textField name="name" maxlength="200" value="${projectInstance?.name}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="description"><g:message code="project.description.label" default="Description" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'description', 'errors')}">
                                    %{--<g:textArea name="description" cols="40" rows="5" value="${projectInstance?.description}" />--}%
                                    <tinyMce:renderEditor type="advanced" name="description" cols="60" rows="10" style="width:500px;">
                                        ${projectInstance?.description}
                                    </tinyMce:renderEditor>
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="description"><g:message code="project.tutorialLinks.label" default="Tutorial Links" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'tutorialLinks', 'errors')}">
                                    %{--<g:textArea name="tutorialLinks" cols="40" rows="5" value="${projectInstance?.tutorialLinks}" />--}%
                                    <tinyMce:renderEditor type="advanced" name="description" cols="60" rows="10" style="width:500px;">
                                        ${projectInstance?.tutorialLinks}
                                    </tinyMce:renderEditor>
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="template"><g:message code="project.template.label" default="Template" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'template', 'errors')}">
                                    <g:select name="template.id" from="${au.org.ala.volunteer.Template.list()}" optionKey="id" value="${projectInstance?.template?.id}" noSelection="['null': '']" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="created"><g:message code="project.created.label" default="Created" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'created', 'errors')}">
                                    <g:datePicker name="created" precision="day" value="${projectInstance?.created}" noSelection="['': '']" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="bannerImage"><g:message code="project.bannerImage.label" default="Banner Image" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'bannerImage', 'errors')}">
                                    <g:textField name="bannerImage" value="${projectInstance?.bannerImage}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="showMap"><g:message code="project.showMap.label" default="Show Map" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'showMap', 'errors')}">
                                    <g:checkBox name="showMap" value="${projectInstance?.showMap}" />
                                </td>
                            </tr>
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:submitButton name="create" class="save" value="${message(code: 'default.button.create.label', default: 'Create')}" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
