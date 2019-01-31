<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="groovy.json.StringEscapeUtils" %>
<g:if test="${!entriesField}">
    <div class="alert alert-danger">
        <g:message code="transcribe.dynamicDatasetRows.no_entriesField_defined" />
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
            class="icon-plus icon-white"></i><g:message code="transcribe.dynamicDatasetRows.add_row defined" /></button>
</g:if>

<style type="text/css">

#btnAddRow {
    margin-top: 10px;
}


#observationFields hr {
    margin: 3px;
    border-top-color: #d3d3d3;
}

.form-control.latlon { width: 4em; }

</style>

<asset:script>
    var entries = [
    <g:each in="${0..numItems}" var="i">
        [
        <g:each in="${fieldList}" var="field" status="fieldIndex">
            <g:set var="fieldLabel" value="${field.label ?: field.fieldType.label}"/>
            <g:set var="fieldName" value="${field.fieldType.name()}"/>
            <g:set var="fieldValue" value="${recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')?.replaceAll('\\\\', '\\\\\\\\')}"/>
            <g:set var="fieldHelpText" value="${field.helpText}"/>
            {'name':'${fieldName.encodeAsJavaScript()}', 'label':'${fieldLabel.encodeAsJavaScript()}', 'fieldType':'${field.type?.toString().encodeAsJavaScript()}', 'helpText': "${fieldHelpText.encodeAsJavaScript()}", 'value': "${fieldValue.encodeAsJavaScript()}", layoutClass:"${(field.layoutClass ?: 'span1').encodeAsJavaScript()}"}
            <g:if test="${fieldIndex < fieldList.size() - 1}">,</g:if>
        </g:each>
        ]<g:if test="${i < numItems}">,</g:if>
    </g:each>
    ];

    function toDecimalDegrees(deg, min, sec, dir) {
      var total = deg + (min / 60.0) + (sec / 3600.0);
      if (dir == 'W' || dir == 'S') { total *= -1 }
      return total;
    }

    function decimalToDegrees(dec) {
      if (dec == null || dec == '') return dec;
      return Math.floor(Math.abs(dec));
    }

    function decimalToMinutes(dec) {
      if (dec == null || dec == '') return dec;
      return Math.floor((Math.abs(dec) * 60) % 60);
    }

    function decimalToSeconds(dec) {
      if (dec == null || dec == '') return dec;
      return bvp.round((Math.abs(dec) * 3600) % 60, 5);
    }


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
                    } else if (e.fieldType == 'latLong') {
                      htmlStr += '<input type="text" id="'+name+'-degrees" name="'+name+'.degrees" placeholder="D" class="' + e.name + ' degrees form-control latlon" value="' + decimalToDegrees(e.value) + '" data-field="'+name+'" />';
                      htmlStr += '<input type="text" id="'+name+'-minutes" name="'+name+'.minutes" placeholder="M" class="' + e.name + ' minutes form-control latlon" value="' + decimalToMinutes(e.value) + '" data-field="'+name+'" />';
                      htmlStr += '<input type="text" id="'+name+'-seconds" name="'+name+'.seconds" placeholder="S" class="' + e.name + ' seconds form-control latlon" value="' + decimalToSeconds(e.value) + '" data-field="'+name+'" />';%{--validationRule="${field.validationRule}"--}%
                      var directionFrom;
                      var direction;
                      if ((e.name).match(/lat/i)) {
                        direction = e.value < 0 ? 'S' : 'N';
                        directionFrom = ['N', 'S'];
                      } else {
                        direction = e.value < 0 ? 'W' : 'E';
                        directionFrom = ['E', 'W'];
                      }
                      htmlStr += '<select class="form-control direction latlon" id="'+name+'-direction" name="'+name+'.direction" data-field="'+name+'">';
                      for (var i=0; i < directionFrom.length; ++i) {
                        htmlStr += '<option value="'+directionFrom[i]+'" ';
                        if (direction == directionFrom[i]) {
                          htmlStr += 'selected';
                        }
                        htmlStr += '>'+directionFrom[i]+'</option>';
                      }
                      htmlStr += '</select><input type="hidden" name="' + name + '" value="' + e.value + '" id="' + name + '" />';
                    } else {
                      htmlStr += '<input type="text" name="' + name + '" value="' + e.value + '" id="' + name + '" class="' + e.name + ' form-control"/>';
                    }

                    htmlStr += '</div> ';
                    fieldCount++;
                }
                if (entryIndex > 0) {
                htmlStr += '<button role="button" class="btn btn-xs btn-danger" onclick="deleteEntry(' + entryIndex + '); return false;"><span class="glyphicon glyphicon-remove glyphicon-white"></span> <g:message code="default.button.delete.label" />Delete </button>';
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

$('#observationFields').on('change', '.form-control.latlon', function(e) {
  var $this = $(e.target);
  var field = bvp.escapeIdPart($this.data('field'));
  var $field = $('#' + field);
  var deg = parseFloat($('#'+field+'-degrees').val()) || 0;
  var min = parseFloat($('#'+field+'-minutes').val()) || 0;
  var sec = parseFloat($('#'+field+'-seconds').val()) || 0;
  var dir = $('#'+field+'-direction').val();
  $field.val(toDecimalDegrees(deg,min,sec,dir));
});

$("#btnAddRow").click(function(e) {
    e.preventDefault();
    addEntry();
});

renderEntries();
});

</asset:script>