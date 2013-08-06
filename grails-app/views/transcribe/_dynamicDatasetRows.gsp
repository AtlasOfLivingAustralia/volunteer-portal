<g:hiddenField name="recordValues.0.${entriesField.fieldType}" id="noOfEntries" value="${recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue ?: 0}" />

<g:set var="numItems" value="${(recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue ?: "0").toInteger()}" />


<div class="row-fluid" >
    <g:each in="${fieldList}" var="field" status="i">
        <g:set var="spanClass" value="span12" />
        <g:if test="${i == 0}">
            <g:set var="spanClass" value="span9 offset3" />
        </g:if>
        <div class="${field.layoutClass ?: 'span1'}">
            <div class="${spanClass}">
                <strong>${field.label ?: field.fieldType?.toString()}</strong>
            </div>
        </div>
    </g:each>
    <div class="span1">

    </div>
</div>

<div id="observationFields">
</div>

<button class="btn btn-small btn-success" id="btnAddRow"><i class="icon-plus icon-white"></i>&nbsp;Add&nbsp;Row</button>

<r:script>

    var entries = [

    <g:each in="${0..numItems}" var="i">
        [
        <g:each in="${fieldList}" var="field" status="fieldIndex">
            <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
            <g:set var="fieldName" value="${field.fieldType.name()}"/>
            <g:set var="fieldValue" value="${recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')}" />
            {name:'${fieldName}', label:'${fieldLabel}', fieldType:'${field.type?.toString()}', value: "${fieldValue}", layoutClass:"${field.layoutClass ?: 'span1'}"}<g:if test="${fieldIndex < fieldList.size()- 1 }">,</g:if>
        </g:each>
        ]<g:if test="${i < numItems}">,</g:if>
    </g:each>
    ];

    function renderEntries() {
        try {
            var htmlStr ="";
            var itemCount = 0;
            for (entryIndex in entries) {
                htmlStr += '<div class="row-fluid">';
                // htmlStr += '<tr class="observationFields" id="0"><td><strong>' + (parseInt(entryIndex) + 1) + '.</strong>'
                for (fieldIndex in entries[entryIndex]) {
                    var e = entries[entryIndex][fieldIndex];
                    var name = "recordValues." + entryIndex + "." + e.name;
                    htmlStr += '<div class="value ' + e.layoutClass + '">';
                    var controlClass = 'span12';
                    if (fieldIndex == 0) {
                        controlClass = 'span9';
                        htmlStr += '<strong class="span3">' + (parseInt(entryIndex) + 1) + '.</strong>';
                    }

                    if (e.fieldType == 'textarea') {
                        htmlStr += '<textarea name="' + name + '" rows="2" id="' + name + '" class="' + e.name + ' ' + controlClass + '">' + e.value + '</textarea></div>';
                    } else {
                        htmlStr += '<input type="text" name="' + name + '" value="' + e.value + '" id="' + name + '" class="' + e.name + ' ' + controlClass + '"/></div>';
                    }
                }
                if (entryIndex > 0) {
                    htmlStr += '<div class="span1"><button class="btn btn-small btn-danger" onclick="deleteEntry(' + entryIndex + '); return false;"><i class="icon-remove icon-white"></i>&nbsp;Delete</button></div>';
                }
                htmlStr += "</div>"
                itemCount++;
            }
            $("#observationFields").html(htmlStr);
            $("#noOfEntries").attr('value', itemCount - 1);
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
                {name:'${fieldName}', label:'${fieldLabel}', fieldType:'${field.type?.toString()}', value: '', layoutClass: '${field.layoutClass ?: 'span1'}'}<g:if test="${fieldIndex < fieldList.size() - 1}">,</g:if>
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