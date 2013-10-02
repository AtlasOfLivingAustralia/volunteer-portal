<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.leaderboard.label', default:'Leaderboard - {0}', args: [heading])}" selectedNavItem="bvp">
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <table class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <th>Rank</th>
                            <th>Volunteer</th>
                            <th>Score</th>
                        </tr>
                    </thead>
                    <g:each in="${results}" var="row" status="i">
                        <tr>
                            <td><strong>${i+1}</strong></td>
                            <td><a href="${createLink(controller: 'user', action:'show', id:row.userId)}">${row.name}</a></td>
                            <td>${row.score}</td>
                        </tr>
                    </g:each>
                </table>
            </div>
        </div>
    </body>
</html>