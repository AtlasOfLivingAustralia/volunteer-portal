<%@ page contentType="text/html;charset=UTF-8" import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-institutionSettings"/>
    <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>

<body>

<content tag="pageTitle"><g:message code="institutionAdmin.news_items.label"/></content>

<content tag="adminButtonBar">
    <a class="btn btn-primary"
       href="${createLink(controller: 'newsItem', action: 'create', params: ['institution.id': institutionInstance.id])}"><i
            class="icon-plus icon-white"></i> <g:message code="institutionAdmin.news_items.add"/></a>
</content>

<div class="form-horizontal">
    <div class="control-group">
        <label for="enableNewItems">
            <g:message code="institutionAdmin.news_items.enabled_disabled"/> <g:checkBox name="enableNewsItems" checked="${!institutionInstance.disableNewsItems}"/>
        </label>
    </div>
</div>


<g:form name="enableNewsItemsForm" action="updateNewsItems">

    <g:hiddenField name="id" value="${institutionInstance?.id}"/>
    <g:hiddenField name="version" value="${institutionInstance?.version}"/>
    <g:hiddenField name="disableNewsItems" value=""/>

</g:form>

<g:message code="institutionAdmin.news_items.news_item_count" args="${[newsItems?.size() ?: 0]}"/>

<table class="table table-striped table-hover">
    <thead>
    <tr>
        <th><g:message code="institutionAdmin.news_items.date"/></th>
        <th><g:message code="institutionAdmin.news_items.content"/></th>
        <th/>
    </tr>
    </thead>
    <tbody>
    <g:each in="${newsItems}" var="newsItem">
        <tr>
            <td style="max-width: 40px"><g:formatDate date="${newsItem.created}" format="yyyy-MM-dd HH:mm:ss"/></td>
            <td>
                <div>
                    <strong>${newsItem.title}</strong>
                </div>

                <div>
                    <em>${newsItem.shortDescription}</em>
                </div>

                <div>
                    ${newsItem.body}
                </div>
            </td>
            <td style="max-width: 20px">
                <div class="pull-right">
                    <a class="btn btn-xs btn-danger"
                       href="${createLink(controller: 'newsItem', action: 'delete', id: newsItem.id)}"><i
                            class="fa fa-trash"></i></a>
                    <a class="btn btn-xs btn-default"
                       href="${createLink(controller: 'newsItem', action: 'edit', id: newsItem.id)}"><i
                            class="fa fa-edit"></i></a>
                </div>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>

<asset:script>
    jQuery(function ($) {

        $('input:checkbox').bootstrapSwitch({
            size: "small"
        });

        $('input:checkbox').on('switchChange.bootstrapSwitch', function (event, state) {
            $("#disableNewsItems").val(!state);
            $("#enableNewsItemsForm").submit();
        });
    });
</asset:script>

</body>
</html>