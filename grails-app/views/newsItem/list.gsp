<%@ page import="au.org.ala.volunteer.NewsItem" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>
    </head>

    <body>

        <cl:headerContent crumbLabel="News Items" title="News Items ${projectInstance ? " - " + projectInstance.featuredLabel:''}">
            <%
            if (projectInstance) {
                pageScope.crumbs = [
                    [link: createLink(controller: 'project', action: 'show'), label: projectInstance.featuredLabel]
                ]
            }
            %>
        </cl:headerContent>

        <div class="row" id="content">
            <div class="span12">
                <table class="table">
                    <thead>
                        <tr>
                            <g:sortableColumn style="text-align: left; width: 100px" property="created" title="${message(code: 'newsItem.created.label', default: 'Date')}"/>
                            <g:sortableColumn style="text-align: left; width: 200px" property="title" title="${message(code: 'newsItem.title.label', default: 'Title')}"/>
                            <g:sortableColumn style="text-align: left" property="body" title="${message(code: 'newsItem.body.label', default: 'Body')}"/>
                            <th style="text-align: left; width: 150px"><g:message code="newsItem.project.label" default="Project"/></th>
                        </tr>
                    </thead>
                    <tbody>
                        <g:each in="${newsItemInstanceList}" status="i" var="newsItemInstance">
                            <tr>

                                <td style="vertical-align: top"><g:formatDate date="${newsItemInstance.created}" format="dd MMM, yyyy"/></td>

                                <td style="vertical-align: top">
                                    <b><g:link controller="newsItem" action="show" id="${newsItemInstance.id}">${fieldValue(bean: newsItemInstance, field: "title")}</g:link></b>

                                    <cl:ifAdmin>
                                        <div style="padding-top: 20px">
                                            <g:link class="btn btn-small" controller="newsItem" action="edit" id="${newsItemInstance.id}">Edit...</g:link>
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

                                <td style="vertical-align: top">
                                    <g:link controller="project" action="index" id="${newsItemInstance?.project?.id}">${newsItemInstance?.project?.featuredLabel}</g:link>
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

        <script type="text/javascript">
            $("th > a").addClass("btn")
            $("th.sorted > a").addClass("active")
        </script>

    </body>
</html>
