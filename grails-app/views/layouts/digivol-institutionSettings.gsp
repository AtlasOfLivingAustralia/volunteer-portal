
<g:applyLayout name="${grailsApplication.config.ala.skin}">
<head>
    <title>Edit Institution ${institutionInstance?.name}</title>
    <r:require modules="bootstrap-switch, bootbox"/>
</head>

<body class="admin">

<tinyMce:resources/>

<cl:headerContent hideTitle="${true}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                [link: createLink(controller: 'institutionAdmin', action: 'index'), label: 'Manage Institutions'],
                [link: createLink(controller: 'institutionAdmin', action: 'edit', id: institutionInstance.id), label: institutionInstance.name]
        ]
    %>
    <h1>Institution Settings - ${institutionInstance.name}</h1>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <ul class="list-group">
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'institutionAdmin', action: 'edit', id: institutionInstance.id)}"
                                title="General Settings"/>
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'institutionAdmin', action: 'editNewsItems', id: institutionInstance.id)}"
                                title="News items"/>
                    </ul>
                </div>

                <div class="col-md-9">
                    <div class="panel panel-default subpanel">
                        <div class="panel-heading text-right" >
                            <h4 class="pull-left">${institutionInstance.name} - <g:pageProperty name="page.pageTitle"/></h4>

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
</body>
</g:applyLayout>