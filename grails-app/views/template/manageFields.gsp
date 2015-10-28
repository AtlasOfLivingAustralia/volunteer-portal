<%@ page import="au.org.ala.volunteer.FieldDefinitionType; au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.label" default="Administration"/></title>
    <r:require modules="jquery-ui, bootbox, bootstrap-file-input, qtip, bvp-js"/>

    <r:script>

            $(document).ready(function() {

                $(".btnMoveFieldUp").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr('fieldId');
                    if (fieldId) {
                        window.location = "${createLink(controller: 'template', action: 'moveFieldUp')}?fieldId=" + fieldId;
                    }
                });

                $(".btnMoveFieldDown").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr('fieldId');
                    if (fieldId) {
                        window.location = "${createLink(controller: 'template', action: 'moveFieldDown')}?fieldId=" + fieldId;
                    }
                });

                $(".btnMoveFieldAnywhere").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr('fieldId');
                    if (fieldId) {
                        $("#oldPosition").val($(this).parents("[fieldOrder]").attr("fieldOrder"));
                        $("#dialogFieldId").val(fieldId);
                        $("#dialog").dialog( "open" );
                    }
                });

                $("#btnCancelMove").click(function(e) {
                    e.preventDefault();
                    $("#dialog").dialog( "close" );
                });

                $("#btnApplyMove").click(function(e) {
                    e.preventDefault();
                    var fieldId = $("#dialogFieldId").val();
                    var newPosition = $("#newPosition").val();
                    window.location = "${createLink(controller: 'template', action: 'moveFieldToPosition', id: templateInstance.id)}?fieldId=" + fieldId + "&newOrder=" + newPosition
                });

                $( "#dialog" ).dialog({
                    minHeight: 200,
                    minWidth: 400,
                    resizable: false,
                    autoOpen: false
                });

                $("#btnCleanUpOrdering").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller: 'template', action: 'cleanUpOrdering', id: templateInstance.id)}";
                });

                $("#btnAddField").click(function(e) {
                    e.preventDefault();
                    var options = {
                        title:"Add field to template",
                        url:"${createLink(action: 'addTemplateFieldFragment', id: templateInstance.id)}",
                        onClose : function() { }
                    };

                    bvp.showModal(options);
                });

                $(".btnDeleteField").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr("fieldId");
                    if (fieldId) {
                        if (confirm("Are you sure you wish to delete this field from the template?")) {
                            window.location = "${createLink(controller: 'template', action: 'deleteField', id: templateInstance.id)}?fieldId=" + fieldId;
                        }
                    }
                });

                $(".btnEditField").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr("fieldId");
                    if (fieldId) {
                        window.location = "${createLink(controller: 'templateField', action: 'edit')}/" + fieldId;
                    }
                });

                $("#btnPreviewTemplate").click(function(e) {
                    e.preventDefault();
                    window.open("${createLink(controller: 'template', action: 'preview', id: templateInstance.id)}", "TemplatePreview");
                });

                $("#btnExportAsCSV").click(function(e) {
                    e.preventDefault();
                    window.open("${createLink(controller: 'template', action: 'exportFieldsAsCSV', id: templateInstance.id)}", "CSVExport");
                });

                $("#btnImportFromCSV").click(function(e) {
                    e.preventDefault();
                    if (confirm("This will remove all existing fields, and replace them with the contents of the selected file. Are you sure?")) {
                        $("form").submit();
                    }
                });

                // Context sensitive help popups
                $("a.fieldHelp").each(function() {
                var self = this;
                    $(self).qtip({
                        content: $(self).attr('title'),
                        position: {
                            at: "top left",
                            my: "bottom right"
                        },
                        style: {
                            classes: 'qtip-bootstrap'
                        }
                    }).bind('click', function(e) { e.preventDefault(); return false; });
                });

                // Initialize input type file
                $('input[type=file]').bootstrapFileInput();

            });

    </r:script>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent
            title="${message(code: 'default.manageTemplateFields.label', default: 'Manage Template Fields')} - ${templateInstance.name}"  selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                    [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: ['Template'])],
                    [link: createLink(controller: 'template', action: 'edit', id: templateInstance.id), label: message(code: 'default.edit.label', args: ['Template'])]
            ]
        %>
    </cl:headerContent>

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <g:uploadForm action="importFieldsFromCSV" controller="template">
                    <g:hiddenField name="id" value="${templateInstance.id}"/>
                    <div class="col-md-6">
                        <button class="btn btn-success" id="btnAddField">
                            <i class="icon-plus icon-white"></i>&nbsp;Add field
                        </button>
                        <button class="btn btn-default" id="btnCleanUpOrdering">Clean up ordering</button>
                        <button class="btn btn-default" id="btnPreviewTemplate">Preview Template</button>
                        <button class="btn btn-default" id="btnExportAsCSV">Export as CSV</button>
                    </div>
                    <div class="col-md-6">
                        <input type="file" data-filename-placement="inside" name="uploadFile"/>
                        <button class="btn btn-success" id="btnImportFromCSV">Import from CSV</button>
                    </div>
                </g:uploadForm>
            </div>


            <div class="row">
                <div class="col-md-12">
                    <table class="table table-striped table-hover template-fields">
                        <thead>
                        <tr>
                            <th>Order</th>
                            <th>DwC Field</th>
                            <th>Form type</th>
                            <th>Label</th>
                            <th>Layout Class</th>
                            <th>Validation</th>
                            <th>Category</th>
                            <th>Help text</th>
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>

                        <g:each in="${fields}" var="field">
                            <tr fieldId="${field.id}" fieldOrder="${field.displayOrder}">
                                <td>${field.displayOrder}</td>
                                <td><a href="${createLink(controller: 'templateField', action: 'edit', id: field.id)}"><strong>${field.fieldType} (${field.fieldTypeClassifier})</strong>
                                </a></td>
                                <td>${field.type}</td>
                                <td>${field.label}</td>
                                <td>${field.layoutClass}</td>
                                <td>${field.validationRule}</td>
                                <td>${field.category}</td>
                                <td class="text-center">
                                    <g:if test="${field.helpText}">
                                        <a href="#" class="btn btn-default btn-xs fieldHelp"
                                           title="<markdown:renderHtml>${field.helpText}</markdown:renderHtml>"><span
                                                class="help-container"><i class="fa fa-question"></i> </span></a>
                                    </g:if>
                                </td>
                                <td class="text-center">
                                    <button class="btn btn-xs btn-default btnMoveFieldDown"><i class="fa fa-arrow-down"></i></button>
                                    <button class="btn btn-xs btn-default btnMoveFieldUp"><i class="fa fa-arrow-up"></i></button>
                                    <button class="btn btn-xs btn-default btnMoveFieldAnywhere"><i class="fa fa-arrows"></i></button>
                                    <button class="btn btn-xs btnDeleteField btn-danger"><i class="fa fa-times"></i>
                                    </button>
                                    <button class="btn btn-xs btn-default btnEditField imageButton"><i class="fa fa-pencil"></i></button>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div id="dialog" title="Move field to position" style="display: none">
        <g:hiddenField name="dialogFieldId" id="dialogFieldId"/>
        <table style="width: 100%">
            <tr>
                <td><strong>Old&nbsp;position:</strong></td>
                <td><g:textField name="oldPosition" id="oldPosition" disabled="true" size="10"/></td>
            </tr>
            <tr>
                <td><strong>New&nbsp;position (Order):</strong></td>
                <td><g:textField name="newPosition" id="newPosition" size="10"/></td>
            </tr>
        </table>

        <div style="margin-top: 15px">
            <button class="btn" id="btnCancelMove">Cancel</button>
            <button class="btn" id="btnApplyMove">Move Field</button>
        </div>
    </div>
</div>
</body>
</html>
