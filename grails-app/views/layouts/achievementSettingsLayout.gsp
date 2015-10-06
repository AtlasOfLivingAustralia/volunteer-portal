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
        <g:set var="entityName"
               value="${message(code: 'achievementDescription.label', default: 'Achievement Description')}"/>
        <title><g:message code="default.edit.label" args="[entityName]"/></title>
        <r:require module="bootstrap-switch"/>
    </head>

    <body>

    <cl:headerContent hideTitle="${true}" selectedNavItem="achievements">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Admin'],
                    [link: createLink(controller: 'achievementDescription', action: 'index'), label: 'Manage Achievements'],
                    [link: createLink(controller: 'achievementDescription', action: 'edit', id: achievementDescriptionInstance?.id), label: achievementDescriptionInstance.name]
            ]
        %>
        <h1>Achievement Settings - ${achievementDescriptionInstance?.name}</h1>
    </cl:headerContent>

    <div class="container-fluid">

        <div class="row-fluid">
            <div class="span3">
                <ul class="nav nav-list nav-stacked nav-tabs">
                    <cl:settingsMenuItem
                            href="${createLink(controller: 'achievementDescription', action: 'edit', id: achievementDescriptionInstance?.id)}"
                            title="General Settings"/>
                    <cl:settingsMenuItem
                            href="${createLink(controller: 'achievementDescription', action: 'awards', id: achievementDescriptionInstance?.id)}"
                            title="Awards"/>
                    <cl:settingsMenuItem
                            href="${createLink(controller: 'achievementDescription', action: 'editTest', id: achievementDescriptionInstance?.id)}"
                            title="Tester"/>
                </ul>
            </div>

            <div class="span9">
                <legend>
                    ${achievementDescriptionInstance.name} - <g:pageProperty name="page.pageTitle"/>
                    <div class="btn-group pull-right" style="margin-left: 5px;margin-right: 5px">
                        <g:pageProperty name="page.adminButtonBar"/>
                    </div>

                </legend>

                <div class="row-fluid">
                    <div class="span12">
                        <g:layoutBody/>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </body>
</g:applyLayout>