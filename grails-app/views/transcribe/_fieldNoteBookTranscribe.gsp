<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />

<style type="text/css">

    #image-container {
        width: 100%;
        height: 400px;
        overflow: hidden;
    }

    #image-container img {
        max-width: inherit !important;
    }

    .transcribeSectionHeaderLabel {
        font-weight: bold;
    }

    .prop .name {
        vertical-align: top;
    }

</style>

<g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.individualCount, template)}"/>
<g:set var="numItems" value="${(recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue).toInteger()}" />
<g:set var="fieldList" value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort:'id'])}" />

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

    <g:set var="numberOfTextRows" value="12" />
    <g:set var="sectionNumber" value="${1}" />

    <g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.individualCount, template)}"/>
    <g:hiddenField name="recordValues.0.${entriesField.fieldType}" id="noOfEntries" value="${recordValues?.get(0)?.get(entriesField.fieldType.name())?:entriesField.defaultValue}"/>

    <g:if test="${taskInstance.project.template?.viewParams?.doublePage == 'true'}">
        <div class="row-fluid">
            <div class="span6">
                <div class="well well-small">
                    <g:set var="allTextField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}" />
                    <span class="transcribeSectionHeaderLabel">${sectionNumber++}. Transcribe all text from the left hand page into this box as it appears</span>
                    <a href="#" class="fieldHelp" title='${allTextField?.helpText ?: "Transcribe all text as it appears on the page"}'><span class="help-container">&nbsp;</span></a>
                    <g:textArea class="span12" name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks" rows="${numberOfTextRows}" cols="42"/>
                </div>
            </div>
            <div class="span6">
                <div class="well well-small">
                    <g:set var="allTextField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}" />
                    <span class="transcribeSectionHeaderLabel">${sectionNumber++}. Transcribe all text from the right hand page into this box as it appears</span>
                    <a href="#" class="fieldHelp" title='${allTextField?.helpText ?: "Transcribe all text as it appears on the page"}'><span class="help-container">&nbsp;</span></a>
                    <g:textArea class="span12" name="recordValues.1.occurrenceRemarks" value="${recordValues?.get(1)?.occurrenceRemarks}" id="recordValues.1.occurrenceRemarks" rows="${numberOfTextRows}" cols="42"/>
                </div>
            </div>
        </div>
    </g:if>
    <g:else>
        <div class="row-fluid">
            <div class="span12">
                <div class="well well-small">
                    <g:set var="allTextField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}" />
                    <span class="transcribeSectionHeaderLabel">${sectionNumber++}. ${allTextField?.label ?: "Transcribe All Text"}</span>
                    <a href="#" class="fieldHelp" title='${allTextField?.helpText ?: "Transcribe all text as it appears on the page"}'><span class="help-container">&nbsp;</span></a>
                    <g:textArea class="span12" name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks" rows="${numberOfTextRows}" cols="42"/>
                </div>
            </div>
        </div>
    </g:else>

    <g:if test="${taskInstance.project.template?.viewParams?.hideNames != 'true'}">
        <div class="fields row-fluid" id="journal2Fields">
            <div class="span12">
                <div class="well">
                    <span class="transcribeSectionHeaderLabel">${sectionNumber++}.  Where a species or common name appears in the text please enter any relevant information into the fields below</span>
                    <button class="btn btn-small pull-right btn-info" id="addRowButton">Add row</button>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <g:each in="${fieldList}" var="field">
                                    <th>${field.label}</th>
                                </g:each>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody id="identification_fields">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </g:if>

</div>

<r:script>

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

    var entries = [

    <g:each in="${0..numItems}" var="i" >
        [
        <g:each in="${fieldList}" var="field" status="fieldIndex">
            <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
            <g:set var="fieldName" value="${field.fieldType.name()}"/>
            <g:set var="fieldValue" value="${recordValues?.get(i)?.get(field.fieldType.name())?.encodeAsHTML()?.replaceAll('\\\'', '&#39;')?.replaceAll('\n', '&#10;')?.replaceAll('\r','&#13;')}" />
            {name:'${fieldName}', label:'${fieldLabel}', value: "${fieldValue}"}<g:if test="${fieldIndex < fieldList.size() - 1}">,</g:if>
        </g:each>
        ]<g:if test="${i < numItems}">,</g:if>
    </g:each>
    ];

    function renderEntries() {
      try {
        var htmlStr ="";
        var itemCount = 0; // Need to count the entries because IE8 will report an incorrect array size because of a trailing ',' in the original list render

        for (entryIndex in entries) {
          htmlStr += '<tr class="fieldNoteFields"><td><strong>' + (parseInt(entryIndex) + 1) + '.</strong></td>';
          for (fieldIndex in entries[entryIndex]) {
            var e = entries[entryIndex][fieldIndex];
            var name = "recordValues." + entryIndex + "." + e.name;
            htmlStr += '<td>';
//            htmlStr += '<label for="' + name + '">' + e.label + "</label>";
            htmlStr += '<input class="span12" type="text" name="' + name + '" value="' + e.value + '" id="' + name + '">';
            htmlStr += '</td>';
          }
          if (entryIndex > 0) {
            htmlStr += '<td><button class="btn btn-small btn-danger" onclick="deleteEntry(' + entryIndex + '); return false;">Delete</button></td>';
          } else {
            htmlStr += '<td></td>';
          }
          htmlStr += "</tr>";
          itemCount++;
        }
        $("#identification_fields").html(htmlStr);
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

    function addEntry(e) {
      try {

        // first we need to save any edits to the entry list
        syncEntries();

        var entry = [
        <g:each in="${fieldList}" var="field" status="i">
            <g:set var="fieldLabel" value="${field.label?:field.fieldType.label}"/>
            <g:set var="fieldName" value="${field.fieldType.name()}"/>
            {name:'${fieldName}', label:'${fieldLabel}', value: ''}<g:if test="${i < fieldList.size()-1}">,</g:if>
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

        $("#addRowButton").click(function(e) {
          e.preventDefault();
          addEntry();
        });

        renderEntries();
    });

</r:script>