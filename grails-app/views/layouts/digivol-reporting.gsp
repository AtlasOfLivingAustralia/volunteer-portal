
<g:applyLayout name="${grailsApplication.config.getProperty('ala.skin', String)}">
<head>
    <title><cl:pageTitle title="DigiVol Reporting"/></title>
    <g:layoutHead/>
</head>

<body class="admin">

<cl:headerContent title="${message(code: 'admin.reporting.label', default: 'DigiVol Reporting')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin', action: 'index'), label: 'Administration']
        ]
    %>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <ul class="list-group">
                        <cl:settingsMenuItem
                                href="${createLink(controller: 'report', action: 'userReport')}"
                                title="User Reporting"/>

                        <cl:settingsMenuItem
                                href="${createLink(controller: 'admin', action: 'currentUsers')}"
                                title="Current Online Users"
                                target="_blank"/>

                        <cl:ifSiteAdmin>
                            <cl:settingsMenuItem
                                    href="${createLink(controller: 'admin', action: 'projectSummaryReport')}"
                                    title="Expedition Summary Report"/>
                        </cl:ifSiteAdmin>
                    </ul>
                </div>

                <div class="col-md-9">
                    <div class="panel panel-default subpanel">
                        <div class="panel-heading text-right" style="padding-bottom: 25px;">
                            <h4 class="pull-left"><g:pageProperty name="page.pageTitle"/></h4>

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