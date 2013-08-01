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

    <g:set var="entriesField" value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.sightingCount, template)}"/>
    <g:set var="fieldList" value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort:'displayOrder'])}" />

    <div class="well well-small transcribeSection">
        <div class="row-fluid transcribeSectionHeader">
            <div class="span12">
                <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Transcribe each record as follows: Enter the number into the “CatalogNumber “ field. Enter the text into the “Transcribe All text” field.
                <a style="float:right" class="closeSectionLink" href="#">Shrink</a>
            </div>
        </div>
        <div class="transcribeSectionBody">
            <g:render template="dynamicDatasetRows" model="${[recordValues:recordValues, fieldList: fieldList, entriesField: entriesField]}" />
        </div>
    </div>

</div>

<r:script>


    $(document).ready(function() {

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

    });

</r:script>