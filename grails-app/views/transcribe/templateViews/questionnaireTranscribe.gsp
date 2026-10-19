<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
<head>
    <title><cl:pageTitle title="${(validator) ? 'Validate' : 'Expedition'} ${taskInstance?.project?.name}" /></title>
</head>
<content tag="templateView">
    <div class="row">
        <div class="col-12 col-lg-6 qt-image-card">
            <div class="card mb-2">
                <div class="card-body">
                    <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                        <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                            <g:imageViewer multimedia="${multimedia}"/>
                        </g:if>
                    </g:each>
                </div>
            </div>
        </div>

        <g:set var="fieldList" value="${g.templateFields(category: FieldCategory.dataset, template: template)}"/>
        <g:set var="hiddenList"
               value="${g.templateFields(category: FieldCategory.dataset, template: template, hidden: true)}"/>

        <div class="col-12 col-lg-6">
            <div class="card mb-2">
                <div class="card-body">
                    <div id="qa-questions-pager">
                        <ul class="nav nav-pills justify-content-center mb-4" id="carouselPills" role="tablist">
                            <g:each in="${fieldList}" var="f" status="st">
                                <g:set var="isActive" value="${!validator && st == 0 ? 'active' : ''}"/>
                            <li class="nav-item">
                                <button class="nav-link ${isActive}"
                                        data-bs-target="#qaCarousel"
                                        data-bs-slide-to="${st}"
                                        type="button">Step ${st + 1}</button>
                            </li>
                            </g:each>
                            <li class="nav-item">
                                <button class="nav-link ${validator ? 'active' : ''}"
                                        data-bs-target="#qaCarousel"
                                        data-container="body"
                                        data-bs-slide-to="${fieldList.size()}"
                                        type="button">Step ${fieldList.size() + 1}</button>
                            </li>
                        </ul>
                    </div>
%{--                    <div id="qa-questions-pager" class="stepwizard">--}%
%{--                        <div class="stepwizard-row">--}%
%{--                            <div class="stepwizard-step">--}%
%{--                                <span>Steps</span>--}%
%{--                                <g:each in="${fieldList}" var="f" status="st">--}%
%{--                                    <g:set var="isActive" value="${!validator && st == 0 ? 'active' : ''}"/>--}%
%{--                                    <button type="button" class="btn btn-sm btn-circle btn-outline-secondary ${isActive}"--}%
%{--                                            data-bs-target="#qaCarousel"--}%
%{--                                            data-bs-slide-to="${st}">--}%
%{--                                        ${st + 1}--}%
%{--                                    </button>--}%
%{--                                </g:each>--}%
%{--                                <button type="button" class="btn btn-sm btn-circle btn-outline-secondary ${validator ? 'active' : ''}"--}%
%{--                                        title="${message(code: 'questionnaire.summary.button.tooltip', default: 'Click any time to view and submit your choices')}"--}%
%{--                                        data-container="body"--}%
%{--                                        data-bs-target="#qaCarousel"--}%
%{--                                        data-bs-slide-to="${fieldList.size()}">--}%
%{--                                    ${fieldList.size() + 1}--}%
%{--                                </button>--}%
%{--                            </div>--}%
%{--                        </div>--}%
%{--                    </div>--}%

                    <div class="row">
                        <div id="qaCarousel" class="carousel slide" data-bs-interval="" style="min-height: 382px">
                        <div class="carousel-inner">
                            <g:each in="${fieldList}" var="f" status="st">
                                <g:set var="name" value="${g.widgetName(field: f.field, recordIdx: f.recordIdx)}"/>
                                <g:set var="isActive" value="${!validator && st == 0 ? 'active' : ''}"/>
                                <div id="item-${name}" class="${isActive} carousel-item" data-item-index="${st}">

                                    <h5 class="mb-2"><g:if
                                            test="${!template.viewParams.hideQuestionNumbers}">${st + 1}/${fieldList.size()}:</g:if><g:fieldValue
                                            bean="${f.field}" field="uiLabel"/></h5>
                                    <div class="col-12">
                                        <p><g:fieldValue bean="${f.field}" field="helpText"/></p>
                                    </div>

                                    <div id="inline-validation-${name}" class="col-12" style="display: none;">
                                        <div class="alert alert-warning inline-validation"><span></span></div>
                                    </div>

                                    <div class="col-12">
                                        <g:renderWidgetHtml taskInstance="${taskInstance}" field="${f.field}"
                                                            recordValues="${recordValues}" recordIdx="${f.recordIdx}"
                                                            auxClass=""/>
                                    </div>

                                </div>
                            </g:each>
                        %{-- summary page last --}%
                            <div id="item-summary" class="carousel-item ${validator ? 'active' : ''}"
                                 data-item-index="${fieldList.size()}">
                                <h5 class="mb-2">Data summary</h5>
                                <div class="col-12"><p>
                                    Please confirm the following info
                                </p></div>
                                <div class="col-12">
                                    <table class="table table-striped confirmation-table">
                                        <thead>
                                        <tr>
                                            <th class="col-5">Category</th>
                                            <th class="col-7">Your choices</th>
                                        </tr>
                                        </thead>
                                        <tbody id="tbody-answer-summary">
                                        <g:each in="${fieldList}" var="f" status="st">
                                            <g:set var="name" value="${g.widgetName(field: f.field, recordIdx: f.recordIdx)}"/>
                                            <tr>
                                                <td><g:fieldValue bean="${f.field}" field="uiLabel"/></td>
                                                <td><span id="validation-${name}" class="float-end validation pointer"
                                                          data-target-field="${name}"></span><span id="display-${name}"></span>
                                                </td>
                                            </tr>
                                        </g:each>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    </div>
                    <div class="col-12">

                        <div class="transcription-actions">
                            <button id="carousel-control-right" type="button" class="btn btn-outline-secondary float-end ms-2 qt-next">
                                Next <i class="fa fa-chevron-right fa-sm"></i>
                            </button>

                            <g:if test="${validator}">
                                <div class="float-end">
                                    <button type="button" id="btnDontValidate" class="btn btn-secondary bvp-submit-button">
                                        ${message(code: 'default.button.dont.validate.label', default: 'Save partial validation')}
                                    </button>
                                    <button type="button" id="btnValidate" class="btn btn-success bvp-submit-button ms-2">
                                        ${message(code: 'default.button.validate.label', default: 'Submit validation')}
                                    </button>
                                </div>
                            </g:if>
                            <g:else>
                                <button id="btnSave" type="button" class="btn btn-primary float-end bvp-submit-button ms-2" style="display: none">
                                    Submit
                                </button>
                                <button id="btnSavePartial" type="button" class="btn btn-secondary float-end">Save Progress</button>
                            </g:else>

                            <button type="button" class="btn btn-outline-secondary float-start qt-previous"><i class="fa fa-chevron-left fa-sm"></i> Back</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div style="display: none;">
        <g:each in="${hiddenList}" var="f" status="st">
            <g:renderWidgetHtml taskInstance="${taskInstance}" field="${f.field}" recordValues="${recordValues}"
                                recordIdx="${f.recordIdx}" auxClass=""/>
        </g:each>
    </div>


    <script id="template-validation-badge" type="x-tmpl-mustache">
        <span class="badge bg-{{badgeType}}" title="{{title}}"><i class="fa fa-{{iconType}}"></i></span>
    </script>

    <script id="image-select-display" type="x-tmpl-mustache">
        {{#selected}}<span><img src="{{src}}" style="height:20px;width:20px;vertical-align:baseline;"></img> {{value}}</span>{{^last}}, {{/last}}{{/selected}}
    </script>

</content>

<asset:javascript src="dotdotdot" asset-defer=""/>
<asset:javascript src="mustache" asset-defer="" />

<asset:script type="text/javascript">
    jQuery(function($) {
        let interview = true;
        let fieldsSeen = {};

        // let carousel = $('#qaCarousel');
        // carousel.carousel({
        //     interval: false
        // });
        // Bootstrap 5  Carousel
        const carouselEl = document.getElementById('qaCarousel');
        const carousel = bootstrap.Carousel.getOrCreateInstance(carouselEl, {
            interval: false,
            ride: false
        });

        function syncSummary($target) {
            let $parent = $target.parent();
            let $display = $(bvp.escapeId('display-'+$target.prop('name')));

            if ($parent.hasClass('imageSelectWidget') || $parent.hasClass('imageMultiSelectWidget')) {
                let $selected = $parent.find('.selected');
                let selected = $selected.map(function(i) {
                    let $this = $(this);
                    let src = $this.find('img').attr('src');
                    let value = $this.data('image-select-value');
                    let last = $selected.length - 1 === i;
                    return {src: src, value: value, last: last};
                }).toArray();

                $display.empty();
                mu.appendTemplate($display, 'image-select-display', {selected: selected});
            } else {
                let v;
                if ($target.attr('type') === 'checkbox') {
                    v = $target.prop('checked');
                } else {
                    v = $target.val();
                }

                $display.text(v);
            }
        }

        $("input[name^='recordValues'], textarea[name^='recordValues']").change(function(e) {
            let $target = $(e.target);
            syncSummary($target);
            transcribeValidation.validateFields();
        }).each(function () {
            syncSummary($(this));
        });

        $('.qt-previous').click(function() {
            carousel.prev();
        });

        $('.qt-next').click(function() {
            console.log('next clicked');
            console.log(carousel);
            carousel.next();
        });

        carouselEl.addEventListener('slide.bs.carousel', function() {
            let inner = $(carouselEl).find('.carousel-inner');
            let active = $(document.activeElement);
            if ($.contains(inner, active)) {
                active.blur();
            }
            $('#qa-questions-pager').find('button.active').removeClass('active');
        });

        carouselEl.addEventListener('slid.bs.carousel', function(e) {
            let $c = $(e.target);
            let t = $c.find('.carousel-inner > .carousel-item.active');
            let idx = t.data('item-index');
            $('#qa-questions-pager').find('[data-bs-slide-to='+idx+']').closest('button').addClass('active');
            let lastitem = $(carouselEl).find('.carousel-inner .carousel-item:last');
            let ccr = $('#carousel-control-right');
            let save = $('#btnSave');

            if (save.length > 0) {
                if (t.is(lastitem)) {
                    save.removeAttr('disabled');
                    ccr.hide();
                    save.show();
                } else {
                    save.hide();
                    ccr.show();
                }
            }
            markSeenFields($c);
            $('.dotdotdot').dotdotdot();
        });

        $(document).not('input,textarea').keydown(function(e) {
            if (!interview || $(document.activeElement).is(":input,[contenteditable]")) return;
            // let $qaCarousel = $('#qaCarousel');
            switch(e.which) {
                case 37: // left
                    carousel.prev();
                    e.preventDefault(); // prevent the default action (scroll / move caret)
                    break;
                case 39: // right
                    carousel.next();
                    e.preventDefault(); // prevent the default action (scroll / move caret)
                    break;
                default: return; // exit this handler for other keys
            }
        });

        function markSeenFields(carousel) {
            if (!carouselEl) return;
            $(carouselEl).find('.carousel-inner > .carousel-item.active input[name^="recordValues."]')
                .each(function() { fieldsSeen[bvp.escapeIdPart($(this).prop('name'))] = true; });
        }

        // validation
        transcribeValidation.setErrorRenderFunctions(
            function(errorList) {
                $.each(errorList, function(index, error) {
                    let id = bvp.escapeIdPart(error.element.id);
                    let $parent = $('#validation-'+id);
                    let isError = error.type === 'Error';
                    let badgeType =  isError ? 'danger' : 'warning text-dark';
                    let iconType = "times"; // remove icon

                    let $badge = mu.appendTemplate($parent, "template-validation-badge", {
                        title: error.message,
                        badgeType: badgeType,
                        iconType: iconType
                    });
                    new bootstrap.Tooltip($badge);

                    if (fieldsSeen[id]) {
                        let $inline = $('#inline-validation-'+id);
                        $inline.css('display', 'block');
                        if (isError) {
                            $inline.addClass('alert-danger');
                        } else {
                            $inline.removeClass('alert-danger');
                        }
                        $inline.find('span').text(error.message);
                    }
                });
            },
            function() {
                $('#tbody-answer-summary').find('span.validation').empty();
                $('.inline-validation').css('display','none');
            }
        );

        $('#tbody-answer-summary').on('click', 'span.validation, span.validation > i', function() {
            let $this = $(this).closest('span.validation');
            let id = $this.attr('data-target-field');
            let idx = parseInt($('#item-' + bvp.escapeIdPart(id)).attr('data-item-index'));
            // $('#qaCarousel').carousel(idx);
            carousel.to(idx);
        });

        // enable tooltips
        new bootstrap.Tooltip($('[title]'));

        <g:set var="okCaption" value="Submit for validation anyway"/>
        <g:set var="cancelCaption" value="Let me fix the marked fields"/>
        <g:if test="${validator}">
            <g:set var="okCaption" value="Mark valid anyway"/>
            <g:set var="cancelCaption" value="Let me fix the marked fields"/>
        </g:if>

        postValidationFunction = function(validationResults) {
            if (validationResults.hasErrors || validationResults.hasWarnings) {
                bvp.showModal({
                    id: 'questionnaireSubmitConfirm',
                    title: 'Please confirm',
                    message: "<strong>Warning!</strong> There may be some problems with the fields indicated. If you are confident that the data entered accurately reflects the image, then you may continue to submit the record, otherwise please cancel the submission and correct the marked fields.",
                    buttons: {
                        cancel: { label: "${cancelCaption}", className: 'btn-outline-secondary' },
                        ok: { label: "${okCaption}", className: 'btn-primary', callback: function() { submitInvalid(); } }
                    }
                });
            }
        };

        transcribeValidation.validateFields();

        markSeenFields();
    });
</asset:script>

</g:applyLayout>