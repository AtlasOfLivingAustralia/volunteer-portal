%{--
  - ﻿Copyright (C) 2013 Atlas of Living Australia
  - All Rights Reserved.
  -
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  -
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%

<g:applyLayout name="${grailsApplication.config.ala.skin}">
    <head>
        <style type="text/css">

        .icon-chevron-right {
            float: right;
            margin-top: 2px;
            margin-right: -6px;
            opacity: .25;
        }

        </style>
        <title>Edit Project ${projectInstance?.name}</title>
    </head>

    <body>
        <cl:headerContent title="${message(code: 'default.edit.label', args: ['Expedition'])} - ${projectInstance.name}" selectedNavItem="expeditions">
            <%
                pageScope.crumbs = [
                        [link: createLink(controller: 'project', action: 'index', id:projectInstance.id), label: projectInstance.featuredLabel]
                ]
            %>
            <div class="pull-right">
                <g:form controller="project" action="updateGeneralSettings">
                    <g:hiddenField name="id" value="${projectInstance.id}" />
                    <g:if test="${projectInstance.inactive}">
                        <g:hiddenField name="inactive" value="false"/>
                        <button type="submit" class="btn btn-success">Activate expedition</button>
                    </g:if>
                    <g:else>
                        <g:hiddenField name="inactive" value="true"/>
                        <button type="submit" class="btn btn-warning">Deactivate expedition</button>
                    </g:else>
                    <g:actionSubmit class="delete btn btn-danger" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
                </g:form>
            </div>

        </cl:headerContent>

        <div class="container-fluid">

            <div class="row-fluid">
                <div class="span3">
                    <ul class="nav nav-list nav-stacked nav-tabs">
                        <cl:settingsMenuItem href="${createLink(controller: 'project', action: 'editGeneralSettings', id:projectInstance.id)}" title="General Settings" />
                        <cl:settingsMenuItem href="${createLink(controller: 'project', action: 'editBannerImageSettings', id:projectInstance.id)}" title="Banner image" />
                        <cl:settingsMenuItem href="${createLink(controller: 'project', action: 'editPicklistSettings', id:projectInstance.id)}" title="Picklists" />
                        <cl:settingsMenuItem href="${createLink(controller: 'project', action: 'editTaskSettings', id:projectInstance.id)}" title="Tasks" />
                        <cl:settingsMenuItem href="${createLink(controller: 'project', action: 'editMapSettings', id:projectInstance.id)}" title="Map" />
                        <cl:settingsMenuItem href="${createLink(controller: 'project', action: 'editTutorialLinksSettings', id:projectInstance.id)}" title="Tutorial Links" />
                        <cl:settingsMenuItem href="${createLink(controller: 'project', action: 'editNewsItemsSettings', id:projectInstance.id)}" title="News items" />
                    </ul>
                </div>

                <div class="span9">
                    <h2><g:pageProperty name="page.pageTitle"/></h2>
                    <g:layoutBody/>
                </div>
            </div>
        </div>
    </body>
</g:applyLayout>