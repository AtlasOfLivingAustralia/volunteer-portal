<g:applyLayout name="${grailsApplication.config.ala.skin}">
<head>
    <title><cl:pageTitle title="Edit Project ${projectInstance?.name}"/></title>
    <asset:stylesheet src="bootstrap-switch"/>
    <g:layoutHead/>
    <content tag="primaryColour">${projectInstance.institution?.themeColour}</content>
</head>

<body class="admin">
<div class="container">

    <cl:headerContent hideTitle="${true}" title="${message(code: 'default.project.label', default: 'Edit Project')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'project', action: 'manage'), label: message(code: 'default.project.manage', default: 'Manage projects')],
                    [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.featuredLabel ?: ""]
            ]
        %>
        <h1>Expedition Settings - ${projectInstance.name}</h1>
        <h2><g:if test="${projectInstance.archived}"> <small><span class="label label-info"><g:message code="status.archived" /></span></small></g:if>
            <g:if test="${projectInstance.inactive}"> <small><span class="label label-warning"><g:message code="status.inactive" /></span></small></g:if></h2>
        <cl:projectCreatedBy project="${projectInstance}" />
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <ul class="list-group">
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editGeneralSettings', id: projectInstance.id)}"
                                title="General Settings"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editBannerImageSettings', id: projectInstance.id)}"
                                title="Expedition image"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editBackgroundImageSettings', id: projectInstance.id)}"
                                title="Expedition background image"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editPicklistSettings', id: projectInstance.id)}"
                                title="Picklists"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editTaskSettings', id: projectInstance.id)}"
                                title="Tasks"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editMapSettings', id: projectInstance.id)}"
                                title="Map"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editTutorialLinksSettings', id: projectInstance.id)}"
                                title="Tutorial Info"/>
                    </ul>
                </div>

                <div class="col-md-9">
                    <div class="panel panel-default subpanel">
                        <div class="panel-heading text-right" >
                            <h4 class="pull-left">${projectInstance.name} - <g:pageProperty name="page.pageTitle"/></h4>
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
                                        <i class="fa fa-cog"></i>&nbsp;Actions
                                        <span class="caret"></span>
                                    </a>
                                    <ul class="dropdown-menu">
                                        <li>
                                            <g:if test="${projectInstance.archived}">
                                                <span class="expedition disabledMenuItem" title="You cannot activate an archived expedition."><i class="fa fa-toggle-off"></i> Activate expedition</span>
                                            </g:if>
                                            <g:else>
                                            <a id="btnToggleActivation" class="${projectInstance.inactive ? 'fa fa-toggle-on' : 'fa fa-toggle-off'}"
                                               href="#"> ${projectInstance.inactive ? 'Activate expedition' : 'Deactivate expedition'}</a>
                                            </g:else>
                                        </li>
                                        <li class="divider"></li>
                                        <li>
                                            <g:link controller="task" action="projectAdmin" id="${projectInstance.id}"><i class="fa fa-share"></i>&nbsp;Expedition administration</g:link>
                                        </li>
                                        <li>
                                            <g:link controller="project" action="index" id="${projectInstance.id}"><i class="fa fa-home"></i>&nbsp;Expedition home page</g:link>
                                        </li>
                                        <li class="divider"></li>
                                        <li>
                                            <g:link controller="institutionMessage" action="create" params="${[projectId: projectInstance.id]}">
                                                <i class="fa fa-envelope-o"></i>&nbsp;Send a message to Volunteers
                                            </g:link>
                                        </li>
                                        <li class="divider"></li>
                                        <li>
                                            <a id="btnDeleteProject" href="#"><i class="fa fa-trash-o"></i>&nbsp;Delete expedition</a>
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
                title: "Delete expedition '${projectInstance.name.encodeAsJavaScript()}'",
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