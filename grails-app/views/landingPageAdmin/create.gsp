<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="landingPageAdmin.label" default="Landing Page Configuration"/></title>
%{--    <asset:stylesheet src="bootstrap-switch"/>
    <asset:stylesheet src="bootstrap-select.css" />
    <asset:javascript src="bootstrap-switch" asset-defer=""/>
    <asset:javascript src="bootstrap-select.js" asset-defer="" />--}%
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.landingPage.label', default: 'Create or Modify Landing Page')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                    [link: createLink(controller: 'landingPageAdmin', action: 'index'), label: message(code: 'default.landingPageAdmin.label', default: 'Manage Landing Pages')]
            ]
        %>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">

                    <g:hasErrors bean="${landingPageInstance}">
                        <ul class="errors" role="alert">

                            <g:eachError bean="${landingPageInstance}" var="error">
                                <li><g:message  error="${error}" /></li>
                            </g:eachError>
                        </ul>
                    </g:hasErrors>

                    <g:render template="generalForm"/>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
