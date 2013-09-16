<%@ page import="au.org.ala.volunteer.FieldDefinitionType; au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <r:require module="jquery-ui" />
        <style type="text/css">

        .bvp-expeditions td button {
            margin-top: 5px;
        }

        .bvp-expeditions th {
            text-align: left;
        }

        .bvp-expeditions tbody tr td table {
            margin: 0px;
        }


        .bvp-expeditions tbody tr td table tr td {
            vertical-align: top;
            border-bottom: none;
            padding: 2px;
        }

        .bvp-expeditions tbody tr td table tr td button {
            margin-top: 0px;
        }

        table.bvp-expeditions .btn img, .imageButton {
            padding-left: 0;

        }

        .imageButton {
            margin: 2px;
        }

        .section h4 {
            margin-bottom: 5px;
        }

        #buttonBar {
            margin-bottom: 6px;
        }

        </style>
        <r:script>

            $(document).ready(function() {

                $(".btnMoveFieldUp").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr('fieldId');
                    if (fieldId) {
                        window.location = "${createLink(controller: 'template', action:'moveFieldUp')}?fieldId=" + fieldId;
                    }
                });

                $(".btnMoveFieldDown").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr('fieldId');
                    if (fieldId) {
                        window.location = "${createLink(controller: 'template', action:'moveFieldDown')}?fieldId=" + fieldId;
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
                    window.location = "${createLink(controller:'template', action:'moveFieldToPosition', id:templateInstance.id)}?fieldId=" + fieldId + "&newOrder=" + newPosition
                });

                $( "#dialog" ).dialog({
                    minHeight: 200,
                    minWidth: 400,
                    resizable: false,
                    autoOpen: false
                });

                $("#btnCleanUpOrdering").click(function(e) {
                    e.preventDefault();
                    window.location = "${createLink(controller:'template', action:'cleanUpOrdering', id:templateInstance.id)}";
                });

                $("#btnAddField").click(function(e) {
                    e.preventDefault();
                    var fieldType = encodeURIComponent($("#fieldName").val());
                    if (fieldType) {
                        window.location = "${createLink(controller:'template', action:'addField', id:templateInstance.id)}?fieldType=" + fieldType;
                    }
                });

                $(".btnDeleteField").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr("fieldId");
                    if (fieldId) {
                        if (confirm("Are you sure you wish to delete this field from the template?")) {
                            window.location = "${createLink(controller:'template', action:'deleteField', id: templateInstance.id)}?fieldId=" + fieldId;
                        }
                    }
                });

                $(".btnEditField").click(function(e) {
                    e.preventDefault();
                    var fieldId = $(this).parents("[fieldId]").attr("fieldId");
                    if (fieldId) {
                        window.location = "${createLink(controller:'templateField', action:'edit')}/" + fieldId;
                    }
                });

                $("#btnPreviewTemplate").click(function(e) {
                    e.preventDefault();
                    window.open("${createLink(controller:'template', action:'preview', id:templateInstance.id)}", "TemplatePreview");
                });

                $("#btnExportAsCSV").click(function(e) {
                    e.preventDefault();
                    window.open("${createLink(controller:'template', action:'exportFieldsAsCSV', id:templateInstance.id)}", "CSVExport");
                });

                    // Context sensitive help popups
                $("a.fieldHelp").qtip({
                    tip: true,
                    position: {
                        corner: { target: 'topMiddle', tooltip: 'bottomRight' }
                    },
                    style: {
                        width: 400,
                        padding: 8,
                        background: 'white', //'#f0f0f0',
                        color: 'black',
                        textAlign: 'left',
                        border: { width: 4, radius: 5, color: '#E66542' },
                        tip: 'bottomRight',
                        name: 'light' // Inherit the rest of the attributes from the preset light style
                    }
                }).bind('click', function(e) { e.preventDefault(); return false; });

            });

        </r:script>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.manageTemplateFields.label', default: 'Manage Template Fields')} - ${templateInstance.name}">
           <%
               pageScope.crumbs = [
                   [link: createLink(controller: 'admin', action: 'index'), label: 'Administration'],
                   [link: createLink(controller: 'template', action: 'list'), label: message(code: 'default.list.label', args: ['Template'])],
                   [link: createLink(controller: 'template', action: 'edit', id: templateInstance.id), label: message(code: 'default.edit.label', args: ['Template'])]
               ]
           %>
        </cl:headerContent>

        <div class="row">
            <div class="span12">
                <div id="buttonBar">
                    <button class="btn" id="btnCleanUpOrdering">Clean up ordering</button>
                    Field Type:
                    <g:select name="fieldName" from="${au.org.ala.volunteer.DarwinCoreField.values().sort({ it.name() })}"/>
                    <button class="btn" id="btnAddField">Add field</button>
                    <button class="btn" id="btnPreviewTemplate">Preview Template</button>
                    <button class="btn" id="btnExportAsCSV">Export as CSV</button>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="span12">
                <table class="table table-striped table-bordered">
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
                                <td><a href="${createLink(controller: 'templateField', action:'edit', id:field.id)}"><strong>${field.fieldType}</strong></a></td>
                                <td>${field.type}</td>
                                <td>${field.label}</td>
                                <td>${field.layoutClass}</td>
                                <td>${field.validationRule}</td>
                                <td>${field.category}</td>
                                <td>
                                    <g:if test="${field.helpText}">
                                        <a href="#" class="fieldHelp" title="${field.helpText}"><span class="help-container">&nbsp;</span></a>
                                    </g:if>
                                </td>
                                <td style="padding:0; width:180px">
                                    <button class="btn btn-mini btnMoveFieldDown"><i class="icon-arrow-down"></i></button>
                                    <button class="btn btn-mini btnMoveFieldUp"><i class="icon-arrow-up"></i></button>
                                    <button class="btn btn-mini btnMoveFieldAnywhere"><i class="icon-move"></i></button>
                                    <button class="btn btn-mini btnDeleteField btn-danger"><i class="icon-remove icon-white"></i></button>
                                    <button class="btn btn-mini btnEditField imageButton"><i class="icon-edit"></i></button>
                                </td>
                            </tr>
                        </g:each>
                    </tbody>
                </table>
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

    </body>
</html>
