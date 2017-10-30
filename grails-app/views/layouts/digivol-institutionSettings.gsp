<%@ page contentType="text/html; charset=UTF-8" %>


<g:applyLayout name="${grailsApplication.config.ala.skin}">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title><cl:pageTitle title="${institutionInstance?.i18nName}"/></title>
    <asset:stylesheet src="bootstrap-switch"/>
    <g:render template="/layouts/tinyMce" />
    <g:layoutHead/>
</head>

<body class="admin">

<cl:headerContent hideTitle="${true}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                [link: createLink(controller: 'institutionAdmin', action: 'index'), label: 'Manage Institutions'],
                [link: createLink(controller: 'institutionAdmin', action: 'edit', id: institutionInstance.id), label: institutionInstance.i18nName]
        ]
    %>
    <h1><g:message code="institutionSettings.title"/> - ${institutionInstance.i18nName}</h1>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <ul class="list-group">
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'institutionAdmin', action: 'edit', id: institutionInstance.id)}"
                                title="${message(code: 'institutionSettings.general_settings')}"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'institutionAdmin', action: 'editNewsItems', id: institutionInstance.id)}"
                                title="${message(code: 'institutionSettings.news_items')}"/>
                    </ul>
                </div>

                <div class="col-md-9">
                    <div class="panel panel-default subpanel">
                        <div class="panel-heading text-right" >
                            <h4 class="pull-left">${institutionInstance.i18nName} - <g:pageProperty name="page.pageTitle"/></h4>

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
<asset:javascript src="bootstrap-switch" asset-defer="" />
<asset:javascript src="bootbox" asset-defer="" />
<asset:javascript src="tinymce-simple" asset-defer=""/>
</body>
</g:applyLayout>