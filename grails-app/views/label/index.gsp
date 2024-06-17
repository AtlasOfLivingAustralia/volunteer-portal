<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.DateConstants" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <g:set var="entityName" value="${message(code: 'default.label.category.label', default: 'Category')}"/>
    <g:set var="entityNamePlural" value="${message(code: 'default.label.category.plural.label', default: 'Categories')}"/>
        <title><g:message code="default.admin.entity.title.label" args="[entityNamePlural]" default="Manage Tags"/></title>
    <style>
        .label-button {
            cursor: pointer;
            font-size: 1.2em;
        }
    </style>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'default.admin.entity.title.label', args: [entityNamePlural], default: 'Tags')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
        ]
    %>

    <a class="btn btn-success" href="${createLink(action: "createCategory")}">
        <i class="icon-plus icon-white"></i>
        <g:message code="label.create.category.label" default="Create Tag Category"/>&nbsp;
    </a>
</cl:headerContent>

<div class="container" role="main">

    <div class="panel panel-default">
        <div class="panel-body">

            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    ${labelCategories?.size() ?: 0} ${entityName}s found.
                </div>
            </div>

            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <th><g:message code="label.category.name.label" default="Category"/></th>
                                <th><g:message code="label.category.labelcount.label" default="No. Tags"/></th>
                                <th><g:message code="label.category.labelcolour.label" default="Tag Colour"/></th>
                                <th><g:message code="label.category.datecreated.label" default="Date Updated"/></th>
                                <th><g:message code="label.category.createdby.label" default="Created By"/></th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <g:each in="${labelCategories}" status="i" var="labelCategory">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}" categoryId="${labelCategory.id}">
                                <g:set var="labelColourClass" value="${(!labelCategory.labelColour ? 'base' : labelCategory.labelColour)}"/>
                                <td style="vertical-align: middle; width: 35%;"><g:link action="editCategory" id="${labelCategory.id}">${labelCategory.name}</g:link></td>
                                <td style="vertical-align: middle; text-align: right; width: 8%;">${labelCategory.labels?.size()}</td>
                                <td style="vertical-align: middle; text-align: right; width: 8%;"><span class="label label-${labelColourClass}">Example Tag</span></td>
                                <td style="vertical-align: middle;">${formatDate(date: labelCategory.updatedDate, format: DateConstants.DATE_TIME_FORMAT)}</td>
                                <td style="vertical-align: middle;">${labelCategory.createdBy == 0L ? "System" : User.get(labelCategory.createdBy).displayName}</td>
                                <td>
                                    <g:if test="${(!labelCategory.isDefault)}">
                                    <i class="fa fa-trash label-button delete-label-button"
                                       data-href="${createLink(controller: 'label', action: 'deleteCategory', id: labelCategory.id)}"
                                       title="${message(code: 'default.button.delete.label', default: 'Delete')}"></i>
                                    </g:if>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>

</div>
<asset:script type="text/javascript">
$(function($) {
    $.extend({
        postGo: function(url, params) {
            var $form = $("<form>")
                .attr("method", "post")
                .attr("action", url);
            $.each(params, function(name, value) {
                $("<input type='hidden'>")
                    .attr("name", name)
                    .attr("value", value)
                    .appendTo($form);
            });
            $form.appendTo("body");
            $form.submit();
        }
    });

    $('.delete-label-button').click(function(event) {
        event.stopPropagation(); // Prevent row click event from firing
        //console.log('Delete button clicked');
        var $this = $(this);
        var href = $this.data('href');
        //console.log("href: " + href);

        bootbox.confirm("Are you sure you wish to delete this tag category and all it's tags? This action is permanent!", function(result) {
            if (result) {
                $.postGo(href);
            }
        });
    });

});
</asset:script>
    </body>
    </html>