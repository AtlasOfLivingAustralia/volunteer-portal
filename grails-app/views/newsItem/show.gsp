<%@ page import="au.org.ala.volunteer.NewsItem" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <g:set var="entityName" value="${message(code: 'newsItem.label', default: 'NewsItem')}"/>
    <title><g:message code="default.show.label" args="[entityName]"/></title>
</head>

<body>

<cl:headerContent title="${newsItemInstance.title}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'newsItem', action: 'list', id: newsItemInstance?.project?.id), label: message(code: 'default.list.label', args: [entityName])],
        ]

        if (newsItemInstance.project) {
            pageScope.crumbs << [link: createLink(controller: 'project', action: 'show', id: newsItemInstance?.project?.id), label: newsItemInstance.project?.featuredLabel]
        }
    %>
</cl:headerContent>

<div class="row">
    <div class="span12">

        <legend>
            ${fieldValue(bean: newsItemInstance, field: "shortDescription")}
            <small class="pull-right"><g:formatDate date="${newsItemInstance.created}"
                                                    format="yyyy-MM-dd HH:mm"/> by <cl:userDisplayName
                    userId="${newsItemInstance.createdBy}"/></small>
        </legend

        <div>
            ${newsItemInstance.body}
        </div>

        <br/>

        <div>
            <g:link class="btn btn-small" controller="newsItem" action="list">Read more news items...</g:link>
        </div>

        <cl:ifAdmin>
            <div style="margin-top: 15px">
                <g:form>
                    <div class="alert alert-info">
                        <g:hiddenField name="id" value="${newsItemInstance?.id}"/>
                        <g:actionSubmit class="edit  btn btn-small" action="edit"
                                        value="${message(code: 'default.button.edit.label', default: 'Edit')}"/>
                        <g:actionSubmit class="delete btn btn-small btn-danger" action="delete"
                                        value="${message(code: 'default.button.delete.label', default: 'Delete')}"
                                        onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');"/>
                    </div>
                </g:form>
            </div>
        </cl:ifAdmin>
    </div>
</div>

</body>
</html>
