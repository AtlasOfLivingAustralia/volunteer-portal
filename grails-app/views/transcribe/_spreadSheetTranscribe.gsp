<%@ page import="au.org.ala.volunteer.FieldType; groovy.json.StringEscapeUtils; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<%@ page import="au.org.ala.volunteer.PicklistService" %>
<%
    PicklistService picklistService = grailsApplication.classLoader.loadClass('au.org.ala.volunteer.PicklistService').newInstance()
%>

<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<r:require modules="slickgrid, underscore"/>

<g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.sightingCount, template)}"/>

<g:if test="${!entriesField}">
    <div class="alert alert-danger">
        You need to define the sightingCount field in this template to hold the number rows in the grid
    </div>
</g:if>

<g:set var="fieldList"
       value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort: 'displayOrder'])}"/>

<g:hiddenField name="recordValues.0.${entriesField?.fieldType}" id="recordValues.0.${entriesField?.fieldType}"
               value="${recordValues?.get(0)?.get(entriesField?.fieldType?.name()) ?: entriesField?.defaultValue ?: 0}"/>
<g:set var="numItems"
       value="${(recordValues?.get(0)?.get(entriesField?.fieldType?.name()) ?: entriesField?.defaultValue ?: "0").toInteger()}"/>

<style>

#dataGrid, #dataGrid div {
    -webkit-box-sizing: content-box;
    -moz-box-sizing: content-box;
    box-sizing: content-box;
}

.slick-cell {
    padding: 0;
}

.slick-cell.invalid input[type='text'], .slick-cell.invalid select {
    background: #ff4500;
}

.slick-cell.editable {
    border-color: silver;
}

.slick-cell input[type='text'], .slick-cell select {
    padding: 0;
    margin: 0;
    min-height: 22px;
    box-shadow: none;
    border-radius: 0;
    color: #000000;
    font-size: 1em;
    width: 99%;
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

.checkbox-cell {
    text-align: center;
}

</style>


<div class="row">
    <div class="col-md-12">
        <div>
            <g:set var="multimedia" value="${taskInstance.multimedia.first()}"/>
            <g:imageViewer multimedia="${multimedia}"/>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <div class="well well-sm transcribeSection" style="margin-top: 10px">
            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${template.viewParams?.datasetSectionHeader ?: 'Specimen details'}</span>

            <div class="row" style="margin-top: 10px">
                <div class="col-md-12">
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
                <g:set var="fieldLabel"
                       value="${StringEscapeUtils.escapeJavaScript(field.label ?: field.fieldType.label)}"/>
                <g:set var="fieldName" value="${field.fieldType.name()}"/>
                <g:set var="fieldValue"
                       value="${recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')}"/>
                <input type="text" name="recordValues.${i}.${fieldName}" value="${fieldValue}"
                       id="recordValues.${i}.${fieldName}"/>
            </g:each>
        </div>
    </g:each>
</div>

<r:script>

    var spreadsheetDataView = null;
    var grid = null;
    var fieldList = <cl:json value="${fieldList}"/>;


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

    <%
        // Maps a field type to a SlickGrid editor closure reference
        def editorExpr = { FieldType fieldType, long taskId, DarwinCoreField darwinCoreField ->
            switch (fieldType) {
                case FieldType.textarea:
                    return "Slick.Editors.LongText"
                case FieldType.date:
                    return "BVP.SlickGrid.Date"
                case FieldType.autocomplete:
                    return "BVP.SlickGrid.Autocomplete(${taskId}, '${darwinCoreField.toString()}')"
                case FieldType.checkbox:
                    return "BVP.SlickGrid.Checkbox"
                case FieldType.select:
                    def items = picklistService.getPicklistItemsForProject(darwinCoreField, taskInstance.project)
                    def options = items.collect { '"' + StringEscapeUtils.escapeJavaScript(it.value) + '"' }
                    return "BVP.SlickGrid.Select([${options.join(',')}])"
                default:
                    return "Slick.Editors.Text"
            }
        }
    %>

    var makeValidator = function(ruleName) {

        if (ruleName) {

            return function(value) {

                var rule = transcribeValidation.rules[ruleName];
                console.log(rule);
                if (rule) {
                    var element = $(grid.getActiveCellNode()).find("input, select");
                    var result = rule.test(value, element);
                    var message = "";

                    if (!result) {
                        var messageSource = rule.message;
                        if (messageSource) {
                            if (typeof(messageSource) === 'string') {
                                message = messageSource;
                            } else if (typeof(messageSource) === 'function') {
                                message = messageSource(element);
                            }
                        }
                    }
                    element.attr("title", message);
                    return {
                        valid: result,
                        msg: message
                    }
                }

                // Default case, no rule
                return {
                    valid: true,
                    msg: ""
                }
            }
        }
        return null;
    };

    var columns = [
        {id: 'id', name:'', field:'id', focusable: false, cssClass: 'fixed-column', maxWidth: 35, formatter: fixedColumnFormatter },
    <g:each in="${fieldList}" var="field" status="fieldIndex">
        <g:set var="fieldLabel" value="${StringEscapeUtils.escapeJavaScript(field.label ?: field.fieldType.label)}"/>
        <g:set var="fieldName" value="${field.fieldType.name()}"/>
        <g:set var="fieldValue"
               value="${StringEscapeUtils.escapeJavaScript(recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')?.replaceAll('\\\\', '\\\\\\\\'))}"/>
        <g:set var="fieldHelpText" value="${StringEscapeUtils.escapeJavaScript(field.helpText)}"/>
        <g:set var="slickEditor" value="${editorExpr(field.type, taskInstance?.id ?: -1, field.fieldType)}"/>
        <g:set var="validationRuleName" value="${field.validationRule}"/>
        <g:set var="formatter" value=""/>
        <g:set var="cssClass" value=""/>
        <g:if test="${field.type == FieldType.checkbox}">
            <g:set var="formatter" value="BVP.SlickGrid.Checkmark"/>
            <g:set var="cssClass" value="checkbox-cell"/>
        </g:if>
        {'id':'${fieldName}', 'name':'${fieldLabel}', 'field':'${fieldName}', editor: ${slickEditor}, validator: makeValidator('${validationRuleName}'), formatter: ${formatter ?: 'null'}, cssClass: "${cssClass ?: ''}" }<g:if
            test="${fieldIndex < fieldList.size() - 1}">,</g:if>
    </g:each>
    ];

    var options = {
        editable: true,
        enableCellNavigation: true,
        enableColumnReorder: false,
        enableAddRow: true,
        autoEdit: true,
        syncColumnCellResize: true
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
    item.id = "" + dataView.getLength();
    dataView.addItem(item);
});

spreadsheetDataView = dataView;

return grid
}


// Gets called just before validation occurs. This gives us a chance to construct the form fields from the spreadsheet data...
transcribeWidgets.addBeforeSubmitHook(function() {

grid.getEditController().commitCurrentEdit();

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
            $("#spreadsheet-form-fields").append("<input type='text' name='" + elementId + "' id='" + elementId + "' value='" +  value + "'/>");
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

        return true;
    });

    function createDataItemsFromInputs() {
        var grid_data = [];
        var rows = $("#spreadsheet-form-fields").find("input[id^='recordValues.']");
        var dataView = grid.getData();

        var items = {};

        rows.each(function() {
            var $this = $(this);
            var id = $this.attr('id');
            var fieldNameIdx = id.lastIndexOf('.');
            var recordIdxIdx = id.indexOf('.');
            var fieldName = id.substring(fieldNameIdx+1);
            var recordIdx = parseInt(id.substring(recordIdxIdx+1, fieldNameIdx));
            var obj = grid_data[recordIdx];
            if (!obj) {
              obj = { id: recordIdx };
              grid_data[recordIdx] = obj;
            }
            obj[fieldName] = $this.val();
        });

        dataView.setItems(grid_data);

        grid.invalidate();
    }

    // recreate the initial form and then rerun the data items from said form.
    var recoverFunction = function(lastState) {
      var $spreadsheetFields = $("#spreadsheet-form-fields");
      $spreadsheetFields.empty();
      _.each(lastState.fields, function(v,i) {
        var id = v.id;
        var value = v.value;
        $spreadsheetFields.append("<input type='text' name='" + id + "' id='" + id + "' value='" +  value + "'/>");
      });
      createDataItemsFromInputs();
    }
</r:script>