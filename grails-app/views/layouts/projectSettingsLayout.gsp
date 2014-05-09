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

        .dropdown-menu a {
            text-decoration: none;
        }

        </style>
        <title>Edit Project ${projectInstance?.name}</title>
        <r:require module="bootstrap-switch" />

    </head>

    <body>

        <tinyMce:resources />



        <cl:headerContent hideTitle="${true}" selectedNavItem="expeditions">
            <%
                pageScope.crumbs = [
                        [link: createLink(controller: 'project', action: 'index', id:projectInstance.id), label: projectInstance.featuredLabel]
                ]
            %>
            <h1>Expedition Settings - ${projectInstance.name} <small><muted>${projectInstance.inactive ? '(Deactivated)' : ''}</muted></small></h1>
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
                    <legend>
                        ${projectInstance.name} - <g:pageProperty name="page.pageTitle"/>
                        <div class="btn-group pull-right">
                            <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
                                <i class="icon-cog"></i>&nbsp;Actions
                                <span class="caret"></span>
                            </a>
                            <ul class="dropdown-menu">
                                <li>
                                    <a id="btnToggleActivation" href="#">${projectInstance.inactive ? 'Activate expedition' : 'Deactivate expedition'}</a>
                                </li>
                                <li class="divider"></li>
                                <li>
                                    <a id="btnDeleteProject" href="#"><i class="icon-trash"></i>&nbsp;Delete expedition</a>
                                </li>
                            </ul>
                        </div>
                        <div class="btn-group pull-right" style="margin-left: 5px;margin-right: 5px">
                            <g:pageProperty name="page.adminButtonBar"/>
                        </div>


                        <g:form name="activationForm" controller="project" action="updateGeneralSettings">
                            <g:hiddenField name="id" value="${projectInstance.id}" />
                            <g:if test="${projectInstance.inactive}">
                                <g:hiddenField name="inactive" value="false"/>
                            </g:if>
                            <g:else>
                                <g:hiddenField name="inactive" value="true"/>
                            </g:else>
                        </g:form>

                    </legend>
                    <div class="row-fluid">
                        <div class="span12">
                            <g:layoutBody/>
                        </div>
                    </div>
                </div>
            </div>
    </div>
        <script>
            $(document).ready(function() {
                $("#btnDeleteProject").click(function(e) {
                    e.preventDefault();
                    var opts = {
                        title: "Delete expedition '${projectInstance.name}'",
                        url: "${createLink(action:"deleteProjectFragment",id: projectInstance.id)}"
                    };

                    bvp.showModal(opts);
                });

                $("#btnToggleActivation").click(function(e) {
                    e.preventDefault();
                    $("#activationForm").submit();
                });

            });
        </script>
    </body>
</g:applyLayout>