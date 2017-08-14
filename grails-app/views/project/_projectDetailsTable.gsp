<table class="table table-striped">
    <tbody>
    <tr class="prop">
        <td valign="top" class="name">
            <label for="name"><g:message code="project.name.label" default="Name"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'name', 'errors')}">
            <g:textField name="name" maxlength="200" value="${projectInstance?.name}"/>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="description"><g:message code="project.description.label" default="Description"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'i18nDescription', 'errors')}">
            <g:textArea name="description" class="mce" rows="10" cols="60" value="${projectInstance?.description}" />
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="description"><g:message code="project.tutorialLinks.label" default="Tutorial Links"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'i18nTutorialLinks', 'errors')}">
            <g:textArea name="tutorialLinks" cols="60" rows="10" class="mce" value="${projectInstance?.tutorialLinks}" />
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="template"><g:message code="project.template.label" default="Template"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'template', 'errors')}">
            <g:select name="template.id" from="${au.org.ala.volunteer.Template.list()}" optionKey="id"
                      value="${projectInstance?.template?.id}" noSelection="['null': '']"/>
            <a class="btn"
               href="${createLink(controller: 'template', action: 'edit', id: projectInstance?.template?.id)}">Edit Template</a>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="projectType"><g:message code="project.projectType.label" default="Expedition type"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'projectType', 'errors')}">
            <g:select name="projectType.id" from="${au.org.ala.volunteer.ProjectType.list()}" optionKey="id"
                      value="${projectInstance?.projectType?.id}" noSelection="['null': '']"/>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="shortDescription"><g:message code="project.shortDescription.label"
                                                     default="Short description"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'i18nShortDescription', 'errors')}">
            <g:textArea class="input-xxlarge" name="shortDescription" value="${projectInstance?.shortDescription}"
                        rows="5" cols="100"/>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="featuredLabel"><g:message code="project.featuredLabel.label" default="Featured Label"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'i18nName', 'errors')}">
            <g:textField class="input-xxlarge" name="i18nName" value="${projectInstance?.i18nName}"/>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="featuredOwner"><g:message code="project.featuredOwner.label" default="Featured Owner"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'featuredOwner', 'errors')}">
            <g:textField name="featuredOwner" value="${projectInstance?.featuredOwner}"/>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="featuredImageCopyright"><g:message code="project.featuredImageCopyright.label"
                                                           default="Featured Image Copyright (Optional)"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'featuredImageCopyright', 'errors')}">
            <g:textField class="input-xxlarge" name="featuredImageCopyright"
                         value="${projectInstance?.featuredImageCopyright}"/>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="picklistInstitutionCode"><g:message code="project.picklistInstitutionCode.label"
                                                            default="Picklist Institution Code"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'picklistInstitutionCode', 'errors')}">
            <g:select name="picklistInstitutionCode" from="${picklistInstitutionCodes}"
                      value="${projectInstance?.picklistInstitutionCode}"/>
            <span><g:message code="project.a_picklist_must_be_loaded_first" /></span>
        </td>
    </tr>


    %{--<tr class="prop">--}%
    %{--<td valign="top" class="i18nName">--}%
    %{--<label for="collectionEventLookupCollectionCode"><g:message code="project.collectionEventLookupCollectionCode.label" default="Collection Event Lookup collection code"/></label>--}%
    %{--</td>--}%
    %{--<td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'collectionEventLookupInstitution', 'errors')}">--}%
    %{--<g:select i18nName="collectionEventLookupCollectionCode" from="${eventCollectionCodes}" value="${projectInstance?.collectionEventLookupCollectionCode}"/>--}%
    %{--</td>--}%
    %{--</tr>--}%

    %{--<tr class="prop">--}%
    %{--<td valign="top" class="i18nName">--}%
    %{--<label for="localityLookupCollectionCode"><g:message code="project.localityLookupCollectionCode.label" default="Locality Lookup collection code"/></label>--}%
    %{--</td>--}%
    %{--<td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'localityEventLookupInstitution', 'errors')}">--}%
    %{--<g:select i18nName="localityLookupCollectionCode" from="${localityCollectionCodes}" value="${projectInstance?.localityLookupCollectionCode}"/>--}%
    %{--</td>--}%
    %{--</tr>--}%

    <tr class="prop">
        <td valign="top" class="name">
            <label for="inactive"><g:message code="project.inactive.label"
                                             default="Deactivate this project (will not appear in expedition list if ticked)"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'inactive', 'errors')}">
            <g:checkBox name="inactive" value="${projectInstance?.inactive}"/>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="disableNewsItems"><g:message code="project.disableNewsItems.label"
                                                     default="Disable news items for this project"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'disableNewsItems', 'errors')}">
            <g:checkBox name="disableNewsItems" value="${projectInstance?.disableNewsItems}"/>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="newsItems"><g:message code="project.newsItems.label" default="News Items"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'newsItems', 'errors')}">
            <ul>
                <g:each in="${projectInstance?.newsItems ?}" var="n">
                    <li><g:link controller="newsItem" action="show"
                                id="${n.id}">${n?.title?.encodeAsHTML()}</g:link></li>
                </g:each>
            </ul>
            <g:link class="btn btn-small" controller="newsItem" action="create"
                    params="['project.id': projectInstance?.id]">${message(code: 'default.add.label', args: [message(code: 'project.newsItem.label', default: 'NewsItem')])}</g:link>
        </td>
    </tr>

    <tr class="prop">
        <td valign="top" class="name">
            <label for="showMap"><g:message code="project.showMap.label" default="Show Map"/></label>
        </td>
        <td valign="top" class="value ${hasErrors(bean: projectInstance, field: 'showMap', 'errors')}">
            <g:checkBox name="showMap" value="${projectInstance?.showMap}"/>
        </td>
    </tr>

    <tr class="prop">
        <td valign="middle" class="name">
            <label><g:message code="project.tasks" default="Tasks"/></label>
            <span>&nbsp;(<a
                    href="${createLink(controller: 'task', action: 'list', id: projectInstance.id)}">${taskCount} <g:message code="project.tasks" /></a>)
            </span>
        </td>
        <td valign="middle" class="value">
            <a class="btn"
               href="${createLink(controller: 'task', action: 'load', id: projectInstance.id)}"><g:message code="project.load_tasks" /></a>
            <a class="btn"
               href="${createLink(controller: 'task', action: 'staging', params: [projectId: projectInstance.id])}"><g:message code="project.load_tasks_image_staging" /></a>
        </td>
    </tr>

    <tr>
        <td></td>
        <td>
            <a class="btn"
               href="${createLink(controller: 'task', action: 'loadTaskData', params: [projectId: projectInstance.id])}"><g:message code="project.load_task_data" /></a>
            <g:message code="project.load_field_values_for_existing_tasks" />
        </td>
    </tr>

    <tr class="alert">
        <td></td>
        <td>
            <span>
                <span style="padding-left:7px; padding-top: 8px; padding-right: 5px; padding-bottom: 11px; background-image: url(${asset.assetPath(src: 'warning-button.png')})">
                    <g:actionSubmit class="delete btn btn-danger" action="deleteTasks" value="${message(code: 'project.delete_all_tasks')}"
                                    onclick="return confirmDeleteAllTasks()"/>
                </span>
                &nbsp;<g:message code="project.delete_task_images" />&nbsp;<g:checkBox style="width:20px" name="deleteImages"
                                                          value="true"></g:checkBox>
            </span>
        </td>
    </tr>

    </tbody>
</table>
