<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <title><g:message code="landingPageAdmin.label" default="Landing Page Configuration"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'create.landingPage.label', default: 'Create Landing Page')}" selectedNavItem="bvpadmin">
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
