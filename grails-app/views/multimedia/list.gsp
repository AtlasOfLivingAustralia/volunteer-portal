<%@ page import="au.org.ala.volunteer.Multimedia" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'multimedia.label', default: 'Multimedia')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="two-column-right">
<div id="content">
    <div class="section">
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message
                    code="default.home.label"/></a></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label"
                                                                                       args="[entityName]"/></g:link></span>
        </div>

        <div>
            <h1><g:message code="default.list.label" args="[entityName]"/></h1>
            <cl:messages/>
            <div class="list">
                <table>
                    <thead>
                    <tr>

                        <g:sortableColumn property="id" title="${message(code: 'multimedia.id.label', default: 'Id')}"/>

                        <g:sortableColumn property="created"
                                          title="${message(code: 'multimedia.created.label', default: 'Created')}"/>

                        <g:sortableColumn property="creator"
                                          title="${message(code: 'multimedia.creator.label', default: 'Creator')}"/>

                        <g:sortableColumn property="filePath"
                                          title="${message(code: 'multimedia.filePath.label', default: 'File Path')}"/>

                        <g:sortableColumn property="filePathToThumbnail"
                                          title="${message(code: 'multimedia.filePathToThumbnail.label', default: 'File Path To Thumbnail')}"/>

                        <g:sortableColumn property="licence"
                                          title="${message(code: 'multimedia.licence.label', default: 'Licence')}"/>

                    </tr>
                    </thead>
                    <tbody>
                    <g:each in="${multimediaInstanceList}" status="i" var="multimediaInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                            <td><g:link action="show"
                                        id="${multimediaInstance.id}">${fieldValue(bean: multimediaInstance, field: "id")}</g:link></td>

                            <td><g:formatDate date="${multimediaInstance.created}"/></td>

                            <td>${fieldValue(bean: multimediaInstance, field: "creator")}</td>

                            <td>${fieldValue(bean: multimediaInstance, field: "filePath")}</td>

                            <td>${fieldValue(bean: multimediaInstance, field: "filePathToThumbnail")}</td>

                            <td>${fieldValue(bean: multimediaInstance, field: "licence")}</td>

                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>

            <div class="paginateButtons">
                <g:paginate total="${multimediaInstanceTotal}"/>
            </div>
        </div>
    </div>
</div>
</body>
</html>
