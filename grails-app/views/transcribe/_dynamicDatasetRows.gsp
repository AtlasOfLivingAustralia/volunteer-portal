<g:hiddenField name="recordValues.0.${entriesField.fieldType}" id="noOfEntries" value="${recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue ?: 0}" />
<g:set var="numItems" value="${(recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue ?: "0").toInteger()}" />

<div id="observationFields">
</div>
<style type="text/css">

    .fieldLabel {
        margin-right: 10px;
        margin-left: 10px;
        text-wrap: none;
    }

    .fieldValue input[type="text"] {
        padding: 0px;
        min-height: 22px;
        width: 130px;
    }

    #btnAddRow {
        margin-top: 10px;
    }

    .deleteButton {
        margin: 5px;
    }

</style>

<button class="btn btn-small btn-success" id="btnAddRow"><i class="icon-plus icon-white"></i>&nbsp;Add&nbsp;Row</button>

<r:script>

    var entries = [

    <g:each in="${0..numItems}" var="i">
        [
        <g:each in="${fieldList}" var="field" status="fieldIndex">
            <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
            <g:set var="fieldName" value="${field.fieldType.name()}"/>
            <g:set var="fieldValue" value="${recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')}" />
            <g:set var="fieldHelpText" value="${field.helpText}" />
            {name:'${fieldName}', label:'${fieldLabel}', fieldType:'${field.type?.toString()}', helpText: "${fieldHelpText}", value: "${fieldValue}", layoutClass:"${field.layoutClass ?: 'span1'}"}<g:if test="${fieldIndex < fieldList.size()- 1 }">,</g:if>
        </g:each>
        ]<g:if test="${i < numItems}">,</g:if>
    </g:each>
    ];

    function renderEntries() {
        try {
            var htmlStr ="";
            var itemCount = 0;
            for (entryIndex in entries) {
                htmlStr += '<div>';
                if (entryIndex > 0) {
                    htmlStr += "<hr/>";
                }
                for (fieldIndex in entries[entryIndex]) {
                    var e = entries[entryIndex][fieldIndex];
                    var name = "recordValues." + entryIndex + "." + e.name;
                    htmlStr += '<span class="fieldLabel">';
                    if (fieldIndex == 0) {
                        htmlStr += '<strong>' + (parseInt(entryIndex) + 1) + '.</strong>&nbsp;';
                    }
                    htmlStr += e.label;
                    if (e.helpText) {
                        htmlStr += '<a href="#" class="fieldHelp" title="' + e.helpText + '"><span class="help-container">&nbsp;</span></a>';
                    }

                    htmlStr += '</span>';

                    htmlStr += '<span class="fieldValue">';

                    if (e.fieldType == 'textarea') {
                        htmlStr += '<textarea name="' + name + '" rows="2" id="' + name + '" class="' + e.name + '">' + e.value + '</textarea>';
                    } else {
                        htmlStr += '<input type="text" name="' + name + '" value="' + e.value + '" id="' + name + '" class="' + e.name + '"/>';
                    }

                    htmlStr += "</span>";
                }
                if (entryIndex > 0) {
                    htmlStr += '<span class="deleteButton"><button class="btn btn-small btn-danger" onclick="deleteEntry(' + entryIndex + '); return false;"><i class="icon-remove icon-white"></i>&nbsp;Delete</button></span>';
                }
                htmlStr += "</div>"
                itemCount++;
            }
            $("#observationFields").html(htmlStr);
            $("#noOfEntries").attr('value', itemCount - 1);
            bindTooltips();
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
                <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
                <g:set var="fieldName" value="${field.fieldType.name()}"/>
                <g:set var="fieldHelpText" value="${field.helpText}" />
                {name:'${fieldName}', label:'${fieldLabel}', helpText: "${fieldHelpText}", fieldType:'${field.type?.toString()}', value: '', layoutClass: '${field.layoutClass ?: 'span1'}'}<g:if test="${fieldIndex < fieldList.size() - 1}">,</g:if>
            </g:each>
            ];
            entries.push(entry);
            renderEntries();
        } catch (e) {
            alert(e)
        }
    }

    function deleteEntry(index) {
        syncEntries()
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