<%@ page import="au.org.ala.volunteer.Picklist; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />
<r:require module="mustache" />

<div class="container-fluid tall-image">

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

        %{--<g:set var="fieldList" value="${g.templateFields(category: FieldCategory.dataset, template:  template)}" />--}%
        %{--<g:set var="hiddenList" value="${g.templateFields(category: FieldCategory.dataset, template:  template, hidden: true)}" />--}%

        <div class="span6" style="max-height: 560px; overflow-y: auto;">
            <div id="camera-trap-questions" class="" data-interval="">
                <div id="ct-landing" class="item clearfix active">
                    <h3>Step 1</h3>
                    <p>Are there any specimens visible in the image?</p>
                    <div class="btn-group btn-group-vertical" data-toggle="buttons-radio">
                        <button class="btn input-medium btn-ct-landing">Setup</button>
                        <button class="btn btn-warning input-medium btn-ct-landing">Unsure</button>
                        <button class="btn btn-danger input-medium btn-ct-landing">No animals present</button>
                        <button id="btn-animals-present" class="btn btn-primary input-medium btn-ct-landing">Animals present</button>
                    </div>
                </div>
                <div id="ct-animals-present" class="item clearfix">
                    <h3>Step 2</h3>
                    <p>Select all specimens present in the image.  If you a certain that a specimen is present, select the tick for the corresponding icon. If you think the specimen is present in the image but you are not sure then select the question mark icon instead.</p>
                    <div>
                        <ul class="nav nav-pills">
                            <li class="active"><a href="#small-mammal" data-toggle="pill">Small Mammal</a></li>
                            <li><a href="#large-mammal" data-toggle="pill">Large Mammal</a></li>
                            <li><a href="#reptile" data-toggle="pill">Reptile</a></li>
                            <li><a href="#bird" data-toggle="pill">Bird</a></li>
                            <li><a href="#other" data-toggle="pill">Other</a></li>
                        </ul>
                        <div class="pill-content">
                            <div class="pill-pane fade in active" id="small-mammal">
                                <div class="itemgrid">
                                    <g:set var="smImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.smallMammalsPicklistId?.toLong()), project: taskInstance?.project)}" />
                                    <g:each in="${smImageInfos.items}" var="piItem">
                                        <div class="griditem bvpBadge">
                                            <div class="thumbnail" data-image-select-value="${piItem.value}">
                                                <img src="${smImageInfos.infos[piItem.key].squareThumbUrl}" alt="${piItem.value}">
                                                <div>
                                                    <span class="ct-badge ct-badge-sure badge pull-left"><i class="icon-white icon-ok-sign"></i></span>
                                                    <span>${piItem.value}</span>
                                                    <span class="ct-badge ct-badge-uncertain badge pull-right"><i class="icon-white icon-question-sign"></i></span>
                                                </div>
                                            </div>
                                        </div>
                                    </g:each>
                                </div>
                            </div>
                            <div class="pill-pane fade" id="large-mammal">
                                <p>TODO Large Mammals</p>
                            </div>
                            <div class="pill-pane fade" id="reptile">
                                <p>TODO Reptiles</p>
                            </div>
                            <div class="pill-pane fade" id="bird">
                                <p>TODO Birds</p>
                            </div>
                            <div class="pill-pane fade" id="other">
                                <p>TODO Other</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span11">
            <h3>My selections</h3>
        </div>
        <div class="span1">
            <div style="margin: 10px 0; line-height: 40px;">
                <button class="btn btn-primary">Submit</button>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <div class="well">
                <div id="ct-selection-grid" class="itemgrid">

                </div>
            </div>
        </div>
    </div>

</div>

<script id="selected-item-template" type="x-tmpl-mustache">
<div class="griditem bvpBadge">
    <div class="thumbnail">
        <img src="{{squareThumbUrl}}" alt="{{value}}">
        <div>
            {{#success}}
            <span class="badge badge-success pull-left"><i class="icon-white icon-ok-sign"></i></span>
            {{/success}}
            <span>{{value}}</span>
            {{#uncertain}}
            <span class="badge badge-warning pull-right"><i class="icon-white icon-question-sign"></i></span>
            {{/uncertain}}
        </div>
    </div>
</div>
</script>

<r:script>
  jQuery(function($) {
    var active = 0;
    var interview = true;
    var i = 0;

    var template = $('#selected-item-template').html();
    Mustache.parse(template);   // optional, speeds up future uses

    var selections = {};

    function page(id) {
      return {'page': id};
    }

    if (history.replaceState)
      history.replaceState(page('ct-landing'), window.document.title);

    $('#btn-animals-present').click(function(e) {
      e.preventDefault();
      $('#ct-landing').removeClass('active').addClass('fading');
      $('#ct-animals-present').addClass('active');
      if (history.pushState)
        history.pushState(page('ct-animals-present'), window.document.title);
    });

    $('#camera-trap-questions').on('transitionend', '.item.fading', function(e) {
      $(e.target).removeClass('fading');
    });

    $('.btn-ct-landing').click(function(e) {
      e.preventDefault();
    });

    var badges = ['badge-success', 'badge-warning'];
    $('.ct-badge-sure').click(function(e) {
      ctBadgeClick(e, 0, 1);
    });
    $('.ct-badge-uncertain').click(function(e) {
      ctBadgeClick(e, 1, 0.5);
    });

    function ctBadgeClick(e, badgeClass, selectionCertainty) {
      var t = $(e.target);
      var badge = t.closest('.badge');

      var value = t.closest('.thumbnail').attr('data-image-select-value');
      badge.siblings('.badge').removeClass(badges.join(" "));
      if (selections.hasOwnProperty(value) && selections[value] == selectionCertainty) {
        badge.removeClass(badges[badgeClass]);
        delete selections[value];
      } else {
        badge.addClass(badges[badgeClass]);
        selections[value] = selectionCertainty;
      }
      syncSelectionState();
    }

    function syncSelectionState() {
      var selElem = $('#ct-selection-grid');
      selElem.empty(); // TODO just the diffs ma'am
      for (var sel in selections) {
        if( selections.hasOwnProperty( sel ) ) {
            var opts = {
                squareThumbUrl: "",
                value: sel,
                success: selections[sel] == 1,
                uncertain: selections[sel] < 1
            };
            var rendered = Mustache.render(template, opts);
            $(rendered).appendTo(selElem);
        }
      }
    }

    window.onpopstate = function(e) {
      var state = window.history.state;
      if (state.page) {
        $('#camera-trap-questions').children('.active').removeClass('active').addClass('fading');
        $('#'+state.page).addClass('active');
      }
    }
  });
</r:script>