<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <title><cl:pageTitle title="${(validator) ? message(code: 'transcribe.templateViews.all.validate') : message(code: 'transcribe.templateViews.all.expedition')} ${taskInstance?.project?.i18nName}" /></title>
    </head>
<content tag="templateView">
<div class="form-condensed">
    <div class="row">
        <div class="col-md-12">
            <div>
                <g:set var="multimedia" value="${taskInstance.multimedia.first()}"/>
                <g:imageViewer multimedia="${multimedia}"/>
            </div>
        </div>
    </div>

    <div class="row" style="margin-top: 10px">

        <div class="col-md-9">
            <table style="width:100%">
                <tr>
                    <td>
                        <strong><g:message code="transcribe.templateViews.all.institution"/></strong>
                        <span class="institutionName">${taskInstance?.project?.featuredOwner}</span>
                    </td>
                    <td>
                        <strong><g:message code="transcribe.templateViews.all.project"/></strong>
                        <span class="institutionName">${taskInstance?.project?.i18nName}</span>
                    </td>
                    <td>
                        <strong><g:message code="transcribe.templateViews.all.catalogue_no"/></strong>
                        <span class="institutionName">${recordValues?.get(0)?.catalogNumber}</span>
                    </td>
                    <td>
                        <strong><g:message code="transcribe.templateViews.all.taxa"/></strong>
                        <span class="institutionName">${recordValues?.get(0)?.scientificName}</span>
                    </td>
                </tr>
            </table>
        </div>

        <div class="col-md-3">
            <g:if test="${taskInstance?.project?.i18nTutorialLinks?.toString()}">
                <div class="tutorialLinks" style="text-align: right">
                    ${raw(taskInstance?.project?.i18nTutorialLinks?.toString())}
                </div>
            </g:if>
        </div>

    </div>

    <div class="panel panel-default transcribeSection">
        <div class="panel-body">
            <div class="row">
            <div class="col-md-3">
                <div class="row">
                    <div class="col-md-12">
                        <div class="form-group">
                            <g:set var="allTextField"
                                   value="${TemplateField.findByTemplateAndFieldType(template, DarwinCoreField.occurrenceRemarks)}"/>
                            <span class="pull-right">
                                <g:fieldHelp field="${allTextField}" tooltipPosition="bottomLeft"/>
                            </span>
                            <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. ${allTextField?.label ?: message(code: 'transcribe.templateViews.all.transcribe_all_text_as_it_appears')}</span>
                            <g:textArea class="form-control" validationRule="${allTextField?.validationRule}"
                                        name="recordValues.0.occurrenceRemarks"
                                        value="${recordValues?.get(0)?.occurrenceRemarks}"
                                        id="recordValues.0.occurrenceRemarks" rows="12" cols="42"/>
                            <div class="col-md-12">
                                <button type="button" class="insert-symbol-button" symbol="&deg;"
                                        title="${message(code: 'transcribe.templateViews.all.insert_degree')}"></button>
                                <button type="button" class="insert-symbol-button" symbol="&#39;"
                                        title="${message(code: 'transcribe.templateViews.all.insert_apostophe')}"></button>
                                <button type="button" class="insert-symbol-button" symbol="&quot;"
                                        title="${message(code: 'transcribe.templateViews.all.insert_quote')}"></button>
                                <button type="button" class="insert-symbol-button" symbol="&#x2642;"
                                        title="${message(code: 'transcribe.templateViews.all.insert_male_gender_symbol')}"></button>
                                <button type="button" class="insert-symbol-button" symbol="&#x2640;"
                                        title="${message(code: 'transcribe.templateViews.all.insert_frmale_gender_symbol')}"></button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-10">
                        <button type="button" class="btn btn-info btnCopyFromPreviousTask" href="#task_selector"
                                style=""><g:message code="transcribe.templateViews.all.copy_values_from_a_previous_task"/></button>
                    </div>

                    <div class="col-md-2">
                        <a href="#" class="btn btn-default btn-xs fieldHelp" tooltipPosition="bottomLeft"
                           title="${message(code: 'transcribe.templateViews.all.clicking_this_button.description')}"><i
                                class="fa fa-question help-container"></i></a>
                    </div>
                </div>
            </div>

            <div class="col-md-9">
                <div class="row">
                    <div class="col-md-6">
                        <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. <g:message code="transcribe.templateViews.threeColumnLabel.collection_location"/></span>
                        <g:renderCategoryFieldsColumn category="${FieldCategory.location}" task="${taskInstance}"
                                                      recordValues="${recordValues}" title="${message(code: 'transcribe.templateViews.threeColumnLabel.collection_location')}"/>
                    </div>

                    <div class="col-md-6">
                        <span class="transcribeSectionHeaderLabel"><g:sectionNumber />. <g:message code="transcribe.templateViews.miscellaneous"/></span>
                        <g:renderCategoryFieldsColumn category="${FieldCategory.miscellaneous}" task="${taskInstance}"
                                                      recordValues="${recordValues}" title="${message(code: 'transcribe.templateViews.miscellaneous_event')}"/>
                    </div>
                </div>
            </div>
        </div>
        </div>
    </div>

</div>


<asset:script type="text/javascript">

    $(document).ready(function () {
        $(".tutorialLinks a").each(function (index, element) {
            $(this).addClass("btn btn-default").attr("target", "tutorialWindow");
        });
    });

</asset:script>
</content>
</g:applyLayout>