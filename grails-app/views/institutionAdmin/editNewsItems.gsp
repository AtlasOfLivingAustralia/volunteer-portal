<%@ page contentType="text/html;charset=UTF-8" import="au.org.ala.volunteer.Institution" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-institutionSettings"/>
    <g:set var="entityName" value="${message(code: 'institution.label', default: 'Institution')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
    <g:setProvider library="jquery"/>
</head>

<body>

<content tag="pageTitle">News items</content>

<content tag="adminButtonBar">
    <a class="btn btn-primary"
       href="${createLink(controller: 'newsItem', action: 'create', params: ['institution.id': institutionInstance.id])}"><i
            class="icon-plus icon-white"></i> Add news item</a>
</content>

<div class="form-horizontal">
    <div class="control-group">
        <label for="enableNewItems">
            News items are <g:checkBox name="enableNewsItems" checked="${!institutionInstance.disableNewsItems}"/>
        </label>
    </div>
</div>


<g:form name="enableNewsItemsForm" action="updateNewsItems">

    <g:hiddenField name="id" value="${institutionInstance?.id}"/>
    <g:hiddenField name="version" value="${institutionInstance?.version}"/>
    <g:hiddenField name="disableNewsItems" value=""/>

</g:form>

${newsItems?.size() ?: 0} news items

<table class="table table-striped table-hover">
    <thead>
    <tr>
        <th>Date</th>
        <th>Content</th>
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

<r:script>
    jQuery(function ($) {

        $('input:checkbox').bootstrapSwitch({
            size: "small"
        });

        $('input:checkbox').on('switchChange.bootstrapSwitch', function (event, state) {
            $("#disableNewsItems").val(!state);
            $("#enableNewsItemsForm").submit();
        });
    });
</r:script>

</body>
</html>