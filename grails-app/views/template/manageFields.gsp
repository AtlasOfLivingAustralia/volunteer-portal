<%@ page import="au.org.ala.volunteer.FieldDefinitionType; au.org.ala.volunteer.Project" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <title><g:message code="admin.label" default="Administration"/></title>
        <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.qtip-1.0.0-rc3.min.js')}"></script>
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
        <script type='text/javascript'>

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
                    minWidth: 300,
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

        </script>
    </head>

    <body class="sublevel sub-site volunteerportal">

        <cl:navbar/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <nav id="breadcrumb">
                    <ol>
                        <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
                        <li><a class="home" href="${createLink(controller: 'template', action: 'list')}">Templates</a>
                        <li><a class="home" href="${createLink(controller: 'template', action: 'edit', id: templateInstance.id)}">Edit ${templateInstance.name}</a></li>
                        <li class="last">Manage Template Fields</li>
                    </ol>
                </nav>
                <hgroup>
                    <h1>Template Fields - ${templateInstance.name}</h1>
                </hgroup>
            </div>
        </header>

        <div>
            <div class="inner">
                <div id="buttonBar">
                    <button class="button" id="btnCleanUpOrdering">Clean up ordering</button>
                    Field Type:
                    <g:select name="fieldName" from="${au.org.ala.volunteer.DarwinCoreField.values().sort({ it.name() })}"/>
                    <button class="button" id="btnAddField">Add field</button>
                    <button class="button" id="btnPreviewTemplate">Preview Template</button>
                    <button class="button" id="btnExportAsCSV">Export as CSV</button>
                </div>
                <table class="bvp-expeditions">
                    <thead>
                        <tr>
                            <th>Order</th>
                            <th>DwC Field</th>
                            <th>Form type</th>
                            <th>Label</th>
                            <th>Category</th>
                            <th>Help text</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>

                        <g:each in="${fields}" var="field">
                            <tr fieldId="${field.id}" fieldOrder="${field.displayOrder}">
                                <td>${field.displayOrder}</td>
                                <td><strong>${field.fieldType}</strong></td>
                                <td>${field.type}</td>
                                <td>${field.label}</td>
                                <td>${field.category}</td>
                                <td>
                                    <g:if test="${field.helpText}">
                                        <a href="#" class="fieldHelp" title="${field.helpText}"><span class="help-container">&nbsp;</span></a>
                                    </g:if>
                                </td>
                                <td style="padding:0; width:180px">
                                    <button class="button btnMoveFieldDown imageButton"><img src="${resource(dir:'/images', file:'down_arrow.png')}" title="Move this field down"></button>
                                    <button class="button btnMoveFieldUp imageButton"><img src="${resource(dir:'/images', file:'up_arrow.png')}" title="Move this field up"></button>
                                    <button class="button btnMoveFieldAnywhere imageButton"><img src="${resource(dir:'/images', file:'left_arrow.png')}" title="Move this to an arbitrary position"></button>
                                    <button class="button btnDeleteField imageButton"><img src="${resource(dir:'/images/skin', file:'database_delete.png')}" title="Delete this field"></button>
                                    <button class="button btnEditField imageButton"><img src="${resource(dir:'/images/skin', file:'database_edit.png')}" title="Edit this field"></button>
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
            <div>
                <button class="button" id="btnCancelMove">Cancel</button>
                <button class="button" id="btnApplyMove">Move Field</button>
            </div>
        </div>

    </body>
</html>
