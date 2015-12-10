<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>

<style>
    .fontSizeButton {
        line-height: 18px !important;
    }
    #journalPageButtons {
        margin-bottom:5px;
    }
</style>

<div class="row">
    <div class="col-md-12">
        <div class="btn-toolbar" id="journalPageButtons">
            <div class="btn-group btn-group-sm">
                <button type="button" class="btn btn-default" id="showPreviousJournalPage"
                        title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><img
                        src="${resource(dir: 'images', file: 'left_arrow.png')}"> show previous journal page</button>
                <button type="button" class="btn btn-default" id="showNextJournalPage"
                        title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>show next journal page <img
                        src="${resource(dir: 'images', file: 'right_arrow.png')}"></button>
                <button type="button" class="btn btn-default" id="rotateImage"
                        title="Rotate the page 180 degrees">Rotate&nbsp;<img
                        style="vertical-align: middle; margin: 0 !important;"
                        src="${resource(dir: 'images', file: 'rotate.png')}"></button>
            </div>

            <div class="btn-group btn-group-sm pull-right">
                <button type="button" class="btn btn-default fontSizeButton" title="Small sized fonts"
                        style="font-size: 12px">A</button>
                <button type="button" class="btn btn-default fontSizeButton" title="Medium sized fonts"
                        style="font-size: 15px">A</button>
                <button type="button" class="btn btn-default fontSizeButton" title="Large sized fonts"
                        style="font-size: 18px">A</button>

            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <div class="panel panel-default">
            <div class="panel-body">
            <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                    <g:imageViewer multimedia="${multimedia}"/>
                </g:if>
            </g:each>
            </div>
        </div>
    </div>
</div>

<g:set var="numberOfTextRows" value="12"/>

<g:if test="${taskInstance.project.template?.viewParams?.doublePage == 'true'}">
    <div class="row">
        <div id="leftPage" class="col-md-6 page">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-12">
                            <g:set var="allTextField"
                                   value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}"/>
                            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Transcribe all text from the left hand page into this box as it appears</span>
                            <a href="#" class="btn btn-default btn-xs fieldHelp"
                               title='${allTextField?.helpText ?: "Transcribe all text as it appears on the page"}'
                               tooltipPosition="bottomLeft" targetPosition="topRight"><i class="fa fa-question help-container"></i>
                            </a>
                            <button class="btn btn-default btn-mini pull-right textAreaResizeButton" style="margin-bottom: 3px"><i
                                    class="glyphicon glyphicon-resize-full"></i></button>
                        </div>
                        <div class="col-md-12">
                            <g:textArea class="form-control occurrenceRemarks" name="recordValues.0.occurrenceRemarks"
                                value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks"
                                rows="${numberOfTextRows}" cols="42"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="rightPage" class="col-md-6 page">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-12">
                            <g:set var="allTextField"
                                   value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}"/>
                            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. Transcribe all text from the right hand page into this box as it appears</span>
                            <a href="#" class="btn btn-default btn-xs fieldHelp"
                               title='${allTextField?.helpText ?: "Transcribe all text as it appears on the page"}'><i
                                    class="fa fa-question help-container"></i></a>
                            <button class="btn btn-default btn-mini pull-right textAreaResizeButton" style="margin-bottom: 3px"><i
                                    class="glyphicon glyphicon-resize-full"></i></button>
                        </div>

                        <div class="col-md-12">
                            <g:textArea class="form-control occurrenceRemarks" name="recordValues.1.occurrenceRemarks"
                                value="${recordValues?.get(1)?.occurrenceRemarks}" id="recordValues.1.occurrenceRemarks"
                                rows="${numberOfTextRows}" cols="42"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</g:if>
<g:else>
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="row">
                        <g:set var="allTextField"
                               value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}"/>
                        <div class="col-md-12">
                            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}. ${allTextField?.label ?: "Transcribe All Text"}</span>
                            <a href="#" class="btn btn-default btn-xs fieldHelp"
                               title='${allTextField?.helpText ?: "Transcribe all text as it appears on the page"}'
                               tooltipPosition="bottomLeft" targetPosition="topRight"><i class="fa fa-question help-container"></i>
                            </a>
                        </div>
                        <div class="col-md-12">
                            <g:textArea class="form-control occurrenceRemarks" name="recordValues.0.occurrenceRemarks"
                                    value="${recordValues?.get(0)?.occurrenceRemarks}" id="recordValues.0.occurrenceRemarks"
                                    rows="${numberOfTextRows}" cols="42"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</g:else>

<g:if test="${taskInstance.project.template?.viewParams?.hideNames != 'true'}">
    <div class="fields row transcribeSection">
        <div class="col-md-12">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="row transcribeSectionHeader">
                        <div class="col-md-12">
                            <span class="transcribeSectionHeaderLabel">${nextSectionNumber()}.  Where a species or common name appears in the text please enter any relevant information into the fields below</span>
                            <a style="float:right" class="closeSectionLink" href="#">Shrink</a>
                        </div>
                    </div>

                    <div class="transcribeSectionBody">
                        <g:set var="entriesField"
                               value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.individualCount, template)}"/>
                        <g:if test="${isPreview && !entriesField}">
                            <div class="alert alert-danger">
                                This template view (fieldNoteBookTranscribe) requires the <strong>individualCount</strong> field to be configured.
                            </div>
                        </g:if>
                        <g:set var="fieldList"
                               value="${TemplateField.findAllByCategoryAndTemplate(FieldCategory.dataset, template, [sort: 'displayOrder'])}"/>
                        <g:render template="/transcribe/dynamicDatasetRows"
                                  model="${[recordValues: recordValues, fieldList: fieldList, entriesField: entriesField]}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</g:if>


<script>

    $(document).ready(function () {
        $(".fontSizeButton").click(function (e) {
            e.preventDefault();
            var fontSize = $(this).css("font-size");
            $(".row .occurrenceRemarks, #observationFields input, #observationFields textarea").css("font-size", fontSize).css("line-height", fontSize);
        });

        $(".textAreaResizeButton").click(function (e) {
            e.preventDefault();
            var page = $(this).closest(".page");
            var otherPage;


            if (page.attr("id") == "leftPage") {
                otherPage = $("#rightPage");
            } else {
                otherPage = $("#leftPage");
            }

            var smallWidth = 1;

            var shrunkClass = "col-md-" + smallWidth.toString();
            var expandedClass = "col-md-" + (12 - smallWidth).toString();

            if (page.hasClass("col-md-6")) {
                page.removeClass("col-md-6");
                page.addClass(expandedClass);
                otherPage.removeClass("col-md-6");
                otherPage.removeClass(expandedClass);
                otherPage.addClass(shrunkClass);
                page.find(".textAreaResizeButton").html('<span class="glyphicon glyphicon-resize-small"></span>');
            } else if (page.hasClass(shrunkClass)) {
                page.removeClass(shrunkClass);
                page.addClass(expandedClass);
                otherPage.removeClass(expandedClass);
                otherPage.addClass(shrunkClass);
                page.find(".textAreaResizeButton").html('<span class="glyphicon glyphicon-resize-small"></span>');
                otherPage.find(".textAreaResizeButton").html('<span class="glyphicon glyphicon-resize-full"></span>');
            } else {
                page.removeClass(expandedClass);
                page.removeClass(shrunkClass);
                page.addClass("col-md-6");
                otherPage.removeClass(shrunkClass);
                otherPage.removeClass(expandedClass);
                otherPage.addClass("col-md-6");
                page.find(".textAreaResizeButton").html('<span class="glyphicon glyphicon-resize-full"></span>');
                otherPage.find(".textAreaResizeButton").html('<span class="glyphicon glyphicon-resize-full"></span>');
                page.find(".transcribeSectionHeaderLabel").css("display", "inline");
                otherPage.find(".transcribeSectionHeaderLabel").css("display", "inline");
            }

            page.find("textarea").css("width", "");
            otherPage.find("textarea").css("width", "");

            $("." + shrunkClass).find(".transcribeSectionHeaderLabel").css("display", "none");
            $("." + expandedClass).find(".transcribeSectionHeaderLabel").css("display", "inline");
        });

    });

</script>