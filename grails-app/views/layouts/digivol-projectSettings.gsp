<%@ page contentType="text/html; charset=UTF-8" %>

<g:applyLayout name="${grailsApplication.config.ala.skin}">
<head>
    <meta name="google" value="notranslate">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title><cl:pageTitle title="${message(code: 'project.project_settings.edit', default: 'Edit Project')}"/></title>
    <asset:stylesheet src="bootstrap-switch"/>
    <g:render template="/layouts/tinyMce" />
    <g:layoutHead/>
    <content tag="primaryColour">${projectInstance.institution?.themeColour}</content>
</head>

<body class="admin">
<div class="container">

    <cl:headerContent hideTitle="${true}" title="${message(code: 'project.project_settings.edit', default: 'Edit Project')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance?.i18nName ?: ""]
            ]
        %>
            <h1><g:message code="project.project_settings.expedition_settings" /> - ${projectInstance.i18nName} <small><muted>${projectInstance.inactive ? ('(' + message(code: 'project.project_settings.deactivated') +  ')') : ''}</muted>
        </small></h1>
        <cl:projectCreatedBy project="${projectInstance}"></cl:projectCreatedBy>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <ul class="list-group">
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editGeneralSettings', id: projectInstance.id)}"
                                title="${message(code:'project.general_settings')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editBannerImageSettings', id: projectInstance.id)}"
                                title="${message(code:'project.expedition_image')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editBackgroundImageSettings', id: projectInstance.id)}"
                                title="${message(code:'project.expedition_background_image')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editPicklistSettings', id: projectInstance.id)}"
                                title="${message(code:'project.piclists.label')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editTaskSettings', id: projectInstance.id)}"
                                title="${message(code:'tasks.label')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editMapSettings', id: projectInstance.id)}"
                                title="${message(code:'project.map_settings.map')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editTutorialLinksSettings', id: projectInstance.id)}"
                                title="${message(code:'project.edit_tutorial.label')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editNewsItemsSettings', id: projectInstance.id)}"
                                title="${message(code:'project.newsItems.label')}"/>
                    </ul>
                </div>

                <div class="col-md-9">
                    <div class="panel panel-default subpanel">
                        <div class="panel-heading text-right" >
                            <h4 class="pull-left">${projectInstance.i18nName} - <g:pageProperty name="page.pageTitle"/></h4>
                            <g:form name="activationForm" controller="project" action="update" class="form-horizontal">
                                <g:hiddenField name="id" value="${projectInstance.id}"/>
                                <g:if test="${projectInstance.inactive}">
                                    <g:hiddenField name="inactive" value="false"/>
                                </g:if>
                                <g:else>
                                    <g:hiddenField name="inactive" value="true"/>
                                </g:else>
                                <div class="btn-group">
                                    <a class="btn btn-default dropdown-toggle" data-toggle="dropdown" href="#">
                                        <i class="fa fa-cog"></i>&nbsp;<g:message code="project.project_settings.actions" />
                                        <span class="caret"></span>
                                    </a>
                                    <ul class="dropdown-menu">
                                        <li>
                                            <a id="btnToggleActivation"
                                               href="#"><i class="${projectInstance.inactive ? 'fa fa-fw fa-toggle-on' : 'fa fa-fw fa-toggle-off'}"></i>&nbsp;${projectInstance.inactive ? message(code: 'project.project_settings.activate_expedition') : message(code: 'project.project_settings.deactivate_expedition')}</a>
                                        </li>
                                        <li class="divider"></li>
                                        <li>
                                            <a id="btnDeleteProject" href="#"><i class="fa fa-trash-o"></i>&nbsp;<g:message code="project.project_settings.delete_expedition" /></a>
                                        </li>
                                    </ul>
                                </div>

                                <div class="btn-group" style="margin-left: 5px;margin-right: 5px">
                                    <g:pageProperty name="page.adminButtonBar"/>
                                </div>
                            </g:form>
                        </div>
                        <div class="panel-body">
                            <g:layoutBody/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="bootstrap-switch" asset-defer="" />
<asset:javascript src="tinymce-simple" asset-defer="" />
<asset:script type="text/javascript">
    $(document).ready(function () {
        $("#btnDeleteProject").click(function (e) {
            e.preventDefault();
            var opts = {
                title: "${message(code: 'project.project_settings.delete_expedition')} '${projectInstance.i18nName.encodeAsJavaScript()}'",
                url: "${createLink(action:"deleteProjectFragment",id: projectInstance.id)}"
            };

            bvp.showModal(opts);
        });

        $("#btnToggleActivation").click(function (e) {
            e.preventDefault();
            $("#activationForm").submit();
        });
    });
</asset:script>
</body>
</g:applyLayout>