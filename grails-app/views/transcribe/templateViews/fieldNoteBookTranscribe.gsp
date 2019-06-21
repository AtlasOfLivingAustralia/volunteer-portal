<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title><cl:pageTitle title="${(validator) ? message(code: 'transcribe.templateViews.all.validate') : message(code: 'transcribe.templateViews.all.expedition')} ${taskInstance?.project?.i18nName}" /></title>
        <style>
            .fontSizeButton {
                line-height: 18px !important;
            }
            #journalPageButtons {
                margin-bottom:5px;
            }
        </style>
    </head>
    <content tag="templateView">
    <div class="row">
        <div class="col-md-12">
            <div class="btn-toolbar" id="journalPageButtons">
                <div class="btn-group btn-group-sm">
                    <button type="button" class="btn btn-default" id="showPreviousJournalPage"
                            title="${message(code: 'transcribe.templateViews.all.display_in_new_window')}" ${prevTask ? '' : 'disabled="true"'}><asset:image
                        src="left_arrow.png" /> <g:message code="transcribe.templateViews.all.show_previous_journal"/></button>
                <button type="button" class="btn btn-default" id="showNextJournalPage"
                        title="${message(code: 'transcribe.templateViews.all.display_in_new_window')}" ${nextTask ? '' : 'disabled="true"'}><g:message code="transcribe.templateViews.all.show_next_journal_page"/>
                        <asset:image src="right_arrow.png" /></button>
                <button type="button" class="btn btn-default" id="rotateImage"
                        title="${message(code: 'transcribe.templateViews.all.rotate_image')}"><g:message code="transcribe.templateViews.all.rotate"/>&nbsp;<asset:image
                        style="vertical-align: middle; margin: 0 !important;"
                        src="rotate.png" /></button>
                </div>

                <div class="btn-group btn-group-sm pull-right">
                    <button type="button" class="btn btn-default fontSizeButton" title="${message(code: 'transcribe.templateViews.fieldNoteBookSingleTranscribe.small_fonts')}"
                            style="font-size: 12px">A</button>
                    <button type="button" class="btn btn-default fontSizeButton" title="${message(code: 'transcribe.templateViews.fieldNoteBookSingleTranscribe.medium_fonts')}"
                            style="font-size: 15px">A</button>
                    <button type="button" class="btn btn-default fontSizeButton" title="${message(code: 'transcribe.templateViews.fieldNoteBookSingleTranscribe.large_fonts')}"
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
                            <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. <g:message code="transcribe.templateViews.fieldNoteBookSingleTranscribe.transcribe_all_text_description"/></span>
                            <a href="#" class="btn btn-default btn-xs fieldHelp"
                               title='${allTextField?.helpText ?: "${message(code: 'transcribe.templateViews.fieldNoteBookSingleTranscribe.transcribe_all_text_as_it_appears')}"}'
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
                            <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. <g:message code="transcribe.templateViews.fieldNoteBookSingleTranscribe.transcribe_all_text_right_description"/></span>
                            <a href="#" class="btn btn-default btn-xs fieldHelp"
                               title='${allTextField?.helpText ?: "${message(code: 'transcribe.templateViews.fieldNoteBookSingleTranscribe.transcribe_all_text_as_it_appears')}"}'><i
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
                            <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. ${allTextField?.label ?: "${message(code: 'transcribe.templateViews.fieldNoteBookSingleTranscribe.transcribe_all_text')}"}</span>
                            <a href="#" class="btn btn-default btn-xs fieldHelp"
                               title='${allTextField?.helpText ?: message(code: 'transcribe.templateViews.fieldNoteBookSingleTranscribe.transcribe_all_text_as_it_appears')}'
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
                            <span class="transcribeSectionHeaderLabel"><g:sectionNumber />.  ${taskInstance.project.template?.viewParams?.transcribeSectionHeader ?: g.message(code: 'fieldNoteBookTranscribe.transcribeSectionHeader.default', default:  'Where a species or common name appears in the text please enter any relevant information into the fields below')}</span>
                            <a style="float:right" class="closeSectionLink" href="#"><g:message code="transcribe.templateViews.all.shrink"/></a>
                        </div>
                    </div>

                    <div class="transcribeSectionBody">
                        <g:set var="entriesField"
                               value="${TemplateField.findByFieldTypeAndTemplate(DarwinCoreField.individualCount, template)}"/>
                        <g:if test="${isPreview && !entriesField}">
                            <div class="alert alert-danger">
                                <g:message code="transcribe.templateViews.fieldNoteBookTranscribe.requirements"/>
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


<asset:script type="text/javascript">

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

</asset:script>
    </content>
</g:applyLayout>