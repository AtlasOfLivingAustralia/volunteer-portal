<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
</head>

<body>

<cl:headerContent title="${message(code: 'default.leaderboard.label', default: 'Honour Board - {0}', args: [heading])}"
                  selectedNavItem="bvp">
</cl:headerContent>

<div class="container">
    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-body">
                    <table class="table table-bordered table-striped">
                        <thead>
                        <tr>
                            <th>Volunteer</th>
                            <th>Tasks completed</th>
                        </tr>
                        </thead>
                        <g:each in="${results}" var="row" status="i">
                            <tr>
                                %{--<td><strong>${i+1}</strong></td>--}%
                                <td><a href="${createLink(controller: 'user', action: 'show', id: row.userId)}">${row.name}</a></td>
                                <td>${row.score}</td>
                            </tr>
                        </g:each>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>