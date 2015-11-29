<g:applyLayout name="${grailsApplication.config.ala.skin}">
<head>
    <title>Edit Project ${projectInstance?.name}</title>
    <r:require module="bootstrap-switch"/>
    <content tag="primaryColour">${projectInstance.institution?.themeColour}</content>
</head>

<body class="admin">
<tinyMce:resources/>
<div class="container">

    <cl:headerContent hideTitle="${true}" title="${message(code: 'default.project.label', default: 'Edit Project')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'project', action: 'index', id: projectInstance.id), label: projectInstance.featuredLabel ?: ""]
            ]
        %>
        <h1>Expedition Settings - ${projectInstance.name} <small><muted>${projectInstance.inactive ? '(Deactivated)' : ''}</muted>
        </small></h1>
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
                                title="Tutorial Links"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'project', action: 'editNewsItemsSettings', id: projectInstance.id)}"
                                title="News items"/>
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
                                            <a id="btnToggleActivation" class="${projectInstance.inactive ? 'fa fa-toggle-on' : 'fa fa-toggle-off'}"
                                               href="#"> ${projectInstance.inactive ? 'Activate expedition' : 'Deactivate expedition'}</a>
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
<script>
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
</script>
</body>
</g:applyLayout>