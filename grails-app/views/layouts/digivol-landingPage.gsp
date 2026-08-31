
<g:applyLayout name="${grailsApplication.config.getProperty('ala.skin', String)}">
<head>
    <title><cl:pageTitle title="Edit Landing Page ${landingPageInstance?.title}"/></title>
    <asset:stylesheet src="bootstrap-switch"/>
    <g:layoutHead/>
</head>

<body class="admin">

<cl:headerContent hideTitle="${true}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                [link: createLink(controller: 'landingPageAdmin', action: 'index'), label: 'Manage Landing Pages'],
                [link: createLink(controller: 'landingPageAdmin', action: 'edit', id: landingPageInstance.id), label: landingPageInstance.title]
        ]
    %>
    <h1>Landing Page Settings - ${landingPageInstance.title}</h1>
</cl:headerContent>

<div class="container">
    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-3">
                    <ul class="list-group">
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'landingPageAdmin', action: 'edit', id: landingPageInstance.id)}"
                                title="General Settings"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'landingPageAdmin', action: 'editImage', id: landingPageInstance.id)}"
                                title="Upload Image"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'landingPageAdmin', action: 'editSelections', id: landingPageInstance.id)}"
                                title="Additional Tags"/>
                    </ul>
                </div>

                <div class="col-md-9">
                    <div class="card subpanel">
                        <div class="card-header text-end" style="padding-bottom: 25px;">
                            <h4 class="float-start">${landingPageInstance.title} - <g:pageProperty name="page.pageTitle"/></h4>

                            <div class="btn-group">
                                <g:pageProperty name="page.adminButtonBar"/>
                            </div>
                        </div>
                        <div class="card-body">
                            <g:layoutBody/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="bootstrap-switch" asset-defer="" />
%{--<asset:javascript src="bootbox" asset-defer="" />--}%
%{--<asset:javascript src="tinymce-simple" asset-defer=""/>--}%
</body>
</g:applyLayout>