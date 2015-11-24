<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><cl:pageTitle title="Tutorials" /></title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
</head>

<body class="tutorial">

<cl:headerContent title="${message(code: 'default.tutorials.label', default: 'Tutorials')}" selectedNavItem="tutorials">
    <cl:ifAdmin>
        </div>
        <div class="col-sm-2">
            <a class="btn btn-primary" href="${createLink(controller: 'admin', action: 'tutorialManagement')}">Manage</a>
    </cl:ifAdmin>
</cl:headerContent>

<div class="container">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:each in="${tutorials.keySet().sort()}" var="group">
                        <g:if test="${tutorials[group]}">
                            <h3>${group == '-' ? 'Generic Tutorials' : group}</h3>
                            <div class="list-group">
                                <g:each in="${tutorials[group]?.sort({ it.title })}" var="tute">
                                    <a class="list-group-item" href="${tute.url}">${tute.title}</a>
                                </g:each>
                            </div>
                        </g:if>
                    </g:each>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
