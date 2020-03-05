<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.ala.skin}">
    <g:set var="entityName" value="${message(code: 'landingPage.label', default: 'Landing Page')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.landingPage.label', default: 'Manage Landing Pages')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]

    %>

    <g:link class="btn btn-success" action="create"><i
            class="icon-plus icon-white"></i>&nbsp;Add Landing Page</g:link>
    %{--<a class="btn btn-success" href="${createLink(action: "edit", params: [mode: 'create'])}"><i
            class="icon-plus icon-white"></i>&nbsp;Add Landing Page</a>--}%
</cl:headerContent>
<div class="container" role="main">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                        <tr>
                            <g:sortableColumn property="title" mapping="landingPageTitle"
                                              title="${message(code: 'landingPageAdmin.title', default: 'Title')}"/>

                            <g:sortableColumn width="8%" property="enabled" mapping="enabled"
                                              title="${message(code: 'landingPageAdmin.enabled.label', default: 'Enabled')}"/>

                            <g:sortableColumn width="13%" property="projectType" mapping="projectType"
                                              title="${message(code: 'landingPageAdmin.enabled.label', default: 'Expedition Type')}"/>

                            <g:sortableColumn width="20%" property="label.value" mapping="label"
                                              title="${message(code: 'landingPageAdmin.tags.label', default: 'Tags')}"/>

                            <g:sortableColumn width="15%" property="dateCreated" mapping="dateCreated"
                                              title="${message(code: 'landingPageAdmin.dateCreated.label', default: 'Date Created')}"/>

                            <g:sortableColumn width="15%" property="lastUpdated" mapping="lastUpdated"
                                              title="${message(code: 'landingPageAdmin.lastUpdated.label', default: 'Last Updated')}"/>

                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${landingPageInstanceList}" status="i" var="landingPage">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
                                <td style="vertical-align: middle;">
                                    <h3><g:link action="edit"
                                                id="${landingPage.id}">${fieldValue(bean: landingPage, field: "title")}</g:link></h3>

                                    <div class="well-small">
                                        <g:if test="${landingPage.bodyCopy}">
                                            <p><markdown:renderHtml text="${landingPage.bodyCopy}" /></p>
                                        </g:if>
                                    </div>
                                </td>

                                <td style="vertical-align: middle;">${fieldValue(bean: landingPage, field: "enabled")}</td>

                                <td style="vertical-align: middle;">${landingPage.projectType?.label}</td>

                                <td style="vertical-align: middle;">${(landingPage.label)? landingPage.label*.toMap().value.join(", ") : ''}</td>

                                <td style="vertical-align: middle;"><g:formatDate
                                        date="${landingPage.dateCreated}"/></td>

                                <td style="vertical-align: middle;"><g:formatDate
                                        date="${landingPage.lastUpdated}"/></td>

                                <td style="vertical-align: middle;">
                                    <g:form url="[action: 'delete', id: landingPage.id]" method="DELETE">
                                        <g:actionSubmit class="btn btn-danger delete-landingPage"
                                                        value="${message(code: 'default.button.delete.label', default: 'Delete')}"/>
                                        <a class="btn btn-default"
                                           href="${createLink(controller: 'landingPageAdmin', action: 'edit', id: landingPage.id)}"><i
                                                class="fa fa-edit"></i></a>
                                    </g:form>
                                </td>

                            </tr>
                        </g:each>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <g:paginate total="${landingPageCount ?: 0}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
