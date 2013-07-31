<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />

<g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.sightingCount, template)}"/>
<g:set var="numItems" value="${(recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue).toInteger()}" />
<g:set var="fieldList" value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort:'id'])}" />

<style type="text/css">

    #image-container {
        width: 100%;
        height: 100px;
        overflow: hidden;
    }

    #image-container img {
        max-width: inherit !important;
    }

</style>

<div class="container-fluid">

    <div class="row-fluid">
        <div class="span12">
            <span id="journalPageButtons">
                <button class="btn btn-small" id="showPreviousJournalPage" title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><img src="${resource(dir:'images',file:'left_arrow.png')}"> show previous journal page</button>
                <button class="btn btn-small" id="showNextJournalPage" title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>show next journal page <img src="${resource(dir:'images',file:'right_arrow.png')}"></button>
                <button class="btn btn-small" id="rotateImage" title="Rotate the page 180 degrees">Rotate&nbsp;<img style="vertical-align: middle; margin: 0 !important;" src="${resource(dir:'images',file:'rotate.png')}"></button>
            </span>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <div class="well well-small">
                <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                    <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                        <g:imageViewer multimedia="${multimedia}" />
                    </g:if>
                </g:each>
            </div>
        </div>
    </div>

    <div class="well well-small transcribeSection">
        <div class="flightDetails row-fluid" >
            <div class="span2">
                <strong>Date</strong>
            </div>
            <div class="span1"></div>
            <div class="span2">
                <strong>Aircraft</strong>
            </div>
            <div class="span7">
                <strong>All text verbatim</strong>
            </div>
        </div>

        <g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.sightingCount, template)}"/>
        <g:hiddenField name="recordValues.0.${entriesField.fieldType}" id="noOfEntries" value="${recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue}"/>

        <div class="flightDetails row-fluid" >
            <div class="span2">
                <g:renderFieldBootstrap fieldType="${DarwinCoreField.eventDate}" recordValues="${recordValues}" task="${taskInstance}" hideLabel="${true}" valueClass="span12" />
            </div>
            <div class="span1"></div>
            <div class="span2">
                <g:renderFieldBootstrap fieldType="${DarwinCoreField.fieldNumber}" recordValues="${recordValues}" task="${taskInstance}" hideLabel="${true}" valueClass="span12" />
            </div>
            <div class="span7">
                <g:renderFieldBootstrap fieldType="${DarwinCoreField.occurrenceRemarks}" recordValues="${recordValues}" task="${taskInstance}" hideLabel="${true}" valueClass="span12" rows="2" />
            </div>
        </div>
    </div>

    <div class="well well-small transcribeSection" style="margin-bottom: 10px">
        <div class="row-fluid" >
            <g:each in="${fieldList}" var="field">
                <div class="${field.layoutClass ?: 'span1'}">
                    <strong>${field.label ?: field.fieldType?.toString()}</strong>
                </div>
            </g:each>
        </div>
        <div id="observationFields">
        </div>
    </div>

    <button class="btn btn-success" id="btnAdd" style="margin-bottom: 10px">Add Row</button>

</div>

<r:script>

    var entries = [

    <g:each in="${0..numItems}" var="i">
        [
        <g:each in="${fieldList}" var="field" status="fieldIndex">
            <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
            <g:set var="fieldName" value="${field.fieldType.name()}"/>
            <g:set var="fieldValue" value="${recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')}" />
            {name:'${fieldName}', label:'${fieldLabel}', value: "${fieldValue}", layoutClass:"${field.layoutClass ?: 'span1'}"}<g:if test="${fieldIndex < fieldList.size()- 1 }">,</g:if>
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
                        controlClass = 'span10';
                        htmlStr += '<strong class="span2">' + (parseInt(entryIndex) + 1) + '.</strong>';

                    }
                    htmlStr += '<input type="text" name="' + name + '" value="' + e.value + '" id="' + name + '" class="' + e.name + ' ' + controlClass + '"></div>';
                }
                if (entryIndex > 0) {
                    htmlStr += '<div class="span1"><button class="btn btn-danger" onclick="deleteEntry(' + entryIndex + '); return false;">Delete</button></div>';
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

    $("#btnAdd").click(function(e) {
        e.preventDefault();
        addEntry();
    });

    renderEntries();

    function syncEntries() {
        for (entryIndex in entries) {
            for (fieldIndex in entries[entryIndex]) {
                var e = entries[entryIndex][fieldIndex];
                e.value = $('#recordValues\\.' + entryIndex + '\\.' + e.name).val();
            }
        }
    }

    function addEntry(e) {
        try {
            // first we need to save any edits to the entry list
            syncEntries();
            var entry = [
            <g:each in="${fieldList}" var="field" status="fieldIndex">
                <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
                <g:set var="fieldName" value="${field.fieldType.name()}"/>
                {name:'${fieldName}', label:'${fieldLabel}', value: '', layoutClass: '${field.layoutClass ?: 'span1'}'}<g:if test="${fieldIndex < fieldList.size() - 1}">,</g:if>
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

    // display previous journal page in new window
    $("#showPreviousJournalPage").click(function(e) {
        e.preventDefault();
        <g:if test="${prevTask}">
            var uri = "${createLink(controller: 'task', action:'showImage', id: prevTask.id)}"
            newwindow = window.open(uri,'journalWindow','directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
            if (window.focus) {
                newwindow.focus()
            }
        </g:if>
    });

    // display next journal page in new window
    $("#showNextJournalPage").click(function(e) {
        e.preventDefault();
        <g:if test="${nextTask}">
            var uri = "${createLink(controller: 'task', action:'showImage', id: nextTask.id)}"
            newwindow = window.open(uri,'journalWindow','directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,height=600,width=1000');
            if (window.focus) {
                newwindow.focus()
            }
        </g:if>
    });

    $("#rotateImage").click(function(e) {
        e.preventDefault();
        $("#image-container img").toggleClass("rotate-image");
    });

    $(document).ready(function() {

        // prevent enter key submitting form
        $(window).keydown(function(event) {
            if (event.keyCode == 13 && event.target.nodeName != "TEXTAREA") {
                event.preventDefault();
                return false;
            }
        });
    });

</r:script>