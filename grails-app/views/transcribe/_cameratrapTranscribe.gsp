<%@ page import="au.org.ala.volunteer.Picklist; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />
<r:require modules="cameratrap" />

<div id="ct-container" class="container-fluid extra-tall-image">

    <div class="row-fluid">
        <div class="span12">
            <span id="journalPageButtons">
                <button type="button" class="btn btn-small" id="showPreviousJournalPage" title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><img src="${resource(dir:'images',file:'left_arrow.png')}"> previous image</button>
                <button type="button" class="btn btn-small" id="showNextJournalPage" title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>next image <img src="${resource(dir:'images',file:'right_arrow.png')}"></button>
                <div id="ct-task-image-toolbar" class="btn-group">
                    <button type="button" class="btn btn-small" id="rotateImage" data-container="body" title="Rotate the page 180 degrees">Rotate&nbsp;<img style="vertical-align: middle; margin: 0 !important;" src="${resource(dir:'images',file:'rotate.png')}"></button>
                    <button type="button" class="btn btn-small" id="showNextFromProject" data-container="body" title="Skip the to next image">Skip</button>
                    %{--<button type="button" class="btn btn-small" id="btnSavePartial">Save draft</button>--}%
                    <g:link controller="transcribe" action="discard" id="${taskInstance?.id}" class="btn btn-small btn-warning" data-container="body" title="Release your lock on this image and return to the expedition page">Quit</g:link>
                </div>
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
                <div class="form-horizontal" style="text-align: center;">
                    %{--<div class="control-group">--}%
                        <div class="controls" style="margin-left: initial; display: inline-block;">
                            <label class="checkbox">
                                <g:checkBox name="recordValues.0.interesting" value="${recordValues[0]?.interesting}" /> This image is particularly interesting – alert the WildCount team
                            </label>
                        </div>
                    %{--</div>--}%
                </div>
            </div>
        </div>

        <div class="span6" style="max-height: 590px; overflow-y: hidden;">
            <div id="camera-trap-questions" class="" data-interval="">
                <div id="ct-landing" class="ct-item clearfix active">
                    <div class="well well-small">
                        <h3>Are there any animals visible in the image?</h3>
                        <g:set var="step1" value="${recordValues[0]?.animalsVisible}" />
                        <div id="ct-step1" class="btn-group btn-group-vertical" data-toggle="buttons-radio">
                            %{--<button class="btn input-medium btn-ct-landing ${step1 == 'setup' ? 'active' : ''}" data-value="setup">Setup</button>--}%
                            <button class="btn btn-warning input-medium btn-ct-landing ${step1 == 'unsure' ? 'active' : ''}" data-value="unsure" type="button">Unsure</button>
                            <button class="btn btn-danger input-medium btn-ct-landing ${step1 == 'none' ? 'active' : ''}" data-value="none" type="button">No animals present</button>
                            <button id="btn-animals-present" class="btn btn-primary input-medium btn-ct-landing ${step1 == 'some' ? 'active' : ''}" data-value="some" type="button">Animals present</button>
                        </div>
                        <g:hiddenField name="skipNextAction" value="true" />
                        <g:hiddenField name="recordValues.0.animalsVisible" value="${recordValues[0]?.animalsVisible}" />
                    </div>
                </div>
                <div id="ct-animals-present" class="ct-item clearfix">
                    %{--<p>Select all animals present in the image.  If you are certain that a specimen is present, select the tick for the corresponding icon. If you think the specimen is present in the image but you are not sure then select the question mark icon instead.</p>--}%
                    <div class="well well-small" style="padding-bottom: 0;">
                        <div class="row-fluid">
                            <div class="span12">
                                <h3><a id="ct-step2-back" style="vertical-align: middle;" href="javascript:void(0)"><i class="icon icon-chevron-left"></i> </a>Select all animals present in image</h3>
                            </div>
                        </div>
                        <g:set var="smImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.smallMammalsPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <g:set var="lmImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.largeMammalsPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <g:set var="reptilesImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.reptilesPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <g:set var="birdsImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.birdsPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <g:set var="otherImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.otherPicklistId?.toLong()), project: taskInstance?.project)}" />
                        <div class="row-fluid">
                            <div class="span11">
                                <ul class="nav nav-pills">
                                    <li class="active"><a href="#small-mammal" data-toggle="pill">Small Mammals</a></li>
                                    <li><a href="#large-mammal" data-toggle="pill">Large Mammals</a></li>
                                    <li><a href="#reptile" data-toggle="pill">Reptiles</a></li>
                                    <li><a href="#bird" data-toggle="pill">Birds</a></li>
                                    <li><a href="#unlisted" data-toggle="pill">Others</a></li>
                                    %{--<li><a href="#unlisted" data-toggle="pill">Unlisted</a></li>--}%
                                </ul>
                            </div>
                            <div class="span1">
                                <div id="ct-nav-toolbar" class="btn-group pull-right">
                                    %{--<button id="button-filter" type="button" class="btn btn-small" data-toggle="button" title="${message(code: 'default.button.filter.label', default: 'Filter')}" data-container="#ct-nav-toolbar"><i class="icon-search"></i></button>--}%
                                    <button id="button-sort-items" type="button" class="btn btn-small" data-toggle="button" title="${message(code: 'default.button.alpha.sort.label', default: 'Sort alphabetically')}" data-placement="left">A<i class="icon-resize-vertical"></i></button>
                                </div>
                                <div id="ct-search" class="ct-search pull-right">
                                    <input id="ct-search-input" type="text" placeholder="${message(code: 'default.input.filter.placeholder', default: "Filter")}">
                                </div>
                            </div>
                        </div>
                        <div class="row-fluid">
                            <div class="span12">
                                <div id="ct-animals-pill-content" class="pill-content" style="overflow-y: auto; height: 463px;">
                                    <div class="pill-pane fade in active sortable" id="small-mammal">
                                        <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: smImageInfos, picklistId: template.viewParams.smallMammalsPicklistId?.toLong()]}" />
                                    </div>
                                    <div class="pill-pane fade sortable" id="large-mammal">
                                        <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: lmImageInfos, picklistId: template.viewParams.largeMammalsPicklistId?.toLong()]}" />
                                    </div>
                                    <div class="pill-pane fade sortable" id="reptile">
                                        <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: reptilesImageInfos, picklistId: template.viewParams.reptilesPicklistId?.toLong()]}" />
                                    </div>
                                    <div class="pill-pane fade sortable" id="bird">
                                        <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: birdsImageInfos, picklistId: template.viewParams.birdsPicklistId?.toLong()]}" />
                                    </div>
                                    %{--<div class="pill-pane fade sortable" id="other">--}%
                                        %{--<g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: otherImageInfos, picklistId: template.viewParams.otherPicklistId?.toLong()]}" />--}%
                                    %{--</div>--}%
                                    <div class="pill-pane fade form-horizontal" id="unlisted">
                                        <div class="control-group">
                                            <div class="controls">
                                                <label style="display: inline-block" class="checkbox" for="recordValues.0.unknown" title="Check this if there are animals present in the photo that you do not recognise"><g:checkBox name="recordValues.0.unknown" value="${recordValues[0]?.unknown}"/>Unknown</label>
                                            </div>
                                        </div>
                                        <g:set var="placeholders" value="${['Quokka (Setonix brachyurus)', 'Short-beaked Echidna (Tachyglossus aculeatus)', 'Western Quoll (Dasyurus geoffroii)', 'Platypus (Ornithorhynchus anatinus)', 'Forest kingfisher (Todiramphus macleayii)', 'Sand goanna (Varanus gouldii )', 'Central bearded dragon (Pogona vitticeps)']}" />
                                        ${Collections.shuffle(placeholders)}
                                        <g:set var="unlisteds" value="${recordValues.findAll { it.value?.unlisted != null }.collect{  [i: it.key, v: it.value.unlisted] }.sort { it.i }.collect { it.v }}" />
                                        <g:each in="${unlisteds}" var="u" status="s">
                                            <div class="control-group">
                                                <label class="control-label" for="recordValues.${s}.unlisted">Species name</label>
                                                <div class="controls">
                                                    <g:textField class="speciesName input-xlarge autocomplete" data-picklist-id="${template.viewParams.unlistedPicklistId}" name="recordValues.${s}.unlisted" placeholder="${placeholders[s % placeholders.size()]}" value="${recordValues[s]?.unlisted}" />
                                                </div>
                                            </div>
                                        </g:each>
                                        <div class="control-group">
                                            <label class="control-label" for="recordValues.${unlisteds.size()}.unlisted">Species name</label>
                                            <div class="controls">
                                                <g:textField class="speciesName input-xlarge autocomplete" data-picklist-id="${template.viewParams.unlistedPicklistId}" name="recordValues.${unlisteds.size()}.unlisted" placeholder="${placeholders[unlisteds.size() % placeholders.size()]}" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="ct-full-image-container" class="ct-item clearfix"></div>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span11">
            <h3>My selections</h3>
        </div>
        <div class="span1">
            <div style="margin: 10px 0; line-height: 40px;">
                <g:if test="${!validator}">
                    <button type="button" id="btnSave" class="btn btn-primary bvp-submit-button">${message(code: 'default.button.save.short.label', default: 'Submit')}</button>
                </g:if>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <div class="well">
                <div id="ct-selection-grid" class="itemgrid">

                </div>
                <div id="ct-unknown-selections-unknown">
                    <span></span>
                </div>
                <div id="ct-unknown-selections">
                    <label style="font-weight: bold; display: inline-block;">${message(code: 'cameratrap.transcribe.unlisted.label', default: 'Others:')}</label> <span></span>
                </div>
            </div>
        </div>
    </div>

    <g:if test="${validator}">
    <div class="row-fluid">
        <div class="offset10 span2">
            <button type="button" id="btnValidate" class="btn btn-success bvp-submit-button"><i class="icon-ok icon-white"></i>&nbsp;${message(code: 'default.button.validate.label', default: 'Mark as Valid')}</button>
            <button type="button" id="btnDontValidate" class="btn btn-danger bvp-submit-button"><i class="icon-remove icon-white"></i>&nbsp;${message(code: 'default.button.dont.validate.label', default: 'Mark as Invalid')}</button>
        </div>
    </div>
    </g:if>

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
            <input type="text" class="speciesName input-xlarge autocomplete" data-picklist-id="${template.viewParams.unlistedPicklistId}" id="recordValues.{{index}}.unlisted" name="recordValues.{{index}}.unlisted" placeholder="{{placeholder}}" />
        </div>
    </div>
</script>

<script id="input-template" type="x-tmpl-mustache">
    <input id="{{id}}" name="{{id}}" type="hidden" value="{{value}}" />
</script>

<script id="carousel-template" type="x-tmpl-mustache">
    <div id="ct-full-image-carousel" data-interval="0" class="carousel slide" style="margin-bottom: 0;">
        <ol class="carousel-indicators">
            {{#imgs}}
                <li class="{{active}}" data-target="#ct-full-image-carousel" data-slide-to="{{idx}}"></li>
            {{/imgs}}
        </ol>
        <div class="carousel-inner">
            {{#imgs}}
            <div class="item {{active}}">
                <img src="{{url}}" />
            </div>
            {{/imgs}}
        </div>
        <a class="carousel-control left" href="#ct-full-image-carousel" data-slide="prev">&lsaquo;</a>
        <a class="carousel-control right" href="#ct-full-image-carousel" data-slide="next">&rsaquo;</a>
    </div>
</script>

<r:script>
var smImageInfos = <cl:json value="${smImageInfos.infos}" />
    ,lmImageInfos = <cl:json value="${lmImageInfos.infos}" />
    ,reptilesImageInfos = <cl:json value="${reptilesImageInfos.infos}" />
    ,birdsImageInfos = <cl:json value="${birdsImageInfos.infos}" />;
    //,otherImageInfos = <cl:json value="${otherImageInfos.infos}" />;

var smItems = <cl:json value="${smImageInfos.items}" />
    ,lmItems = <cl:json value="${lmImageInfos.items}" />
    ,reptilesItems = <cl:json value="${reptilesImageInfos.items}" />
    ,birdsItems = <cl:json value="${birdsImageInfos.items}" />;
    //,otherItems = <cl:json value="${otherImageInfos.items}" />;

var recordValues = <cl:json value="${recordValues}" />;

var placeholders = <cl:json value="${placeholders}" />;

cameratrap(smImageInfos, lmImageInfos, reptilesImageInfos, birdsImageInfos, null, smItems, lmItems,
           reptilesItems, birdsItems, null, recordValues, placeholders);
</r:script>