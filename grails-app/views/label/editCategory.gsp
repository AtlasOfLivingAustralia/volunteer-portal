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
        .edit-label-button, .save-label-button {
            /*display: block;*/
            /*position: absolute;*/
            top: 0px;
            right: 20px;
            padding: 4px 10px;
            text-align: center;
            cursor: pointer;
            float: right;
        }

        .btn {
            border-radius: 5px;
        }

        .save-label-button {
            display: none;
        }

        .edit-label-button {
            display: inline;
        }

        .focus {
            outline: -webkit-focus-ring-color auto 1px;
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

            <g:form controller="label" action="saveCategory" method="POST">
            <div class="form-group">
                <div class="form-row">
                    <div class="form-group col-md-2" style="vertical-align: middle;">
                        <label class="control-label col-md-2" for="name">
                            Category Name:
                        </label>
                    </div>
                    <div class="form-group col-md-4" style="vertical-align: middle;">
                        <input class="form-control" id="name" name="name" type="text" placeholder="Enter the category name" value="${labelCategory.name}" required/>
                        <input type="hidden" name="categoryId" value="${labelCategory.id}"/>
                    </div>
                    <div class="form-group col-md-3" style="vertical-align: middle;">
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
                    <table class="table table-striped table-hover" id="label-list">
                        <thead>
                            <tr>
                                <th>Tag Name</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <g:each in="${labelCategory.labels.sort { a, b -> a.value <=> b.value }}" status="i" var="label">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'} label-data">
                                <td style="vertical-align: middle;" class="label-value col-md-10" data-label-id="${label.id}">
                                    ${label.value}
                                </td>
                                <td class="col-md-2" style="text-align: center;">
                                    <i class="fa fa-save save-label-button" style="font-size: 1.5em;" contenteditable="false" title="${message(code: 'default.button.add.label', default: 'Save')}"></i>
                                    <i class="fa fa-pencil edit-label-button" style="font-size: 1.5em;" contenteditable="false" title="${message(code: 'default.button.edit.label', default: 'Edit')}"></i>
                                </td>
                                <td class="col-md-6"></td>
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
    var activeRow = null;

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

    // Attach click event listeners to each row
    function toggleEdit(row) {
        var $row = $(row).closest('tr.label-data');

        if (activeRow !== null && activeRow[0] !== $row[0]) {
            // activeRow.find('td.label-value').removeAttr('contenteditable');
            // activeRow.find('.save-label-button').hide();
            alert("Please save the current label before editing another.");
            return;
        }

        // Toggle contenteditable attribute for the row
        $row.find('td.label-value').each(function() {
            var contentEditable = $(this).attr('contenteditable');
            if (contentEditable === 'true') {
                // Save icon clicked
                $(this).removeAttr('contenteditable');
                $(this).removeClass('focus');
                saveLabel($row);
            } else {
                // Edit icon clicked
                $(this).attr('contenteditable', 'true');
                $(this).addClass('focus');
                $(this).focus();
                document.execCommand('selectAll', false, null);
            }
        });

        // Toggle icon display
        $row.find('.save-label-button').toggle();
        $row.find('.edit-label-button').toggle();

        // Update the activeRow
        if ($row.find('.save-label-button').is(':hidden')) {
            activeRow = null;
        } else {
            activeRow = $row;
        }
    };

    function saveLabel($row) {
        console.log("Saving label");
        var value = $row.find('td.label-value').text();
        console.log("Saving value: " + $.trim(value));
    }

    // Attach click event listeners to each icon
    $('.save-label-button').click(function(event) {
        event.stopPropagation(); // Prevent row click event from firing
        toggleEdit(this); // Toggle the display of the icon
    });

    // Attach click event listeners to each edit icon
    $('.edit-label-button').click(function(event) {
        event.stopPropagation(); // Prevent row click event from firing
        toggleEdit(this);
    });

    // When an item is selected for editing, don't allow deselection
    // $(document.body).click(function(event) {
    //     console.log(event);
    //     console.log(event.target);
    //     console.log($(event.target).closest("#myTable").length);
    //     console.log($(event.target).hasClass("save-label-button"));
    //     if (!$(event.target).hasClass("save-label-button")) {
    //         if (activeRow !== null) {
    //             $(activeRow).find("td.label-value").attr("contenteditable", "true");
    //             $(activeRow).find(".save-label-button").show();
    //             $(activeRow).find("td.label-value").focus();
    //         }
    //     }
    // });
});
</asset:script>
</body>
</html>