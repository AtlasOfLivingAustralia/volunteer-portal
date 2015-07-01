<%@ page import="au.org.ala.volunteer.Picklist; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />
<r:require modules="mustache-util, underscore, dotdotdot" />

<div id="ct-container" class="container-fluid extra-tall-image">

    <div class="row-fluid">
        <div class="span12">
            <span id="journalPageButtons">
                <button type="button" class="btn btn-small" id="showPreviousJournalPage" title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><img src="${resource(dir:'images',file:'left_arrow.png')}"> previous image</button>
                <button type="button" class="btn btn-small" id="showNextJournalPage" title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>next image <img src="${resource(dir:'images',file:'right_arrow.png')}"></button>
                <button type="button" class="btn btn-small" id="rotateImage" title="Rotate the page 180 degrees">Rotate&nbsp;<img style="vertical-align: middle; margin: 0 !important;" src="${resource(dir:'images',file:'rotate.png')}"></button>
                <button type="button" class="btn btn-small" id="showNextFromProject" title="Skip">Skip</button>
                <button type="button" class="btn btn-small" id="btnSavePartial" title="Save Draft">Save draft</button>
                <g:link controller="transcribe" action="discard" id="${taskInstance?.id}" class="btn btn-small btn-warning" title="Discard">Discard</g:link>
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
                <div class="form-horizontal">
                    %{--<div class="control-group">--}%
                        <div class="controls">
                            <label class="checkbox">
                                <g:checkBox name="interesting" value="${taskInstance.interesting}" /> This image is particularly interesting – alert the WildCount team
                            </label>
                        </div>
                    %{--</div>--}%
                </div>
            </div>
        </div>

        <div class="span6" style="max-height: 590px; overflow-y: hidden;">
            <div id="camera-trap-questions" class="" data-interval="">
                <div id="ct-landing" class="item clearfix active">
                    <div class="well well-small">
                        <h3>Step 1</h3>
                        <p>Are there any animals visible in the image?</p>
                        <g:set var="step1" value="${recordValues[0]?.animalsVisible}" />
                        <div id="ct-step1" class="btn-group btn-group-vertical" data-toggle="buttons-radio">
                            <button class="btn input-medium btn-ct-landing ${step1 == 'setup' ? 'active' : ''}" data-value="setup">Setup</button>
                            <button class="btn btn-warning input-medium btn-ct-landing ${step1 == 'unsure' ? 'active' : ''}" data-value="unsure">Unsure</button>
                            <button class="btn btn-danger input-medium btn-ct-landing ${step1 == 'none' ? 'active' : ''}" data-value="none">No animals present</button>
                            <button id="btn-animals-present" class="btn btn-primary input-medium btn-ct-landing ${step1 == 'some' ? 'active' : ''}" data-value="some">Animals present</button>
                        </div>
                        <g:hiddenField name="skipNextAction" value="true" />
                        <g:hiddenField name="recordValues.0.animalsVisible" value="${recordValues[0]?.animalsVisible}" />
                    </div>
                </div>
                <div id="ct-animals-present" class="item clearfix">
                    %{--<p>Select all animals present in the image.  If you a certain that a specimen is present, select the tick for the corresponding icon. If you think the specimen is present in the image but you are not sure then select the question mark icon instead.</p>--}%
                    <div class="well well-small" style="padding-bottom: 0;">
                        <h3><a id="ct-step2-back" style="vertical-align: middle;" href="javascript:void(0)"><i class="icon icon-chevron-left"></i> </a>Step 2</h3>
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
                            <li><a href="#unlisted" data-toggle="pill">Unlisted</a></li>
                        </ul>
                        <div class="pill-content" style="overflow-y: auto; height: 463px;">
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
                            <div class="pill-pane fade form-horizontal" id="unlisted">
                                <g:set var="placeholders" value="${['Quokka (Setonix brachyurus)', 'Short-beaked Echidna (Tachyglossus aculeatus)', 'Western Quoll (Dasyurus geoffroii)', 'Platypus (Ornithorhynchus anatinus)', 'Forest kingfisher (Todiramphus macleayii)', 'Sand goanna (Varanus gouldii )', 'Central bearded dragon (Pogona vitticeps)']}" />
                                ${Collections.shuffle(placeholders)}
                                <g:set var="unlisteds" value="${recordValues.findAll { it.value?.unlisted != null }.collect{  [i: it.key, v: it.value.unlisted] }.sort { it.i }.collect { it.v }}" />
                                <g:each in="${unlisteds}" var="u" status="s">
                                    <div class="control-group">
                                        <label class="control-label" for="recordValues.${s}.unlisted">Species name</label>
                                        <div class="controls">
                                            <g:textField class="speciesName input-xlarge" name="recordValues.${s}.unlisted" placeholder="${placeholders[s % placeholders.size()]}" value="${recordValues[s]?.unlisted}" />
                                        </div>
                                    </div>
                                </g:each>
                                <div class="control-group">
                                    <label class="control-label" for="recordValues.${unlisteds.size()}.unlisted">Species name</label>
                                    <div class="controls">
                                        <g:textField class="speciesName input-xlarge" name="recordValues.${unlisteds.size()}.unlisted" placeholder="${placeholders[unlisteds.size() % placeholders.size()]}" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="ct-full-image-container" class="item clearfix">
                    <img id="ct-full-image" src="" />
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
                <g:if test="${validator}">
                    <button type="button" id="btnValidate" class="btn btn-success bvp-submit-button"><i class="icon-ok icon-white"></i>&nbsp;${message(code: 'default.button.validate.label', default: 'Mark as Valid')}</button>
                    <button type="button" id="btnDontValidate" class="btn btn-danger bvp-submit-button"><i class="icon-remove icon-white"></i>&nbsp;${message(code: 'default.button.dont.validate.label', default: 'Mark as Invalid')}</button>
                </g:if>
                <g:else>
                    <button type="button" id="btnSave" class="btn btn-primary bvp-submit-button">${message(code: 'default.button.save.short.label', default: 'Submit')}</button>
                </g:else>
                %{--<button class="btn btn-primary">Submit</button>--}%
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

    <div id="ct-fields" style="display: none;"></div>
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
        <div class="ct-caption-table">
            <div class="ct-caption-cell">
                <div class="ct-caption dotdotdot" title="{{value}}">{{value}}</div>
            </div>
        </div>
    </div>
</div>
</script>

<script id="new-unlisted-template" type="x-tmpl-mustache">
    <div class="control-group">
        <label class="control-label" for="recordValues.{{index}}.unlisted">Species name</label>
        <div class="controls">
            <input type="text" class="speciesName input-xlarge" id="recordValues.{{index}}.unlisted" name="recordValues.{{index}}.unlisted" placeholder="{{placeholder}}" />
        </div>
    </div>
</script>

<script id="input-template" type="x-tmpl-mustache">
    <input id="{{id}}" name="{{id}}" type="hidden" value="{{value}}" />
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

    var recordValues = <cl:json value="${recordValues}" />;

    var values = [].concat(_.pluck(smItems, 'value'), _.pluck(lmItems, 'value'), _.pluck(reptilesItems, 'value'), _.pluck(birdsItems, 'value'), _.pluck(otherItems, 'value'));

    var itemValueMap = _.reduce(_.filter([].concat(smItems,lmItems,reptilesItems,birdsItems,otherItems), function(it) { return it != null }), function(memo, it) { memo[it.value] = it; return memo; }, {});

    var unlisted = [];

    var selections = {};

    // setup initial selection state from recordValues
    for (var index in recordValues) {
      if( recordValues.hasOwnProperty( index ) ) {
        var vn = recordValues[index].vernacularName;
        var certainty = recordValues[index].certainty || 1;
        if (vn && itemValueMap[vn]) {
          selections[vn] = {certainty: certainty, key: itemValueMap[vn].key}
        }
      }
    }

    function page(id) {
      return {'page': id};
    }

    if (history.replaceState) {
      history.replaceState(page('ct-landing'), window.document.title);
    }

    function switchCtPage(to) {
      var $ctq = $('#camera-trap-questions');
      // kill any existing transition
      $ctq.children('.fading').removeClass('fading');
      $ctq.children('.active:not('+to+')').removeClass('active').addClass('fading');
      $(to).addClass('active');
    }

    $('#ct-step1').find('.btn').click(function(e) {
      var $this = $(this);
      var value = $this.attr('data-value');
      $('#recordValues\\.0\\.animalsVisible').val(value);
    });

    $('#camera-trap-questions').on('transitionend', '.item', function(e) {
        $(e.target).removeClass('fading');
        $('.ct-caption').dotdotdot();
      });

    $('#ct-step2-back').click(function(e) {
      if (history.pushState) {
        history.back();
      } else {
        switchCtPage('ct-animals-present');
      }
    });

    $('a[data-toggle="pill"]').on('shown', function (e) {
      $('.ct-caption').dotdotdot();
    });

    function animalsPresent() {
      switchCtPage('#ct-animals-present');
      if (history.pushState)
        history.pushState(page('ct-animals-present'), window.document.title);
    }

    $('#btn-animals-present').click(function(e) {
      e.preventDefault();
      animalsPresent();
    });

    $('.ct-thumbnail-image').click(function(e) {
      var key = $(e.target).closest('[data-image-select-key]').data('image-select-key');
      $('#ct-full-image').attr('src', firstInfoWithKey(key).imageUrl);

      switchCtPage('#ct-full-image-container');
    });

    $('#ct-full-image-container').find('img').click(function(e) {
      switchCtPage('#ct-animals-present');
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
      var imageUrl = firstInfoWithKey(imageKey).squareThumbUrl;
      var opts = {
        squareThumbUrl: imageUrl,
        value: sel,
        key: imageKey,
        success: certainty == 1,
        uncertain: certainty < 1
      };
      mu.appendTemplate(selElem, 'selected-item-template', opts);
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

      generateInputFields();
    }

    function generateInputFields() {
      var $ctFields = $('#ct-fields');
      $ctFields.empty();
      var i = 0;
      _.each(selections, function(value, key, list) {
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.'+i+'.vernacularName', value: key});
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.'+i+'.certainty', value: value.certainty});
        ++i;
      });
    }

    function firstItemWithValue(value) {
      return _.find([].concat(smItems, lmItems, reptilesItems, birdsItems, otherItems), function(it) { return it.value === value });
    }

    function firstInfoWithKey(key) {
      return (smImageInfos || {})[key] || (lmImageInfos || {})[key] || (reptilesImageInfos || {})[key] || (birdsImageInfos || {})[key] || (otherImageInfos || {})[key]
    }

    var $unlisted = $('#unlisted');
    //var placeholders = _.shuffle(['Short-beaked Echidna (Tachyglossus aculeatus)', 'Western Quoll (Dasyurus geoffroii)', 'Platypus (Ornithorhynchus anatinus)', 'Forest kingfisher (Todiramphus macleayii)', 'Sand goanna (Varanus gouldii )', 'Central bearded dragon (Pogona vitticeps)']);
    var placeholders = <cl:json value="${placeholders}" />;

    $unlisted.on('change keyup paste input propertychange', '.speciesName:last', function(e) {
      var $this = $(this);
      if ($this.val()) {
        var index = $unlisted.children().length;
        mu.appendTemplate($unlisted, 'new-unlisted-template', {placeholder: placeholders[index % placeholders.length], index: index});
        fixUnlisted();
      }
    });

    $unlisted.on('blur', '.speciesName:not(:last)', function(e) {
      var $this = $(this);
      if (!$this.val()) {
        $this.closest('.control-group').remove();
        fixUnlisted();
      }
    });

    function fixUnlisted() {
      var $unlisted = $('#unlisted');
      $unlisted.find('.control-group').each(function(i, e) {
        var $this = $(this);
        var attrVal = 'recordValues.'+i+'.unlisted';
        $this.find('input').attr('name', attrVal)
                           .attr('id', attrVal);
        $this.find('label').attr('for', attrVal);
      });
    }

    window.onpopstate = function(e) {
      var state = window.history.state;
      if (state.page) {
        switchCtPage('#'+state.page);
      }
    };

    transcribeWidgets.addBeforeSubmitHook(function(e) {
      generateInputFields();
      return true;
    });

    if (recordValues && recordValues['0'] && ('some' === recordValues['0'].animalsVisible)) animalsPresent();

    // force intial sync of saved values
    syncSelectionState();
  });
</r:script>