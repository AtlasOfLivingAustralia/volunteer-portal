<%@ page import="au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />

<div class="container-fluid">

    <div class="row-fluid">
        <div class="span12">
            <span id="journalPageButtons">
                <button type="button" class="btn btn-small" id="showPreviousJournalPage" title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><img src="${resource(dir:'images',file:'left_arrow.png')}"> previous image</button>
                <button type="button" class="btn btn-small" id="showNextJournalPage" title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>next image <img src="${resource(dir:'images',file:'right_arrow.png')}"></button>
                <button type="button" class="btn btn-small" id="rotateImage" title="Rotate the page 180 degrees">Rotate&nbsp;<img style="vertical-align: middle; margin: 0 !important;" src="${resource(dir:'images',file:'rotate.png')}"></button>
                <button type="button" class="btn btn-small" id="skip" title="Skip">Skip</button>
                <button type="button" class="btn btn-small" id="saveDraft" title="Save Draft">Save draft</button>
                <button type="button" class="btn btn-small" id="quit" title="Quit without saving">Quit without saving</button>
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
            <div id="qaCarousel" class="carousel slide" data-interval="">
                <ol class="carousel-indicators">
                    <g:each in="${fieldList}" var="f" status="st">
                        <g:set var="isActive" value="${st == 0 ? 'active' : ''}" />
                        <li data-target="#qaCarousel" data-slide-to="${st}" class="${isActive}"></li>
                    </g:each>
                </ol>
                <!-- Carousel items -->
                <div class="carousel-inner">
                    <g:each in="${fieldList}" var="f" status="st">
                        <g:set var="isActive" value="${st == 0 ? 'active' : ''}" />
                        <div class="${isActive} item">
                            <div style="margin-bottom: 10px;">
                                <h3>Q ${st+1}/${fieldList.size()}: <g:fieldValue bean="${f.field}" field="label" />?</h3>
                                <span><g:fieldValue bean="${f.field}" field="helpText" /></span>
                            </div>
                            <div>
                                <g:renderWidgetHtml taskInstance="${taskInstance}" field="${f.field}" recordValues="${recordValues}" recordIdx="${f.recordIdx}" auxClass="" />
                            </div>
                        </div>
                    </g:each>
                </div>
                <!-- Carousel nav -->
                <a class="carousel-control left" href="#qaCarousel" data-slide="prev">&lsaquo;</a>
                <a class="carousel-control right" href="#qaCarousel" data-slide="next">&rsaquo;</a>
            </div>
        </div>
    </div>

</div>

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
        $(document).not('input,textarea').keydown(function(e) {
            if (!interview || $(document.activeElement).is(":input,[contenteditable]")) return;
            switch(e.which) {
                case 37: // left
                    $('#qaCarousel').carousel('prev');
                    break;
                case 39: // right
                    $('#qaCarousel').carousel('next');
                    break;
                default: return; // exit this handler for other keys
            }
            e.preventDefault(); // prevent the default action (scroll / move caret)
        });
    });
</r:script>