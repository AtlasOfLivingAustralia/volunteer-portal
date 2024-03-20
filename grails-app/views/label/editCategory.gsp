<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.DateConstants" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <g:set var="entityName" value="${message(code: 'default.label.label', default: 'Tag')}"/>
    <g:set var="entityNamePlural" value="${message(code: 'default.label.plural.label', default: 'Tags')}"/>
    <title><g:message code="label.admin.editCategory.label" default="Edit Category"/></title>
    <style>
        .edit, .save-label-button {
            width: 30px;
            display: block;
            position: absolute;
            top: 0px;
            right: 0px;
            padding: 4px 10px;
            border-top-right-radius: 2px;
            border-bottom-left-radius: 5px;
            text-align: center;
            cursor: pointer;
            box-shadow: -1px 1px 4px rgba(0,0,0,0.5);
        }

        .save-label-button {
            display: none;
            background: #bd0f18;
            color: #f0f0f0;
        }
    </style>
</head>

<body class="admin">
<cl:headerContent title="${message(code: 'label.admin.editCategory.label', default: 'Edit Category')}" selectedNavItem="bvpadmin">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration'),
                 link: createLink(controller: 'label'), label: message(code: 'default.label.admin', default: 'Manage Tags')
                ]
        ]
    %>
</cl:headerContent>

<div class="container" role="main">

    <div class="panel panel-default">
        <div class="panel-body">
            <h3>Edit Category</h3>

            <g:form controller="admin" action="addUserRole" method="POST">
            <div class="form-group">
                <div class="form-row">
                    <div class="form-group col-md-2">
                        <label>Category Name</label>
                        <input class="form-control" id="category-name" type="text" placeholder="Enter the category name" value="${labelCategory.name}" required/>
                    </div>
                    <div class="form-group col-md-3">
                        <input type="submit" class="save btn btn-primary" id="addButton"
                               value="${message(code: 'default.button.add.label', default: 'Save')}"/>
                    </div>
                </div>
            </div>
            </g:form>

        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-body">

            <div class="row">
                <div class="col-md-6" style="margin-top: 20px;margin-left: 5px;">
                    ${labelCategory.labels?.size() ?: 0} ${entityNamePlural} found.
                </div>
            </div>

            <div class="row">
                <div class="col-md-12 table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <th>Tag Name</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <g:each in="${labelCategory.labels.sort { a, b -> a.value <=> b.value }}" status="i" var="label">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
                                <td style="vertical-align: middle;" data-label-id="${label.id}">
                                    <span class="save-label-button">save</span>
                                    <span class="label-value">${label.value}</span>
                                </td>
                                <td></td>
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
    $('.label-value').click(function() {
        var id = $(this).data('label-id');
        console.log("id = " + id);
        $(this).attr('contenteditable', 'true');
        $('.save-label-button').show();
    });
});
</asset:script>
</body>
</html>