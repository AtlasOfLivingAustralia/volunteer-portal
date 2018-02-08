<%@ page contentType="text/html; charset=UTF-8" %>
<g:applyLayout name="${grailsApplication.config.ala.skin}">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="google" value="notranslate">
    <g:set var="entityName"
           value="${message(code: 'achievementDescription.label', default: 'Achievement Description')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <asset:stylesheet src="bootstrap-switch"/>
    <g:render template="/layouts/tinyMce" />
    <g:layoutHead />
</head>

<body class="admin">

<cl:headerContent title="${achievementDescriptionInstance?.i18nName}" hideTitle="true" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: message(code: 'default.admin.label')],
                [link: createLink(controller: 'achievementDescription', action: 'index'), label: message(code: 'achievementSettings.manage_achievements')]
        ]
    %>
    <h1>${message(code:"achievementSettings.achievement_settings_x", args: [achievementDescriptionInstance?.i18nName?.toString()])}</h1>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <ul class="list-group">
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'achievementDescription', action: 'edit', id: achievementDescriptionInstance?.id)}"
                                title="${message(code: 'achievementSettings.general_settings')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'achievementDescription', action: 'awards', id: achievementDescriptionInstance?.id)}"
                                title="${message(code: 'achievementSettings.awards')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'achievementDescription', action: 'editTest', id: achievementDescriptionInstance?.id)}"
                                title="${message(code: 'achievementSettings.tester')}"/>
                    </ul>
                </div>
                <div class="col-md-9">
                    <div class="panel panel-default subpanel">
                        <div class="panel-heading text-right" >
                            <h4 class="pull-left">${achievementDescriptionInstance?.i18nName} - <g:pageProperty name="page.pageTitle"/></h4>
                            <div class="btn-group">
                                <g:pageProperty name="page.adminButtonBar"/>
                            </div>

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
<asset:javascript src="bootstrap-switch" asset-defer=""/>

</body>
</g:applyLayout>