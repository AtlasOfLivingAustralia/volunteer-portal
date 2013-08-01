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

    <g:set var="numberOfTextRows" value="12" />

    <g:if test="${taskInstance.project.template?.viewParams?.doublePage == 'true'}">
        <div class="row-fluid">
            <div class="span6">
                <div class="well well-small">
                    <g:set var="allTextField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}" />
                    <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Transcribe all text from the left hand page into this box as it appears</span>
                    <a href="#" class="fieldHelp" title='${allTextField?.helpText ?: "Transcribe all text as it appears on the page"}'><span class="help-container">&nbsp;</span></a>
                    <g:textArea class="span12" name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks" rows="${numberOfTextRows}" cols="42"/>
                </div>
            </div>
            <div class="span6">
                <div class="well well-small">
                    <g:set var="allTextField" value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}" />
                    <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Transcribe all text from the right hand page into this box as it appears</span>
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
                    <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${allTextField?.label ?: "Transcribe All Text"}</span>
                    <a href="#" class="fieldHelp" title='${allTextField?.helpText ?: "Transcribe all text as it appears on the page"}'><span class="help-container">&nbsp;</span></a>
                    <g:textArea class="span12" name="recordValues.0.occurrenceRemarks" value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks" rows="${numberOfTextRows}" cols="42"/>
                </div>
            </div>
        </div>
    </g:else>

    <g:if test="${taskInstance.project.template?.viewParams?.hideNames != 'true'}">
        <div class="fields row-fluid transcribeSection">
            <div class="span12">
                <div class="well">
                    <div class="row-fluid transcribeSectionHeader">
                        <div class="span12">
                            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}.  Where a species or common name appears in the text please enter any relevant information into the fields below</span>
                            <a style="float:right" class="closeSectionLink" href="#">Shrink</a>
                        </div>
                    </div>
                    <div class="transcribeSectionBody">
                        <g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.individualCount, template)}"/>
                        <g:set var="fieldList" value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort:'displayOrder'])}" />
                        <g:render template="dynamicDatasetRows" model="${[recordValues:recordValues, fieldList: fieldList, entriesField: entriesField]}" />
                    </div>
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

</r:script>