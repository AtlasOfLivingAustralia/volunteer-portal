<%@ page import="au.org.ala.volunteer.Picklist; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />
<r:require modules="mustache, underscore, dotdotdot" />

<div id="ct-container" class="container-fluid extra-tall-image">

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

        <div class="span6" style="max-height: 580px; overflow-y: auto;">
            <div id="camera-trap-questions" class="" data-interval="">
                <div id="ct-landing" class="item clearfix active">
                    <h3>Step 1</h3>
                    <p>Are there any animals visible in the image?</p>
                    <div class="btn-group btn-group-vertical" data-toggle="buttons-radio">
                        <button class="btn input-medium btn-ct-landing">Setup</button>
                        <button class="btn btn-warning input-medium btn-ct-landing">Unsure</button>
                        <button class="btn btn-danger input-medium btn-ct-landing">No animals present</button>
                        <button id="btn-animals-present" class="btn btn-primary input-medium btn-ct-landing">Animals present</button>
                    </div>
                </div>
                <div id="ct-animals-present" class="item clearfix">
                    <h3>Step 2</h3>
                    <p>Select all animals present in the image.  If you a certain that a specimen is present, select the tick for the corresponding icon. If you think the specimen is present in the image but you are not sure then select the question mark icon instead.</p>
                    <div>
                        <g:set var="smImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.smallMammalsPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <g:set var="lmImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.largeMammalsPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <g:set var="reptilesImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.reptilesPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <g:set var="birdsImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.birdsPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <g:set var="otherImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.otherPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <ul class="nav nav-pills">
                            <li class="active"><a href="#small-mammal" data-toggle="pill">Small Mammals</a></li>
                            <li><a href="#large-mammal" data-toggle="pill">Large Mammals</a></li>
                            <li><a href="#reptile" data-toggle="pill">Reptiles</a></li>
                            <li><a href="#bird" data-toggle="pill">Birds</a></li>
                            <li><a href="#other" data-toggle="pill">Others</a></li>
                        </ul>
                        <div class="pill-content">
                            <div class="pill-pane fade in active" id="small-mammal">
                                <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: smImageInfos, picklistId: template.viewParams.smallMammalsPicklistId?.toLong()]}" />
                            </div>
                            <div class="pill-pane fade" id="large-mammal">
                                <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: lmImageInfos, picklistId: template.viewParams.largeMammalsPicklistId?.toLong()]}" />
                            </div>
                            <div class="pill-pane fade" id="reptile">
                                <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: reptilesImageInfos, picklistId: template.viewParams.reptilesPicklistId?.toLong()]}" />
                            </div>
                            <div class="pill-pane fade" id="bird">
                                <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: birdsImageInfos, picklistId: template.viewParams.birdsPicklistId?.toLong()]}" />
                            </div>
                            <div class="pill-pane fade" id="other">
                                <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: otherImageInfos, picklistId: template.viewParams.otherPicklistId?.toLong()]}" />
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
    <div class="thumbnail ct-thumbnail" data-image-select-key="{{key}}" data-image-select-value="{{value}}">
        {{#success}}
        <span class="ct-badge ct-badge-sure badge badge-success selected"><i class="icon-white icon-ok-sign"></i></span>
        <span class="ct-badge ct-badge-uncertain badge"><i class="icon-white icon-question-sign"></i></span>
        {{/success}}
        {{#uncertain}}
        <span class="ct-badge ct-badge-sure badge"><i class="icon-white icon-ok-sign"></i></span>
        <span class="ct-badge ct-badge-uncertain badge badge-warning selected"><i class="icon-white icon-question-sign"></i></span>
        {{/uncertain}}
        <img src="{{squareThumbUrl}}" alt="{{value}}">
        <div>
            <span class="ct-caption" title="{{value}}">{{value}}</span>
        </div>
    </div>
</div>
</script>

<r:script>
  jQuery(function($) {
    var active = 0;
    var smImageInfos = <cl:json value="${smImageInfos.infos}" />
        ,lmImageInfos = <cl:json value="${lmImageInfos.infos}" />
        ,reptilesImageInfos = <cl:json value="${reptilesImageInfos.infos}" />
        ,birdsImageInfos = <cl:json value="${birdsImageInfos.infos}" />
        ,otherImageInfos = <cl:json value="${otherImageInfos.infos}" />;

    var smItems = <cl:json value="${smImageInfos.items}" />
        ,lmItems = <cl:json value="${lmImageInfos.items}" />
        ,reptilesItems = <cl:json value="${reptilesImageInfos.items}" />
        ,birdsItems = <cl:json value="${birdsImageInfos.items}" />
        ,otherItems = <cl:json value="${otherImageInfos.items}" />;

    var values = [].concat(_.pluck(smItems, 'value'), _.pluck(lmItems, 'value'), _.pluck(reptilesItems, 'value'), _.pluck(birdsItems, 'value'), _.pluck(otherItems, 'value'));

    var template = $('#selected-item-template').html();
    Mustache.parse(template);   // optional, speeds up future uses

    var selections = {};

    function page(id) {
      return {'page': id};
    }

    if (history.replaceState)
      history.replaceState(page('ct-landing'), window.document.title);

    $('a[data-toggle="pill"]').on('shown', function (e) {
      $('.ct-caption').dotdotdot();
      //e.target // activated tab
      //e.relatedTarget // previous tab
    });

    $('#btn-animals-present').click(function(e) {
      e.preventDefault();
      $('#ct-landing').removeClass('active').addClass('fading');
      $('#ct-animals-present').addClass('active');
      if (history.pushState)
        history.pushState(page('ct-animals-present'), window.document.title);
    });

    $('#camera-trap-questions').on('transitionend', '.item.fading', function(e) {
      $(e.target).removeClass('fading');
      $('.ct-caption').dotdotdot();
    });

    $('.btn-ct-landing').click(function(e) {
      e.preventDefault();
    });

    var ctBadges = {1: 'ct-badge-sure', 0.5: 'ct-badge-uncertain'};
    var badges = {1: 'badge-success', 0.5: 'badge-warning'};
    $('#ct-container')
    .on('click', '.ct-badge-sure', function(e) {
      ctBadgeClick(e, 1);
    })
    .on('click', '.ct-badge-uncertain', function(e) {
      ctBadgeClick(e, 0.5);
    });

    function ctBadgeClick(e, selectionCertainty) {
      var t = $(e.target);
      var badge = t.closest('.badge');

      var selectedThumbnail = t.closest('.thumbnail');
      var value = selectedThumbnail.attr('data-image-select-value');
      var imageKey = selectedThumbnail.attr('data-image-select-key');
      if (selections.hasOwnProperty(value) && selections[value].certainty == selectionCertainty) {
        delete selections[value];
      } else {
        selections[value] = { certainty: selectionCertainty, key: imageKey };
      }
      syncSelectionState();
    }

    function valueToBadgeSelector(v, i, a) { return '.thumbnail[data-image-select-value="'+v+'"] .badge.' + ctBadges[selections[v].certainty] }
    function valueToSelector(v, i, a) { return '.thumbnail[data-image-select-value="'+v+'"]' }

    function addSelectionToContainer(sel, selElem) {
      var certainty = selections[sel].certainty;
      var imageKey = selections[sel].key;
      var imageUrl = (smImageInfos[imageKey] || lmImageInfos[imageKey] || reptilesImageInfos[imageKey] || birdsImageInfos[imageKey] || otherImageInfos[imageKey]).squareThumbUrl;
      var opts = {
        squareThumbUrl: imageUrl,
        value: sel,
        key: imageKey,
        success: certainty == 1,
        uncertain: certainty < 1
      };
      var rendered = Mustache.render(template, opts);
      var jqRendered = $(rendered);
      jqRendered.appendTo(selElem);
      //jqRendered.dotdotdot();
      $('.ct-caption').dotdotdot();
    }

    function syncSelectionState() {
      var ctContainer = $('#ct-container');
      var selectedValues = _.keys(selections);
      var badgeSelector = _.map(selectedValues, valueToBadgeSelector).join(', ');
      var nonSelector = _.map(_.difference(values, selectedValues), valueToSelector).join(', ');

      var selElem = $('#ct-selection-grid');
      var uiSelectedValues = selElem.find('.thumbnail').map(function(i,e) { return $(e).data('image-select-value'); }).toArray();

      var add = _.difference(selectedValues, uiSelectedValues);

      for (var i = 0; i < add.length; ++i) {
        addSelectionToContainer(add[i], selElem);
      }
      selElem.find(nonSelector).parent().remove();

      ctContainer.find('.thumbnail[data-image-select-value] .badge').removeClass('selected ' + _.values(badges).join(' '));
      ctContainer.find(badgeSelector).addClass('selected');
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