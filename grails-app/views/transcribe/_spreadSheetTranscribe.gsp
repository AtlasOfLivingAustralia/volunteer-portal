<%@ page import="au.org.ala.volunteer.FieldType; groovy.json.StringEscapeUtils; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />
<r:require module="slickgrid" />

<g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.sightingCount, template)}"/>

<g:if test="${!entriesField}">
    <div class="alert alert-error">
        You need to define the sightingCount field in this template to hold the number rows in the grid
    </div>
</g:if>

<g:set var="fieldList" value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort:'displayOrder'])}" />

<g:hiddenField name="recordValues.0.${entriesField?.fieldType}" id="recordValues.0.${entriesField?.fieldType}" value="${recordValues?.get(0)?.get(entriesField?.fieldType?.name())?:entriesField?.defaultValue ?: 0}" />
<g:set var="numItems" value="${(recordValues?.get(0)?.get(entriesField?.fieldType?.name())?:entriesField?.defaultValue ?: "0").toInteger()}" />

<style>

    .slick-cell {
        padding: 0;
    }

    .slick-cell.editable {
        border-color: #F0F0E8;
    }

    .slick-cell input[type='text'] {
        padding: 0;
        margin: 0;
        min-height: 22px;
        box-shadow: none;
        border-radius: 0;
        color: #000000;
        font-size: 1em;
        width: 100%;
    }

    .fixed-column {
        background: #F0F0E8;
        text-align: right;
        color: #a9a9a9;
    }

    .slick-header-column {
        background: #E6E6DD;
        background-image: none;
    }

</style>


<div class="container-fluid">
    <div class="row-fluid">
        <div class="span12">
            <div>
                <g:set var="multimedia" value="${taskInstance.multimedia.first()}" />
                <g:imageViewer multimedia="${multimedia}" />
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <div class="well well-small transcribeSection" style="margin-top: 10px">
                <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${template.viewParams?.datasetSectionHeader ?: 'Specimen details' } </span>
                <div class="row-fluid" style="margin-top: 10px">
                    <div class="span12">
                        <div id="dataGrid" style="height: 300px"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="spreadsheet-form-fields" style="display: none">
        <g:each in="${0..numItems}" var="i">
            <div>
            <g:each in="${fieldList}" var="field" status="fieldIndex">
                <g:set var="fieldLabel" value="${StringEscapeUtils.escapeJavaScript(field.label?:field.fieldType.label)}"/>
                <g:set var="fieldName" value="${field.fieldType.name()}"/>
                <g:set var="fieldValue" value="${recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')}" />
                <input type="text" name="recordValues.${i}.${fieldName}" value="${fieldValue}" id="recordValues.${i}.${fieldName}" />
            </g:each>
            </div>
        </g:each>
    </div>

</div>

<r:script>

    var spreadsheetDataView = null;
    var grid = null;

    (function ($) {
        // register namespace
        $.extend(true, window, {
            "Slick": {
                "Editors": {
                    "BVPDate": BVPDateEditor
                }
            }
        });

        function BVPDateEditor(args) {
            var $input;
            var defaultValue;
            var scope = this;
            var calendarOpen = false;

            this.init = function () {
                $input = $("<INPUT type=text class='editor-text' />");
                $input.appendTo(args.container);
                $input.focus().select();
                $input.datepicker({
                    showOn: "button",
                    buttonImageOnly: true,
                    buttonImage: "../images/calendar.gif",
                    dateFormat: 'yy-mm-dd',
                    beforeShow: function () {
                        calendarOpen = true
                    },
                    onClose: function () {
                        calendarOpen = false
                    }
                });
                $input.width($input.width() - 20);
            };

            this.destroy = function () {
                $.datepicker.dpDiv.stop(true, true);
                $input.datepicker("hide");
                $input.datepicker("destroy");
                $input.remove();
            };

            this.show = function () {
                if (calendarOpen) {
                    $.datepicker.dpDiv.stop(true, true).show();
                }
            };

            this.hide = function () {
                if (calendarOpen) {
                    $.datepicker.dpDiv.stop(true, true).hide();
                }
            };

            this.position = function (position) {
                if (!calendarOpen) {
                    return;
                }
                $.datepicker.dpDiv.css("top", position.top + 30).css("left", position.left);
            };

            this.focus = function () {
                $input.focus();
            };

            this.loadValue = function (item) {
                defaultValue = item[args.column.field];
                $input.val(defaultValue);
                $input[0].defaultValue = defaultValue;
                $input.select();
            };

            this.serializeValue = function () {
                return $input.val();
            };

            this.applyValue = function (item, state) {
                item[args.column.field] = state;
            };

            this.isValueChanged = function () {
                return (!($input.val() == "" && defaultValue == null)) && ($input.val() != defaultValue);
            };

            this.validate = function () {
                return {
                    valid: true,
                    msg: null
                };
            };

            this.init();
        }
    })($);

    $(document).ready(function() {

        $(".tutorialLinks a").each(function(index, element) {
            $(this).addClass("btn").attr("target", "tutorialWindow");
        });

        grid = initGrid();

    });

    function initGrid() {
        var grid;
        var fixedColumnFormatter = function(row, col, data, colDef, dc) {
            return parseInt(data) + 1;
        };

        <g:set var="widgetMap" value="${[(FieldType.textarea):"Slick.Editors.LongText", (FieldType.date): "Slick.Editors.BVPDate"]}" />

        var columns = [
            {id: 'id', name:'', field:'id', focusable: false, cssClass: 'fixed-column', maxWidth: 35, formatter: fixedColumnFormatter },
            <g:each in="${fieldList}" var="field" status="fieldIndex">
                <g:set var="fieldLabel" value="${StringEscapeUtils.escapeJavaScript(field.label?:field.fieldType.label)}"/>
                <g:set var="fieldName" value="${field.fieldType.name()}"/>
                <g:set var="fieldValue" value="${StringEscapeUtils.escapeJavaScript(recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')?.replaceAll('\\\\', '\\\\\\\\'))}" />
                <g:set var="fieldHelpText" value="${StringEscapeUtils.escapeJavaScript(field.helpText)}" />
                <g:set var="slickEditor" value="${widgetMap[field.type] ?: 'Slick.Editors.Text'}" />
                {'id':'${fieldName}', 'name':'${fieldLabel}', 'field':'${fieldName}', editor: ${slickEditor} }<g:if test="${fieldIndex < fieldList.size()- 1 }">,</g:if>
            </g:each>
        ];

        var options = {
            editable: true,
            enableCellNavigation: true,
            enableColumnReorder: false,
            enableAddRow: true,
            autoEdit: true
        };

        var dataView = new Slick.Data.DataView();

        grid = new Slick.Grid("#dataGrid", dataView, columns, options);

        dataView.onRowCountChanged.subscribe(function (e, args) {
          grid.updateRowCount();
          grid.render();
        });

        dataView.onRowsChanged.subscribe(function (e, args) {
          grid.invalidateRows(args.rows);
          grid.render();
        });

        var grid_data = [];
        var initRowCount = ${numItems};

        for (var i = 0; i < initRowCount; i++) {
            var item = {id: i};
            <g:each in="${fieldList}" var="field" status="fieldIndex">
                <g:set var="fieldName" value="${field.fieldType.name()}"/>
                item.${fieldName} = $("#recordValues\\." + i + "\\.${fieldName}").val();
            </g:each>
            grid_data[i] = item;
        }

        dataView.setItems(grid_data);

        grid.autosizeColumns();

        grid.onAddNewRow.subscribe(function(event, args) {
            var item = args.item;
            item.id = "" + (dataView.getLength() + 1);
            dataView.addItem(item);
        });

        spreadsheetDataView = dataView;

        return grid
    }


    // Gets called just before validation occurs. This gives us a chance to construct the form fields from the spreadsheet data...
    var transcribeBeforeSubmit = function() {

        grid.getEditController().commitCurrentEdit()

        var forEachProperty = function(obj, f) {
            if (typeof(f) === 'function') {
                for (var propertyName in obj) {
                    if (propertyName != 'id' && obj.hasOwnProperty(propertyName)) {
                        f(propertyName, obj[propertyName]);
                    }
                }
            }
        };

        var renderItem = function(item) {
            forEachProperty(item, function(name, value) {
                var elementId = "recordValues." + item.id + "." + name;
                var selector = $("#recordValues\\." + item.id + "\\." + name);

                if (selector.length) {
                    selector.attr('value', value);
                } else {
                    $("#spreadsheet-form-fields").append("<input type='text' name='" + elementId + "' id='" + elementId + "' value='" +  value + "' />");
                }
            });
        };

        if (spreadsheetDataView) {
            var items = spreadsheetDataView.getItems();
            for (var i = 0; i < items.length; ++i) {
                var item = items[i];
                renderItem(item);
            }
            $("#recordValues\\.0\\.${entriesField?.fieldType}").attr('value', items.length);
        }

    }



</r:script>