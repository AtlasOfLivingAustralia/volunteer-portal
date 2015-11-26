<%@ page import="groovy.json.StringEscapeUtils" %>
<g:if test="${!entriesField}">
    <div class="alert alert-danger">
        No entriesField defined. Each template will require a specific field defined to capture the number of entries. Please consult with the <g:message
                code="default.application.name"/> team for more details.
    </div>
</g:if>

<g:hiddenField name="recordValues.0.${entriesField?.fieldType}" id="recordValues.0.${entriesField?.fieldType}"
               value="${recordValues?.get(0)?.get(entriesField?.fieldType?.name()) ?: entriesField?.defaultValue ?: 0}"/>
<g:set var="numItems"
       value="${(recordValues?.get(0)?.get(entriesField?.fieldType?.name()) ?: entriesField?.defaultValue ?: "0").toInteger()}"/>
<g:if test="${fieldList}">
    <div id="observationFields" entriesFieldId="recordValues.0.${entriesField?.fieldType}">
    </div>
    <button type="button" class="btn btn-small btn-success" id="btnAddRow"><i
            class="icon-plus icon-white"></i>&nbsp;Add&nbsp;Row</button>
</g:if>

<style type="text/css">

#btnAddRow {
    margin-top: 10px;
}


#observationFields hr {
    margin: 3px;
    border-top-color: #d3d3d3;
}

</style>

<r:script>
    var entries = [
    <g:each in="${0..numItems}" var="i">
    [
    <g:each in="${fieldList}" var="field" status="fieldIndex">
        <g:set var="fieldLabel" value="${StringEscapeUtils.escapeJavaScript(field.label ?: field.fieldType.label)}"/>
        <g:set var="fieldName" value="${field.fieldType.name()}"/>
        <g:set var="fieldValue"
               value="${StringEscapeUtils.escapeJavaScript(recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')?.replaceAll('\\\\', '\\\\\\\\'))}"/>
        <g:set var="fieldHelpText" value="${StringEscapeUtils.escapeJavaScript(field.helpText)}"/>
        {'name':'${fieldName}', 'label':'${fieldLabel}', 'fieldType':'${field.type?.toString()}', 'helpText': "${fieldHelpText}", 'value': "${fieldValue}", layoutClass:"${field.layoutClass ?: 'span1'}"}<g:if
            test="${fieldIndex < fieldList.size() - 1}">,</g:if>
    </g:each>
    ]<g:if test="${i < numItems}">,</g:if>
</g:each>
    ];

    function renderEntries() {
        try {
            var htmlStr ="";
            var itemCount = 0;
            for (entryIndex in entries) {
                if (entryIndex > 0) {
                  htmlStr += "<hr/>";
                }
                htmlStr += '<div class="form-inline">';
                var fieldCount = 0;
                for (fieldIndex in entries[entryIndex]) {
                    var e = entries[entryIndex][fieldIndex];
                    var name = "recordValues." + entryIndex + "." + e.name;
                    if (fieldIndex == 0) {
                      htmlStr += '<strong>' + (parseInt(entryIndex) + 1) + '.</strong>&nbsp;';
                    }

                    htmlStr += '<div class="form-group">';

                    htmlStr += '<label for="' + name + '">' + e.label;
                    if (e.helpText) {
                      htmlStr += '<a href="#" class="btn btn-default btn-xs fieldHelp" title="' + e.helpText + '" ' + (fieldCount == 0 ? 'tooltipPosition="bottomLeft" targetPosition="topRight"' : '') + '><i class="fa fa-question help-container"></i></a>';
                    }
                    htmlStr += '</label> ';

                    if (e.fieldType == 'textarea') {
                      htmlStr += '<textarea name="' + name + '" rows="2" id="' + name + '" class="' + e.name + ' form-control">' + e.value + '</textarea>';
                    } else {
                      htmlStr += '<input type="text" name="' + name + '" value="' + e.value + '" id="' + name + '" class="' + e.name + ' form-control"/>';
                    }

                    htmlStr += '</div> ';
                    fieldCount++;
                }
                if (entryIndex > 0) {
                htmlStr += '<button role="button" class="btn btn-xs btn-danger" onclick="deleteEntry(' + entryIndex + '); return false;"><span class="glyphicon glyphicon-remove glyphicon-white"></span> Delete </button>';
                }
                htmlStr += "</div>";
                itemCount++;
            }
            $("#observationFields").html(htmlStr);
            $("#recordValues\\.0\\.${entriesField?.fieldType}").attr('value', itemCount - 1);
            bvp.bindTooltips("#observationFields a.fieldHelp");
        } catch (e) {
            alert(e)
        }
    }

    function syncEntries() {
        for (entryIndex in entries) {
            for (fieldIndex in entries[entryIndex]) {
                var e = entries[entryIndex][fieldIndex];
                e.value = $('#recordValues\\.' + entryIndex + '\\.' + e.name).val();
            }
        }
    }

    function addEntry() {
        try {
            // first we need to save any edits to the entry list
            syncEntries();
            var entry = [
    <g:each in="${fieldList}" var="field" status="fieldIndex">
        <g:set var="fieldLabel" value="${field.label ?: field.fieldType.label}"/>
        <g:set var="fieldName" value="${field.fieldType.name()}"/>
        <g:set var="fieldHelpText" value="${field.helpText}"/>
        {name:'${fieldName}', label:'${fieldLabel}', helpText: "${fieldHelpText}", fieldType:'${field.type?.toString()}', value: '', layoutClass: '${field.layoutClass ?: 'span1'}'}<g:if
            test="${fieldIndex < fieldList.size() - 1}">,</g:if>
    </g:each>
    ];
    entries.push(entry);
    renderEntries();
} catch (e) {
    alert(e)
}
}

function deleteEntry(index) {
syncEntries();
if (index > 0 && index <= entries.length) {
    entries.splice(index, 1);
    renderEntries();
}
return false;
}

$(document).ready(function() {

// prevent enter key submitting form
$(window).keydown(function(event) {
    if (event.keyCode == 13 && event.target.nodeName != "TEXTAREA") {
        event.preventDefault();
        return false;
    }
});

$("#btnAddRow").click(function(e) {
    e.preventDefault();
    addEntry();
});

renderEntries();
});

</r:script>