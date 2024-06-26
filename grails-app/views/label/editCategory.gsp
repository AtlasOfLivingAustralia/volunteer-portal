<%@ page import="au.org.ala.volunteer.User" %>
<%@ page import="au.org.ala.volunteer.DateConstants" %>
<%@ page import="au.org.ala.volunteer.LabelColour" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}">
    <g:set var="entityName" value="${message(code: 'default.label.label', default: 'Tag')}"/>
    <g:set var="entityNamePlural" value="${message(code: 'default.label.plural.label', default: 'Tags')}"/>
    <title><g:message code="label.admin.editCategory.label" default="Edit Category"/></title>
    <style>
        .label-button {
            /*display: block;*/
            /*position: absolute;*/
            top: 0;
            right: 20px;
            padding: 4px 10px;
            text-align: center;
            cursor: pointer;
            float: right;
            font-size: 1.2em;
        }

        .btn {
            border-radius: 5px;
        }

        .save-label-button, .cancel-label-button {
            display: none;
        }

        .edit-label-button, .delete-label-button {
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
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')],
                [link: createLink(controller: 'label'), label: message(code: 'default.label.admin', default: 'Manage Tags')]

        ]
    %>
</cl:headerContent>

<div class="container" role="main">

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12" style="margin-left: 5px;">
                    <g:form controller="label" action="updateCategory" class="form-horizontal" method="POST">
                    <div class="form-group">
                        <label class="control-label col-md-2" for="name">
                            Category Name:
                        </label>
                        <div class="col-md-4" style="vertical-align: middle;">
                            <g:set var="isProtected" value="${(loadedDefaultLabels && labelCategory.isDefault)}"/>
                            <input class="form-control" id="name" name="name" type="text"
                                   placeholder="Enter the category name"
                                   value="${labelCategory.name}"
                                   ${(isProtected ? "disabled='disabled'" : '')} required/>
                            <input type="hidden" name="categoryId" value="${labelCategory.id}"/>
                        </div>
                    </div>
                        <div class="form-group">
                            <label class="control-label col-md-2" for="name">
                                Tag Colour:
                            </label>
                            <div class="col-md-4" style="vertical-align: middle;">
                                <g:select name="labelColour" id="label-colour"
                                          class="form-control"
                                          from="${LabelColour.values()}"
                                          keys="${LabelColour.values()*.name()}"
                                          required=""
                                          noSelection="['':'- Select a Tag Colour -']"
                                          value="${labelCategory?.labelColour}"/>
                            </div>
                            <div class="control-label col-md-1" id="example-tag-display">
                                <g:set var="labelColourClass" value="${(!labelCategory.labelColour ? 'base' : labelCategory.labelColour)}"/>
                                <span class="label label-${labelColourClass}" id="example-tag">Example Tag</span>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-4">
                                <input type="submit" class="save btn btn-primary" id="addButton"
                                       value="${message(code: 'default.button.add.label', default: 'Save')}"/>
                            </div>
                        </div>
                    </g:form>
                </div>
            </div>

            <g:if test="${isProtected}">
            <div class="row">
                <div class="col-md-12" style="margin-top: 20px;margin-left: 5px;">
                    <i>* This category is a default, system-loaded category. It and default tags are not editable. You may add to the existing tags however.</i>
                </div>
            </div>
            </g:if>


            <div class="row">
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-body">
            <h4>${labelCategory.name} ${entityNamePlural}</h4>

            <div class="row">
                <div class="col-md-12" style="margin-left: 5px;">
                    <g:form controller="label" action="saveNewLabel" class="form-horizontal" method="POST">
                        <div class="form-group">
                            <label class="control-label col-md-2" for="value">
                                Add ${entityName}:
                            </label>
                            <div class="col-md-4">
                                <input class="form-control" id="value" name="value" type="text"
                                       placeholder="Enter the ${entityName} name"
                                       required/>
                                <input type="hidden" name="categoryId" value="${labelCategory.id}"/>
                            </div>
                            <input type="submit" class="save btn btn-primary" id="addLabelButton"
                                   value="${message(code: 'default.button.add.label', default: 'Add')}"/>
                        </div>
                    </g:form>
                </div>
            </div>

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
                                <th>Last Updated</th>
                                <th>Created By</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <g:each in="${labelCategory.labels.sort { a, b -> a.value <=> b.value }}" status="i" var="label">
                            <tr class="${(i % 2) == 0 ? 'even' : 'odd'} label-data">
                                <td style="vertical-align: middle;" class="label-value col-md-6" data-label-id="${label.id}">
                                    ${label.value}
                                </td>
                                <td style="vertical-align: middle;" class="col-md-2">
                                    ${formatDate(date: label.updatedDate, format: DateConstants.DATE_TIME_FORMAT)}
                                </td>
                                <td style="vertical-align: middle;" class="col-md-2">
                                    ${User.get(label.createdBy)?.displayName ?: 'System'}
                                </td>
                                <td class="col-md-2" style="text-align: center;">
                                    <g:set var="isEditable" value="${(!isProtected || (isProtected && !label.isDefault))}"/>
                                    <g:if test="${(isEditable)}">
                                        <i class="fa fa-times label-button cancel-label-button" contenteditable="false"
                                           title="${message(code: 'default.button.cancel.label', default: 'Cancel')}"></i>
                                        <i class="fa fa-save label-button save-label-button" contenteditable="false"
                                           title="${message(code: 'default.button.add.label', default: 'Save')}"></i>

                                        <i class="fa fa-trash label-button delete-label-button" contenteditable="false"
                                           data-href="${createLink(controller: 'label', action: 'deleteLabel', id: label.id)}"
                                           title="${message(code: 'default.button.delete.label', default: 'Delete')}"></i>
                                        <i class="fa fa-pencil label-button edit-label-button" contenteditable="false"
                                           title="${message(code: 'default.button.edit.label', default: 'Edit')}"></i>

                                        <i class="fa fa-share-square-o label-button change-cat-button"
                                           data-label-name="${label.value}"
                                           data-label-id="${label.id}"
                                           contenteditable="false"
                                           title="${message(code: 'label.changecat.label', default: 'Move to a different Category')}"></i>
                                    </g:if>
                                    <i class="fa fa-tags label-button view-tags-button"
                                       data-label-name="${label.value}"
                                       data-label-id="${label.id}"
                                       contenteditable="false"
                                       title="${message(code: 'label.viewtags.label', default: 'View Tag Usage')}"></i>
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

<!-- View Tags Modal -->
<div class="modal fade" id="view-labels-modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4>${message(code: 'default.label.label', default: 'Tag')} Usage for: '<span id="view-label-name"></span>'</h4>
            </div>
            <div class="modal-body">
                <div id="view-label-list"></div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-default" id="btn-close-view-labels">OK</button>
            </div>
        </div>
    </div>
</div>

<!-- Change Category Modal -->
<div class="modal fade" id="change-cat-modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4>Change ${message(code: 'default.label.label', default: 'Tag')} Category: '<span id="change-cat-label-name"></span>'</h4>
            </div>
            <div class="modal-body">
                <div class="row">
                    <p>Select the new category for this ${message(code: 'default.label.label', default: 'Tag')}.</p>
                    <div class="col-md-12" style="margin-left: 5px;">
                        <div class="form-group">
                            <label class="control-label col-md-4" for="newCategory">
                                New Category:
                            </label>
                            <div class="col-md-8" style="vertical-align: middle;">
                                <g:set var="categoryFilterList" value="${categoryList.findAll{it.id != labelCategory.id}}"/>
                                <g:select name="newCategory"
                                          class="form-control"
                                          from="${categoryFilterList}"
                                          optionKey="id"
                                          optionValue="name"
                                          noSelection="[0:'- Select a new Category -']"/>
                                <input type="hidden" name="changeCatLabelId" id="cat-change-label-id" value=""/>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-default" id="btn-save-change-cat">Save</button>
                <button class="btn btn-default" id="btn-close-change-cat">Cancel</button>
            </div>
        </div>
    </div>
</div>

<asset:script type="text/javascript">
$(function($) {
    var activeRow = null;
    var valueBackup = "";

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

    /**
    * Updates the data attr with new label name. Assumes ele is the row/parent element and searches for the
    * buttons as children.
    * @param ele the parent element
    * @param newLabelName the new label name.
    */
    function updateLabel(ele, newLabelName) {
        var changeCatButton = $(ele).find('.change-cat-button');
        if (changeCatButton.length > 0) {
            $(changeCatButton).attr('data-label-name', newLabelName);
        }

        var viewTagsButton = $(ele).find('.view-tags-button');
        if (viewTagsButton.length > 0) {
            $(viewTagsButton).attr('data-label-name', newLabelName);
        }
    }

    $(".change-cat-button").click(function() {
        var labelName = $(this).data('label-name');
        var labelId = $(this).data('label-id');
        //console.log("LabelID: " + labelId);
        $('#change-cat-label-name').text(labelName);
        $('#cat-change-label-id').val(labelId);
        //console.log("Setting hidden field to " + $('#cat-change-label-id').val());
        $( "#change-cat-modal" ).modal( "show" );
    });

    $("#btn-close-change-cat").click(function() {
        $( "#change-cat-modal" ).modal( "hide" );
    });

    $("#btn-save-change-cat").click(function() {
        // Save change category.
        //console.log("saving category change");
        var labelId = $('#cat-change-label-id').val();
        var newCategory = $('#newCategory').val();
        //console.log("Label ID: " + labelId + ", newCategory: " + newCategory);
        if (labelId !== undefined && newCategory !== undefined) {
            var href = "${createLink(controller: 'label', action: 'changeCategory')}?labelId=" + labelId + "&newCategory=" + newCategory;
            $.postGo(href);
        }
    });

    $(".view-tags-button").click(function(e) {
        e.preventDefault();
        var labelName = $(this).data('label-name');
        var labelId = $(this).data('label-id');
        var href = "${createLink(controller: 'label', action: 'labelUsage')}?id=" + labelId;
        $('#view-label-name').html(labelName);
        $('#view-label-list').html("<i class='fa fa-spinner fa-pulse fa-3x fa-fw'></i><span class='sr-only'>Loading...</span>");

        $.get(href, function(data) {
            var $div = $('<div>');
            if (data.projects !== undefined && data.projects.length > 0) {
                $div.append('<h4>Projects ('+ data.projects.length +'):</h4>');
                var $ul = $('<ul>');
                $.each(data.projects, function(index, project) {
                    if (index > 100) {
                        var $li = $('<li>').text((data.projects.length - index) + ' more.');
                        $ul.append($li);
                        return false;
                    }
                    var $li = $('<li>').text(project.name);
                    $ul.append($li);
                });
                $div.append($ul);
            }

            if (data.landingPages !== undefined && data.landingPages.length > 0) {
                $div.append('<h4>Landing Pages ('+ data.landingPages.length +'):</h4>');
                var $ul = $('<ul>');
                $.each(data.landingPages, function(index, page) {
                    var $li = $('<li>').text(page.name);
                    $ul.append($li);
                });
                $div.append($ul);
            }

            $('#view-label-list').html($div);
        }).fail(function(jqXHR, textStatus) {
            $('#view-label-list').html("No entities found.");
            //console.log(jqXHR);
        });

        $( "#view-labels-modal" ).modal( "show" );
    });

    $("#btn-close-view-labels").click(function(e) {
        e.preventDefault();
        $( "#view-labels-modal" ).modal( "hide" );
    });

    // Attach click event listeners to each row
    /**
     * Toggles the editable nature of the tag value.
     * @param ele the element where the event originated (e.g. button).
     */
    function toggleEdit(ele) {
        var $row = $(ele).closest('tr.label-data');

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

                if ($(ele).hasClass("save-label-button")) {
                    //console.log("Save button clicked");
                    saveLabel($row);
                } else if ($(ele).hasClass("cancel-label-button")) {
                    //console.log("Cancel button clicked");
                    $(this).html(valueBackup);
                }
            } else {
                // Edit icon clicked
                var value = $.trim($(this).text());
                //console.log("Old value: " + value);
                valueBackup = value;
                $(this).attr('contenteditable', 'true');
                $(this).addClass('focus');
                $(this).focus();
                document.execCommand('selectAll', false, null);
            }
        });

        toggleButtons($row);

        // Update the activeRow
        if ($row.find('.save-label-button').is(':hidden')) {
            activeRow = null;
        } else {
            activeRow = $row;
        }
    }

    /**
     * Toggles the buttons from hidden to visible and vice versa.
     * @param $row The row to perform the toggle.
     */
    function toggleButtons($row) {
        // Toggle icon display
        //$row.find('.label-button').toggle();
        $row.find('.save-label-button').toggle();
        $row.find('.edit-label-button').toggle();
        $row.find('.cancel-label-button').toggle();
        $row.find('.delete-label-button').toggle();
    }

    /**
     * Saves the value for the tag to the database.
     * @param $row The label row to save.
     */
    function saveLabel($row) {
        //console.log("Saving label");
        var td = $row.find('td.label-value');
        var value = $(td).text();
        var id = $(td).data('label-id');
        //console.log("Saving value: " + $.trim(value));
        //console.log("ID: " + id);
        const url = "${createLink(controller: 'label', action: 'saveLabel')}";
        var data = {
            labelName: $.trim(value),
            id: id
        }
        $.post(url, data)
        .done(function (data, status, xhr) {
            updateLabel($row, $.trim(value));
        })
        .fail(function(xhr, status, error) {
           //console.log("Couldn't delete tasks", status, error);
           alert("Error saving label. Please try again later.");
        });
    }

    $('td.label-value').keypress(function(event) {
        //console.log("keypress");
        var keycode = event.charCode || event.keyCode;
        if (keycode === 10 || keycode === 13) { // Enter key's keycode
            event.preventDefault();
            //console.log("Enter pressed");
            var saveButton = $(this).closest('tr').find('.save-label-button');
            if (saveButton.length > 0) {
                saveButton.trigger('click');
            }
        }
    });

    // Attach click event listeners to each icon
    $('.save-label-button').click(function(event) {
        //console.log("Save button clicked");
        event.stopPropagation(); // Prevent row click event from firing
        toggleEdit(this); // Toggle the display of the icon
    });

    // Attach click event listeners to each edit icon
    $('.edit-label-button').click(function(event) {
        event.stopPropagation(); // Prevent row click event from firing
        toggleEdit(this);
    });

    $('.cancel-label-button').click(function(event) {
        event.stopPropagation(); // Prevent row click event from firing
        //console.log('Cancel button clicked');
        toggleEdit(this);
    });

    $('.delete-label-button').click(function(event) {
        event.stopPropagation(); // Prevent row click event from firing
        //console.log('Delete button clicked');
        var $this = $(this);
        var href = $this.data('href');
        //console.log("href: " + href);

        bootbox.confirm("Are you sure you wish to delete this label? This action is permanent!", function(result) {
            if (result) {
                $.postGo(href);
                toggleEdit(this);
            }
        });
    });

    $('#label-colour').on('change', function() {
        var colourValue = $(this).val();
        var newLabelColour = "label-" + colourValue;
        $('#example-tag').removeClass().addClass("label " + newLabelColour);
    });

});
</asset:script>
</body>
</html>