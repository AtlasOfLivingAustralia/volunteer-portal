<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder; au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
        <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
        <script type="text/javascript">
          confirmDeleteAllTasks = function() {
            return confirm("Warning!!!! This will remove all tasks, including those that have already been transcribed!\n\nAre you sure you want to delete all ${taskCount} tasks for '${projectInstance.featuredLabel}'?")
          }
        </script>
    </head>
    <body class="sublevel sub-site volunteerportal">
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
            <span class="menuButton"><g:message code="default.edit.label" args="[entityName]" /></span>
        </div>
        <div>
            <h2><g:message code="default.edit.label" args="[entityName]" /></h2>
            <cl:messages />
            <g:hasErrors bean="${projectInstance}">
            <div class="errors">
                <g:renderErrors bean="${projectInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <g:hiddenField name="id" value="${projectInstance?.id}" />
                <g:hiddenField name="version" value="${projectInstance?.version}" />
                <div class="inner">
                    <table align="center">
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
                                    <tinyMce:renderEditor type="advanced" name="tutorialLinks" cols="60" rows="10" style="width:500px;">
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
                                    <g:datePicker name="created" precision="day" value="${projectInstance?.created}" default="none" noSelection="['': '']" />
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
                                  <label for="shortDescription"><g:message code="project.shortDescription.label" default="Short description" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'shortDescription', 'errors')}">
                                    <g:textArea name="shortDescription" value="${projectInstance?.shortDescription}" rows="5" cols="100" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="featuredLabel"><g:message code="project.featuredLabel.label" default="Featured Label" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'featuredLabel', 'errors')}">
                                    <g:textField name="featuredLabel" value="${projectInstance?.featuredLabel}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="featuredOwner"><g:message code="project.featuredOwner.label" default="Featured Owner" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'featuredOwner', 'errors')}">
                                    <g:textField name="featuredOwner" value="${projectInstance?.featuredOwner}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="collectionEventLookupCollectionCode"><g:message code="project.collectionEventLookupCollectionCode.label" default="Collection Event Lookup collection code" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'collectionEventLookupInstitution', 'errors')}">
                                    <g:select name="collectionEventLookupCollectionCode" from="${eventCollectionCodes}" value="${projectInstance?.collectionEventLookupCollectionCode}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="localityLookupCollectionCode"><g:message code="project.localityLookupCollectionCode.label" default="Locality Lookup collection code" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'localityEventLookupInstitution', 'errors')}">
                                  <g:select name="localityLookupCollectionCode" from="${eventCollectionCodes}" value="${projectInstance?.localityLookupCollectionCode}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="featuredImageCopyright"><g:message code="project.featuredImageCopyright.label" default="Featured Image Copyright (Optional)" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'featuredImageCopyright', 'errors')}">
                                    <g:textField name="featuredImageCopyright" value="${projectInstance?.featuredImageCopyright}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="inactive"><g:message code="project.inactive.label" default="Deactivate this project (will not appear in expedition list if ticked)" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'inactive', 'errors')}">
                                    <g:checkBox name="inactive" value="${projectInstance?.inactive}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="disableNewsItems"><g:message code="project.disableNewsItems.label" default="Disable news items for this project" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'disableNewsItems', 'errors')}">
                                    <g:checkBox name="disableNewsItems" value="${projectInstance?.disableNewsItems}" />
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="newsItems"><g:message code="project.newsItems.label" default="News Items" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'newsItems', 'errors')}">
                                    
<ul>
<g:each in="${projectInstance?.newsItems?}" var="n">
    <li><g:link controller="newsItem" action="show" id="${n.id}">${n?.encodeAsHTML()}</g:link></li>
</g:each>
</ul>
<g:link controller="newsItem" action="create" params="['project.id': projectInstance?.id]">${message(code: 'default.add.label', args: [message(code: 'newsItem.label', default: 'NewsItem')])}</g:link>

                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="projectAssociations"><g:message code="project.projectAssociations.label" default="Project Associations" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'projectAssociations', 'errors')}">
                                    
<ul>
<g:each in="${projectInstance?.projectAssociations?}" var="p">
    <li><g:link controller="projectAssociation" action="show" id="${p.id}">${p?.encodeAsHTML()}</g:link></li>
</g:each>
</ul>
<g:link controller="projectAssociation" action="create" params="['project.id': projectInstance?.id]">${message(code: 'default.add.label', args: [message(code: 'projectAssociation.label', default: 'ProjectAssociation')])}</g:link>

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

                            <tr class="prop">
                                <td valign="middle" class="name">
                                    <label><g:message code="project.tasks.label" default="Tasks" /></label>
                                </td>
                                <td valign="middle" class="value">
                                  <span style="padding-right: 10px"><a href="${createLink(controller: 'task', action:'list', id: projectInstance.id)}">${taskCount} tasks</a></span>
                                  <a class="button" href="${createLink(controller: 'task', action: 'load', id: projectInstance.id)}">Load tasks...</a>
                                  <span style="padding-left:5px; padding-top: 7px; padding-right: 5px; padding-bottom: 8px; background-image: url(${resource(dir: '/images', file: 'warning-button.png')})">
                                      <span class="button"><g:actionSubmit style="width: 100px" class="delete" action="deleteTasks" value="Delete all tasks" onclick="return confirmDeleteAllTasks()" /></span>
                                  </span>
                                </td>
                            </tr>

                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </div>
            </g:form>
        </div>
        <br />
        <div>
          <table align="center" border="1">
            <thead><tr><td colspan="3">Image Upload</td></tr></thead>
            <tr>
              <td style="vertical-align: middle;">
                <label><g:message code="project.featuredImage.label" default="Featured Image" /></label>
              </td>
              <td>
                <img src="${projectInstance?.featuredImage}" align="middle"/>
              </td>
              <td style="vertical-align: middle;">
                <g:form action="uploadFeaturedImage" controller="project" method="post" enctype="multipart/form-data">
                  <input type="file" name="featuredImage" />
                  <input type="hidden" name="id" value="${projectInstance.id}" />
                  <g:submitButton name="Upload" />
                </g:form>
                <br/>
                Images should be 254 x 158 pixels in size
              </td>
            </tr>
          </table>
        </div>
    </body>
</html>
