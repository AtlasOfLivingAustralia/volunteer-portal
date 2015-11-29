<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'field.label', default: 'Field')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
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

                <g:sortableColumn property="id" title="${message(code: 'field.id.label', default: 'Id')}"/>

                <th><g:message code="field.task.label" default="Task"/></th>

                <g:sortableColumn property="name" title="${message(code: 'field.name.label', default: 'Name')}"/>

                <g:sortableColumn property="recordIdx"
                                  title="${message(code: 'field.recordIdx.label', default: 'Record Idx')}"/>

                <g:sortableColumn property="transcribedByUserId"
                                  title="${message(code: 'field.transcribedByUserId.label', default: 'Transcribed By User Id')}"/>

                <g:sortableColumn property="validatedByUserId"
                                  title="${message(code: 'field.validatedByUserId.label', default: 'Validated By User Id')}"/>

            </tr>
            </thead>
            <tbody>
            <g:each in="${fieldInstanceList}" status="i" var="fieldInstance">
                <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                    <td><g:link action="show"
                                id="${fieldInstance.id}">${fieldValue(bean: fieldInstance, field: "id")}</g:link></td>

                    <td>${fieldValue(bean: fieldInstance, field: "task")}</td>

                    <td>${fieldValue(bean: fieldInstance, field: "name")}</td>

                    <td>${fieldValue(bean: fieldInstance, field: "recordIdx")}</td>

                    <td>${fieldValue(bean: fieldInstance, field: "transcribedByUserId")}</td>

                    <td>${fieldValue(bean: fieldInstance, field: "validatedByUserId")}</td>

                </tr>
            </g:each>
            </tbody>
        </table>
    </div>

    <div class="paginateButtons">
        <g:paginate total="${fieldInstanceTotal}"/>
    </div>
</div>
</body>
</html>
