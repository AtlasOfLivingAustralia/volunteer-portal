<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
</head>

<body>

<cl:headerContent title="${message(code: 'default.leaderboard.label', default: 'Honour Board - {0}', args: [heading])}"
                  selectedNavItem="bvp">
</cl:headerContent>

<div class="container">

    <div class="card my-2">
        <div class="card-body">

            <div class="table-responsive col-8 col-lg-6 mx-auto">
                <table class="table table-borderless table-hover align-middle">
                <thead>
                <tr class="border-bottom text-uppercase fs-7 text-muted">
                    <th scope="col">Volunteer</th>
                    <th scope="col" class="text-end">Tasks completed</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${results}" var="row" status="i">
                    <tr class="${i == 0 ? 'fw-bold' : ''}">
                        <td>
                            <span class="badge ${i == 0 ? 'bg-warning text-dark' : i == 1 ? 'bg-secondary' : i == 2 ? 'bg-bronze text-dark border' : 'bg-white text-dark border'} me-2">${i + 1}</span>
                            <a href="${createLink(controller: 'user', action: 'show', id: row.userId)}">${row.name}</a>
                        </td>
                        <td class="text-end ${i == 0 ? 'text-success' : ''}">${formatNumber(number: row.score, format: '###,###')}</td>
                    </tr>
                </g:each>
                </tbody>
                </table>
            </div>

        </div>
    </div>

</div>

</body>
</html>