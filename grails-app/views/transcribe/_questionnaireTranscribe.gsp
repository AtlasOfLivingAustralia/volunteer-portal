<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />
<r:require modules="dotdotdot, mustache-util" />
<div class="container-fluid qa-transcribe tall-image">

    <div class="row-fluid">
        <div class="span12">
            <span id="journalPageButtons">

                <button type="button" class="btn btn-small" id="showPreviousJournalPage" title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><img src="${resource(dir:'images',file:'left_arrow.png')}"> show previous</button>
                <button type="button" class="btn btn-small" id="showNextJournalPage" title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>show next <img src="${resource(dir:'images',file:'right_arrow.png')}"></button>
                <button type="button" class="btn btn-small" id="rotateImage" title="Rotate the page 180 degrees">Rotate&nbsp;<img style="vertical-align: middle; margin: 0 !important;" src="${resource(dir:'images',file:'rotate.png')}"></button>
                <button type="button" class="btn btn-small bvp-submit-button" id="showNextFromProject">Skip</button>
                <g:if test="${validator}">
                    <g:if test="${validator}">
                        <a href="${createLink(controller: "task", action:"projectAdmin", id:taskInstance?.project?.id, params: params.clone())}" />
                    </g:if>
                </g:if>
                <g:else>
                    <button type="button" class="btn btn-small" id="btnSavePartial" class="btn bvp-submit-button">${message(code: 'default.button.save.partial.label', default: 'Save draft')}</button>
                    <button type="button" class="btn btn-small" id="btnQuit" class="btn bvp-quit-button">${message(code: 'default.button.quit.label', default: 'Quit')}</button>
                </g:else>
                <vpf:taskTopicButton task="${taskInstance}" class="btn-info btn-small"/>
            </span>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span6">
            <div class="well well-small">
                <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                    <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                        <g:imageViewer multimedia="${multimedia}" />
                    </g:if>
                </g:each>
            </div>
        </div>

        <g:set var="fieldList" value="${g.templateFields(category: FieldCategory.dataset, template:  template)}" />
        <g:set var="hiddenList" value="${g.templateFields(category: FieldCategory.dataset, template:  template, hidden: true)}" />

        <div class="span6">
            <div class="well well-small">
                <div id="qaCarousel" class="carousel slide" data-interval="">
                    <div class="carousel-inner">
                        <g:each in="${fieldList}" var="f" status="st">
                            <g:set var="name" value="${g.widgetName(field: f.field, recordIdx: f.recordIdx)}" />
                            <g:set var="isActive" value="${!validator && st == 0 ? 'active' : ''}" />
                            <div id="item-${name}" class="${isActive} item" data-item-index="${st}">
                                <div style="margin-bottom: 10px;">
                                    <h3><g:if test="${!template.viewParams.hideQuestionNumbers}">${st+1}/${fieldList.size()}: </g:if><g:fieldValue bean="${f.field}" field="uiLabel" /></h3>
                                    <span><g:fieldValue bean="${f.field}" field="helpText" /></span>
                                    <div id="inline-validation-${name}" class="alert alert-block inline-validation" style="display: none;"><span></span></div>
                                </div>
                                <div>
                                    <g:renderWidgetHtml taskInstance="${taskInstance}" field="${f.field}" recordValues="${recordValues}" recordIdx="${f.recordIdx}" auxClass="" />
                                </div>
                            </div>
                        </g:each>
                        %{-- summary page last --}%
                        <div id="item-summary" class="item ${validator ? 'active' : ''}" data-item-index="${fieldList.size()}">
                            <h4>Data summary</h4>
                            <table class="table table-condensed">
                                <thead>
                                <tr>
                                    <th class="span2">Category</th>
                                    <th class="span4">Your choices</th>
                                </tr>
                                </thead>
                                <tbody id="tbody-answer-summary">
                                <g:each in="${fieldList}" var="f" status="st">
                                    <g:set var="name" value="${g.widgetName(field: f.field, recordIdx: f.recordIdx)}" />
                                    <tr>
                                        <td><g:fieldValue bean="${f.field}" field="uiLabel" /></td>
                                        <td><span id="validation-${name}" class="pull-right validation pointer" data-target-field="${name}"></span><span id="display-${name}"></span></td>
                                    </tr>
                                </g:each>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
                <div class="pagination text-center" style="height:36px;">
                    <ul style="margin-bottom: 6px;">
                        <li><a href="#qaCarousel" data-slide="prev" style="width:69px;">&larr; Previous</a></li>
                        <g:each in="${fieldList}" var="f" status="st">
                            <g:set var="isActive" value="${!validator && st == 0 ? 'active' : ''}" />
                            <li class="${isActive}"><a href="#qaCarousel" data-target="#qaCarousel" data-slide-to="${st}">${st+1}</a></li>
                        </g:each>
                        <li class="${validator ? 'active' : ''}"><a href="#qaCarousel" data-target="#qaCarousel" data-slide-to="${fieldList.size()}">Summary</a></li>
                        %{--${fieldList.size()+1}--}%
                        <li>
                            <a id="carousel-control-right" href="#qaCarousel" data-slide="next" style="width:69px;">Next &rarr;</a>
                            <button type="button" id="btnSave" class="btn btn-primary bvp-submit-button" ${'disabled="true"'} style="width:93px; border-top-left-radius: 0; border-bottom-left-radius: 0; border-left-width: 0; display: none;">${message(code: 'transcribe.button.shortsubmit.label', default: 'Submit')}</button>
                        </li>
                    </ul>
                </div>

        </div>
    </div>

    %{--<div class="row-fluid">
        <div class="span6">
        </div>
    </div>--}%

    <div style="display: none;">
        <g:each in="${hiddenList}" var="f" status="st">
            <g:renderWidgetHtml taskInstance="${taskInstance}" field="${f.field}" recordValues="${recordValues}" recordIdx="${f.recordIdx}" auxClass="" />
        </g:each>
    </div>

</div>

<script id="template-validation-badge" type="x-tmpl-mustache">
    <span class="badge badge-{{badgeType}}" title="{{title}}"><i class="icon-{{iconType}} icon-white"></i></span>
</script>

<script id="image-select-display" type="x-tmpl-mustache">
    {{#selected}}<span><img src="{{src}}" style="height:20px;width:20px;vertical-align:baseline;"></img> {{value}}</span>{{^last}}, {{/last}}{{/selected}}
</script>

<r:script>
    jQuery(function($) {
        var active = 0;
        var interview = true;
        var i = 0;
        var n = ${fieldList.size()};
        var carousel = $('#qaCarousel');

        carousel.carousel({
          interval: false
        });

        $("input[name^='recordValues'], textarea[name^='recordValues']").change(function(e) {
          var $target = $(e.target);
          var $parent = $target.parent();
          var $display = $(bvp.escapeId('display-'+e.target.name));

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

          transcribeValidation.validateFields();
        });

        $('.qt-previous').click(function(e) {
            i = (i + n - 1) % n;

            showHideRows();
        });
        $('.qt-next').click(function(e) {
            i = (i + 1) % n;
            showHideRows();
        });

        function showHideRows() {
          $('.qt-row').addClass('hidden');
          $('.qt-row.row-'+i).removeClass('hidden');
        }

        $('#qa-list').click(function(e) {
          if (interview) {
              var qac = $('#qaCarousel');
              qac.removeClass('carousel slide');
              $('.carousel-control').addClass('hidden');
              //var ci = ;
              active = $('.carousel-inner > .item.active').index();
              $('.carousel-inner > .item').addClass('active');
              $('#qa-list').addClass('active');
              $('#qa-interview').removeClass('active');
              qac.find('.carousel-indicators').hide();
              interview = false;
          }
        });

        $('#qa-interview').click(function(e) {
            if (!interview) {
                var qac = $('#qaCarousel');
                qac.addClass('carousel slide');
                $('.carousel-control').removeClass('hidden');
                var ci = $('.carousel-inner > .item');
                //active = ci.index('.active');
                ci.removeClass('active');
                $('.carousel-inner > .item:eq('+active+')').addClass('active');
                $('#qa-list').removeClass('active');
                $('#qa-interview').addClass('active');
                qac.find('.carousel-indicators').show();
                interview = true;
            }
        });
        carousel.on('slide', function(e) {
            var inner = carousel.find('.carousel-inner');
            var active = $(document.activeElement);
            if ($.contains(inner, active)) {
                active.blur();
            }
        });
        carousel.on('slide', function(e) {
            $('.qa-transcribe .pagination').find('li.active').removeClass('active');
        });
        carousel.on('slid', function(e) {
            var t = $(e.target).find('.carousel-inner > .item.active');
            var idx = t.data('item-index');
            $('.qa-transcribe .pagination').find('[data-slide-to='+idx+']').closest('li').addClass('active');
            var lastitem = $('.carousel-inner .item:last');
            var ccr = $('#carousel-control-right');
            var save = $('#btnSave');
            if (t.is(lastitem)) {
                save.removeAttr('disabled');
                ccr.hide();
                save.show();
            } else {
                save.hide();
                ccr.show();
            }
        });
        carousel.on('slid', function(e) {
            $('.dotdotdot').dotdotdot();
        });
        $('.dotdotdot').dotdotdot();
        $(document).not('input,textarea').keydown(function(e) {
            if (!interview || $(document.activeElement).is(":input,[contenteditable]")) return;
            var $qaCarousel = $('#qaCarousel');
            switch(e.which) {
                case 37: // left
                    $qaCarousel.carousel('prev');
                    break;
                case 39: // right
                    $qaCarousel.carousel('next');
                    break;
                default: return; // exit this handler for other keys
            }
            e.preventDefault(); // prevent the default action (scroll / move caret)
        });

        // validation
        transcribeValidation.setErrorRenderFunctions(
          function(errorList) {
            $.each(errorList, function(index, error) {
              var id = bvp.escapeIdPart(error.element.id);
              var $parent = $('#validation-'+id);
              var isError = error.Type === 'Error';
              var badgeType =  isError ? 'important' : 'warning';
              var iconType = "remove";
              mu.appendTemplate($parent, "template-validation-badge", {
                title: error.message,
                badgeType: badgeType,
                iconType: iconType
              });

              var $inline = $('#inline-validation-'+id);
              $inline.css('display', 'block');
              if (isError) {
                $inline.addClass('alert-error');
              } else {
                $inline.removeClass('alert-error');
              }
              $inline.find('span').text(error.message);
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

        transcribeValidation.validateFields();
    });
</r:script>