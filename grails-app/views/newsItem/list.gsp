<%@ page import="au.org.ala.volunteer.NewsItem" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="admin">
<div class="container">

    <%
        def headingByLine = projectInstance?.featuredLabel ?: institutionInstance?.name ?: ""
    %>

    <cl:headerContent crumbLabel="${message(code: 'default.list.label', args: [entityName])}" title="News Items ${headingByLine ? " - " + headingByLine : ' list'}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
            ]
            if (projectInstance) {
                pageScope.crumbs + [
                        [link: createLink(controller: 'project', action: 'show', id: projectInstance.id), label: projectInstance.featuredLabel]
                ]
            } else if (institutionInstance) {
                pageScope.crumbs + [
                        [link: createLink(controller: 'institution', action: 'index', id: institutionInstance.id), label: institutionInstance.acronym]
                ]
            }
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn style="text-align: left; width: 100px" property="created"
                                              title="${message(code: 'newsItem.created.label', default: 'Date')}"/>
                            <g:sortableColumn style="text-align: left; width: 200px" property="title"
                                              title="${message(code: 'newsItem.title.label', default: 'Title')}"/>
                            <g:sortableColumn style="text-align: left" property="body"
                                              title="${message(code: 'newsItem.body.label', default: 'Body')}"/>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${newsItemInstanceList}" status="i" var="newsItemInstance">
                            <tr>

                                <td style="vertical-align: top"><g:formatDate date="${newsItemInstance.created}"
                                                                              format="dd MMM, yyyy"/></td>

                                <td style="vertical-align: top">
                                    <b><g:link controller="newsItem" action="show"
                                               id="${newsItemInstance.id}">${fieldValue(bean: newsItemInstance, field: "title")}</g:link></b>

                                    <cl:ifAdmin>
                                        <div style="padding-top: 20px">
                                            <g:link class="btn btn-small" controller="newsItem" action="edit"
                                                    id="${newsItemInstance.id}">Edit...</g:link>
                                        </div>
                                    </cl:ifAdmin>

                                </td>

                                <td>
                                    <div class="lead">
                                        ${newsItemInstance?.shortDescription}
                                    </div>

                                    <div>
                                        ${newsItemInstance?.body}
                                    </div>
                                </td>

                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${newsItemInstanceTotal}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<r:script type="text/javascript">
    $("th > a").addClass("btn")
    $("th.sorted > a").addClass("active")
</r:script>

</body>
</html>
