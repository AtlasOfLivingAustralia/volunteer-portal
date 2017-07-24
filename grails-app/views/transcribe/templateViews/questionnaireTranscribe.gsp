<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <title><cl:pageTitle title="${(validator) ? message(code: 'transcribe.templateViews.all.validate') : message(code: 'transcribe.templateViews.all.expedition')} ${taskInstance?.project?.name}" /></title>
    </head>
    <content tag="templateView">
        <div class="col-sm-6">
            <div class="media-container">
                <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                    <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                        <g:imageViewer multimedia="${multimedia}"/>
                    </g:if>
                </g:each>
            </div>
        </div>

        <g:set var="fieldList" value="${g.templateFields(category: FieldCategory.dataset, template: template)}"/>
        <g:set var="hiddenList"
               value="${g.templateFields(category: FieldCategory.dataset, template: template, hidden: true)}"/>

        <div class="col-sm-6">
            <div id="qa-questions-pager" class="stepwizard">
                <div class="stepwizard-row">
                    <div class="stepwizard-step">
                        <span>Steps</span>
                        <g:each in="${fieldList}" var="f" status="st">
                            <g:set var="isActive" value="${!validator && st == 0 ? 'active' : ''}"/>
                            <button type="button" class="btn btn-circle btn-default ${isActive}" data-target="#qaCarousel" data-slide-to="${st}">${st + 1}</button>
                        </g:each>
                        <button type="button" class="btn btn-circle btn-default ${validator ? 'active' : ''}"
                                                                    title="${message(code: 'questionnarie.summary.button.tooltip', default: 'Click any time to view and submit your choices')}"
                                                                    data-container="body" data-target="#qaCarousel"
                                                                    data-slide-to="${fieldList.size()}">${fieldList.size() + 1}</button>
                    </div>
                </div>
            </div>
            <div class="row"> %{-- style="margin-bottom: 10px;" --}%
                <div id="qaCarousel" class="carousel slide" data-interval="" style="min-height: 382px">
                    <div class="carousel-inner">
                        <g:each in="${fieldList}" var="f" status="st">
                            <g:set var="name" value="${g.widgetName(field: f.field, recordIdx: f.recordIdx)}"/>
                            <g:set var="isActive" value="${!validator && st == 0 ? 'active' : ''}"/>
                            <div id="item-${name}" class="${isActive} item" data-item-index="${st}">

                                <legend><g:if
                                        test="${!template.viewParams.hideQuestionNumbers}">${st + 1}/${fieldList.size()}:</g:if><g:fieldValue
                                        bean="${f.field}" field="uiLabel"/></legend>
                                <div class="col-xs-12">
                                    <p><g:fieldValue bean="${f.field}" field="helpText"/></p>
                                </div>

                                <div id="inline-validation-${name}" class="col-xs-12" style="display: none;">
                                    <div class="alert alert-warning alert-block inline-validation"><span></span></div>
                                </div>

                                <div class="col-xs-12">
                                    <g:renderWidgetHtml taskInstance="${taskInstance}" field="${f.field}"
                                                        recordValues="${recordValues}" recordIdx="${f.recordIdx}"
                                                        auxClass=""/>
                                </div>

                            </div>
                        </g:each>
                    %{-- summary page last --}%
                        <div id="item-summary" class="item ${validator ? 'active' : ''}"
                             data-item-index="${fieldList.size()}">
                            <legend><g:message code="transcribe.templateViews.questionnaireTranscribe.data_summary"/></legend>
                            <div class="col-xs-12"><p>
                                <g:message code="transcribe.templateViews.questionnaireTranscribe.please_confirm_info"/>
                            </p></div>
                            <div class="col-xs-12">
                                <table class="table table-striped confirmation-table">
                                    <thead>
                                    <tr>
                                        <th class="col-xs-5"><g:message code="transcribe.templateViews.questionnaireTranscribe.category"/></th>
                                        <th class="col-xs-7"><g:message code="transcribe.templateViews.questionnaireTranscribe.your_choice"/></th>
                                    </tr>
                                    </thead>
                                    <tbody id="tbody-answer-summary">
                                    <g:each in="${fieldList}" var="f" status="st">
                                        <g:set var="name" value="${g.widgetName(field: f.field, recordIdx: f.recordIdx)}"/>
                                        <tr>
                                            <td><g:fieldValue bean="${f.field}" field="uiLabel"/></td>
                                            <td><span id="validation-${name}" class="pull-right validation pointer"
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
                <div class="col-xs-12">

                    <div class="transcription-actions">
                        <button id="carousel-control-right" type="button" class="btn btn-default pull-right btn-next qt-next"><g:message code="default.next"/> <i class="fa fa-chevron-right fa-sm"></i></button>
                        <g:if test="${validator}">
                            <div class="btn-group pull-right">
                                <button type="button" id="btnValidate" class="btn btn-default btn-next bvp-submit-button"><i
                                        class="icon-ok icon-white"></i>&nbsp;${message(code: 'default.button.validate.label', default: 'Mark as Valid')}
                                </button>
                                <button type="button" id="btnDontValidate" class="btn btn-danger btn-next bvp-submit-button"><i
                                        class="icon-remove icon-white"></i>&nbsp;${message(code: 'default.button.dont.validate.label', default: 'Mark as Invalid')}
                                </button>
                            </div>
                        </g:if>
                        <g:else>
                            <button id="btnSave" type="button" class="btn btn-default pull-right btn-next bvp-submit-button" style="display: none"><g:message code="default.submit"/> <i class="fa fa-chevron-right fa-sm"></i></button>
                        </g:else>
                        <button id="btnSavePartial" type="button" class="btn btn-default pull-right"> <i class="fa fa-check fa-sm"></i></button>
                        <button type="button" class="btn btn-default pull-left qt-previous"><i class="fa fa-chevron-left fa-sm"></i> <g:message code="default.back"/></button>
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
    <span class="badge badge-{{badgeType}}" title="{{title}}"><i class="icon-{{iconType}} icon-white"></i></span>
</script>

<script id="image-select-display" type="x-tmpl-mustache">
    {{#selected}}<span><img src="{{src}}" style="height:20px;width:20px;vertical-align:baseline;"></img> {{value}}</span>{{^last}}, {{/last}}{{/selected}}
</script>
        <asset:javascript src="dotdotdot" asset-defer=""/>
        <asset:javascript src="mustache" asset-defer="" />
        <asset:javascript src="bootbox" asset-defer="" />
<asset:script type="text/javascript">
    jQuery(function($) {
        var active = 0;
        var interview = true;
        var fieldsSeen = {};
        var i = 0;
        var n = ${fieldList.size()};
        var carousel = $('#qaCarousel');

        carousel.carousel({
          interval: false
        });

        function syncSummary($target) {
          var $parent = $target.parent();
          var $display = $(bvp.escapeId('display-'+$target.prop('name')));

          if ($parent.hasClass('imageSelectWidget') || $parent.hasClass('imageMultiSelectWidget')) {
            var $selected = $parent.find('.selected');
            var selected = $selected.map(function(i,e) {
                var $this = $(this);
                var src = $this.find('img').attr('src');
                var value = $this.data('image-select-value');
                var last = $selected.length - 1 == i;
                return {src: src, value: value, last: last};
            }).toArray();

            $display.empty();
            mu.appendTemplate($display, 'image-select-display', {selected: selected});
          } else {
            var v;
            if ($target.attr('type') === 'checkbox') {
              v = e.target.checked;
            } else {
              v = $target.val();
            }

            $display.text(v);
          }
        }

        $("input[name^='recordValues'], textarea[name^='recordValues']").change(function(e) {
          var $target = $(e.target);
          syncSummary($target);
          transcribeValidation.validateFields();
        }).each(function () {
          syncSummary($(this));
        });

        $('.qt-previous').click(function(e) {
            carousel.carousel('prev');
        });
        $('.qt-next').click(function(e) {
            carousel.carousel('next');
        });

        carousel.on('slide.bs.carousel', function(e) {
            var inner = carousel.find('.carousel-inner');
            var active = $(document.activeElement);
            if ($.contains(inner, active)) {
                active.blur();
            }
        });
        carousel.on('slide.bs.carousel', function(e) {
            $('#qa-questions-pager').find('button.active').removeClass('active');
        });
        carousel.on('slid.bs.carousel', function(e) {
            var $c = $(e.target);
            var t = $c.find('.carousel-inner > .item.active');
            var idx = t.data('item-index');
            $('#qa-questions-pager').find('[data-slide-to='+idx+']').closest('button').addClass('active');
            var lastitem = $('.carousel-inner .item:last');
            var ccr = $('#carousel-control-right');
            var save = $('#btnSave');
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
        });
        carousel.on('slid.bs.carousel', function(e) {
            $('.dotdotdot').dotdotdot();
        });
        $('.dotdotdot').dotdotdot();
        $(document).not('input,textarea').keydown(function(e) {
            if (!interview || $(document.activeElement).is(":input,[contenteditable]")) return;
            var $qaCarousel = $('#qaCarousel');
            switch(e.which) {
                case 37: // left
                    $qaCarousel.carousel('prev');
                    e.preventDefault(); // prevent the default action (scroll / move caret)
                    break;
                case 39: // right
                    $qaCarousel.carousel('next');
                    e.preventDefault(); // prevent the default action (scroll / move caret)
                    break;
                default: return; // exit this handler for other keys
            }
        });

        function markSeenFields(carousel) {
          if (!carousel) carousel = $('#qaCarousel');
          carousel.find('.carousel-inner > .item.active input[name^="recordValues."]').each(function() { fieldsSeen[bvp.escapeIdPart($(this).prop('name'))] = true; });
        }

        // validation
        transcribeValidation.setErrorRenderFunctions(
          function(errorList) {
            $.each(errorList, function(index, error) {
              var id = bvp.escapeIdPart(error.element.id);
              var $parent = $('#validation-'+id);
              var isError = error.type === 'Error';
              var badgeType =  isError ? 'important' : 'warning';
              var iconType = "remove";
              var $badge = mu.appendTemplate($parent, "template-validation-badge", {
                title: error.message,
                badgeType: badgeType,
                iconType: iconType
              });
              $badge.tooltip();

              if (fieldsSeen[id]) {
                var $inline = $('#inline-validation-'+id);
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

        $('#tbody-answer-summary').on('click', 'span.validation, span.validation > i', function(e) {
          var $this = $(this).closest('span.validation');
          var id = $this.attr('data-target-field');
          var idx = parseInt($('#item-' + bvp.escapeIdPart(id)).attr('data-item-index'));
          $('#qaCarousel').carousel(idx);
        });

        // enable tooltips
        $('[title]').tooltip();

    <g:set var="okCaption" value="Submit for validation anyway"/>
    <g:set var="cancelCaption" value="Let me fix the marked fields"/>
    <g:if test="${validator}">
        <g:set var="okCaption" value="Mark valid anyway"/>
        <g:set var="cancelCaption" value="Let me fix the marked fields"/>
    </g:if>
    postValidationFunction = function(validationResults) {
      if (validationResults.hasErrors || validationResults.hasWarnings) {
        bootbox.confirm(
          "<strong>Warning!</strong> There may be some problems with the fields indicated. If you are confident that the data entered accurately reflects the image, then you may continue to submit the record, otherwise please cancel the submission and correct the marked fields.",
              "${cancelCaption}", "${okCaption}", function(answer) {
                if (answer) submitInvalid();
              });
          }
        };

        transcribeValidation.validateFields();
        markSeenFields();
    });
</asset:script>
    </content>
</g:applyLayout>