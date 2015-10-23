<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body class="">

<cl:headerContent title="${message(code: 'default.show.label', args: [entityName])}" selectedNavItem="expeditions">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'project', action: 'list'), label: message(code: 'default.expeditions.label', default: 'Expeditions')]
        ]
    %>
</cl:headerContent>

%{--<div class="nav">--}%
%{--<span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></span>--}%
%{--<span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>--}%
%{--<span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>--}%
%{--</div>--}%
<div>
    <h1><g:message code="default.show.label" args="[entityName]"/> - ${projectInstance.featuredLabel}</h1>

    <cl:messages/>
    <div class="inner">
        <table>
            <tbody>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.id.label" default="Id"/></td>

                <td valign="top" class="value">${fieldValue(bean: projectInstance, field: "id")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.name.label" default="Name"/></td>

                <td valign="top" class="value">${fieldValue(bean: projectInstance, field: "name")}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.description.label" default="Description"/></td>

                <td valign="top" class="value">${projectInstance.description}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.tutorialLinks.label"
                                                         default="Tutorial Links"/></td>

                <td valign="top" class="value">${projectInstance.tutorialLinks}</td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.template.label" default="Template"/></td>

                <td valign="top" class="value"><g:link controller="template" action="show"
                                                       id="${projectInstance?.template?.id}">${projectInstance?.template?.encodeAsHTML()}</g:link></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.created.label" default="Created"/></td>

                <td valign="top" class="value"><g:formatDate date="${projectInstance?.created}"/></td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.featuredImage.label"
                                                         default="Featured Image"/></td>
                <td valign="top" class="value"><img src="${fieldValue(bean: projectInstance, field: "featuredImage")}"
                                                    height="150"/></td>
            </tr>


            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.disableNewsItems.label"
                                                         default="Disable news items for this project"/></td>
                <td valign="top" class="value"><g:formatBoolean boolean="${projectInstance?.disableNewsItems}"/></td>
            </tr>


            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.newsItems.label" default="News Items"/></td>

                <td valign="top" style="text-align: left;" class="value">
                    <ul>
                        <g:each in="${projectInstance.newsItems}" var="n">
                            <li><g:link controller="newsItem" action="show"
                                        id="${n.id}">${n?.encodeAsHTML()}</g:link></li>
                        </g:each>
                    </ul>
                </td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.projectAssociations.label"
                                                         default="Project Associations"/></td>

                <td valign="top" style="text-align: left;" class="value">
                    <ul>
                        <g:each in="${projectInstance.projectAssociations}" var="p">
                            <li><g:link controller="projectAssociation" action="show"
                                        id="${p.id}">${p?.encodeAsHTML()}</g:link></li>
                        </g:each>
                    </ul>
                </td>

            </tr>

            <tr class="prop">
                <td valign="top" class="name"><g:message code="project.showMap.label" default="Show Map"/></td>

                <td valign="top" class="value"><g:formatBoolean boolean="${projectInstance?.showMap}"/></td>

            </tr>

            %{--<tr class="prop">--}%
            %{--<td valign="top" class="name"><g:message code="project.tasks.label" default="Tasks" /></td>--}%
            %{----}%
            %{--<td valign="top" style="text-align: left;" class="value">--}%
            %{--<ul>--}%
            %{--<g:each in="${projectInstance.tasks}" var="t">--}%
            %{--<li><g:link controller="task" action="show" id="${t.id}">${t?.encodeAsHTML()}</g:link></li>--}%
            %{--</g:each>--}%
            %{--</ul>--}%
            %{--</td>--}%
            %{----}%
            %{--</tr>--}%

            </tbody>
        </table>
    </div>

    <div class="buttons">
        <g:form>
            <g:hiddenField name="id" value="${projectInstance?.id}"/>
            <span class="button"><g:actionSubmit class="edit" action="edit"
                                                 value="${message(code: 'default.button.edit.label', default: 'Edit')}"/></span>
            <span class="button"><g:actionSubmit class="delete" action="delete"
                                                 value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                                 onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/></span>
        </g:form>
    </div>
</div>
</body>
</html>
