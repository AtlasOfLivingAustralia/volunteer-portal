<%@ page import="au.org.ala.volunteer.Picklist; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}" />
<r:require modules="cameratrap, fontawesome" />

<div id="ct-container" class="container-fluid fourthree-image">

    <g:set var="sequences" value="${sequenceNumbers(project: taskInstance.project, number: sequenceNumber, count: 3)}" />
    <div class="row-fluid">
        <div class="span12">
            <span id="journalPageButtons">
                %{--<button type="button" class="btn btn-small" id="showPreviousJournalPage" title="displays page in new window" data-container="body" ${prevTask ? '' : 'disabled="true"'}><img src="${resource(dir:'images',file:'left_arrow.png')}"> previous image</button>--}%
                %{--<button type="button" class="btn btn-small" id="showNextJournalPage" title="displays page in new window" data-container="body" ${nextTask ? '' : 'disabled="true"'}>next image <img src="${resource(dir:'images',file:'right_arrow.png')}"></button>--}%
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
        <div id="ct-image-span" class="span6">
            <div id="ct-image-well" class="well well-small">
                <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                    <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                        <g:imageViewer multimedia="${multimedia}" />
                    </g:if>
                </g:each>
                <div class="form-horizontal" style="text-align: center;">
                    %{--<div class="control-group">--}%
                        <div class="controls" style="margin-left: initial; display: inline-block;">
                            <label class="checkbox" for="recordValues.0.interesting">
                                <g:checkBox name="recordValues.0.interesting" value="${recordValues[0]?.interesting}" /> This image is particularly interesting – alert the WildCount team
                            </label>
                        </div>
                    %{--</div>--}%
                </div>
            </div>
        </div>

        <style>
            .well hr {
                border-top-color: #e9eae0;
                border-bottom-color: #d9dad0;
            }

            /* undo bootstrap well padding */
            .well .well-navbar {
                margin-top: -19px;
                margin-left: -19px;
                margin-right: -19px;
            }

            .well.well-small .well-navbar {
                margin-top: -9px;
                margin-left: -9px;
                margin-right: -9px;
            }

            .well-navbar .well-navbar-inner {
                min-height: 40px;
                padding-left: 20px;
                padding-right: 20px;
                background-color: #d8dcc8;
                background-image: unset;
                background-repeat: unset;
                filter: unset;
                border-bottom: 1px solid #d7cac9;
                -webkit-border-radius: unset;
                -moz-border-radius: unset;
                border-radius: unset;
                -webkit-box-shadow: unset;
                -moz-box-shadow: unset;
                box-shadow: unset;
            }

            .well-navbar.navbar .brand {
                text-shadow: none;
                color: #7f826a;
                font-weight: 100;
            }

            .well-navbar.navbar .nav > .active > a, .well-navbar.navbar .nav > .active > a:hover, .well-navbar.navbar .nav > .active > a:focus {
                color: #222;
                text-decoration: none;
                background-color: white;
                -webkit-box-shadow: none;
                -moz-box-shadow: none;
                box-shadow: none;
            }

            .well-navbar.navbar .nav > li > a {
                color: #7f826a;
                text-shadow: none;
            }
        </style>
        <g:set var="step1" value="${recordValues[0]?.animalsVisible}" />
        <g:set var="bnw" value="${recordValues[0]?.photoBlackAndWhite}" />
        <div id="ct-question-span" class="span6" style="">
            <div id="camera-trap-questions" class="" data-interval="">
                <div class="well well-small" style="height: 506px;">
                    <div class="well-navbar navbar">
                        <div class="well-navbar-inner">
                            <span class="brand">Steps</span>
                            <ul id="ct-questions-nav" class="nav">
                                <li class="active"><a href="#ct-landing" data-toggle="nav">1</a></li>
                                <li><a href="#ct-animals-present" data-toggle="nav">2</a></li>
                                <li><a href="#ct-animals-summary" data-toggle="nav">My Selections</a></li>
                            </ul>
                        </div>
                    </div>
                    <div id="ct-item-container" style="position: relative;">
                        <div id="ct-landing" class="ct-item clearfix active">
                                <p><strong>Are there any animals visible in the image?</strong></p>
                                <div>
                                    <label class="radio inline">
                                        <input type="radio" id="btn-animals-present" name="recordValues.0.animalsVisible" value="some" ${'some' == step1 ? 'checked': ''}>Yes
                                    </label>
                                    <label class="radio inline">
                                        <input type="radio" name="recordValues.0.animalsVisible" value="none" ${'none' == step1 ? 'checked': ''}>No
                                    </label>
                                    <label class="radio inline">
                                        <input type="radio" name="recordValues.0.animalsVisible" value="unsure" ${'unsure' == step1 ? 'checked': ''}>Unsure
                                    </label>
                                </div>
                                <hr />
                                <p><strong>Is the photo black and white?</strong></p>
                                <div>
                                    <label class="radio inline">
                                        <input type="radio" name="recordValues.0.photoBlackAndWhite" value="yes" ${'yes' == bnw ? 'checked': ''}>Yes
                                    </label>
                                    <label class="radio inline">
                                        <input type="radio" name="recordValues.0.photoBlackAndWhite" value="no" ${'no' == bnw ? 'checked': ''}>No
                                    </label>
                                </div>
                                <g:hiddenField name="skipNextAction" value="true" />
                        </div>
                        <div id="ct-animals-present" class="ct-item clearfix">

                            <div class="row-fluid">
                                <div class="span12">
                                    <p><strong>Select animals that are present in the image</strong></p>
                                </div>
                            </div>
                            <g:set var="smImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.smallMammalsPicklistId?.toLong()), project: taskInstance?.project)}" />
                            <g:set var="lmImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.largeMammalsPicklistId?.toLong()), project: taskInstance?.project)}" />
                            <g:set var="reptilesImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.reptilesPicklistId?.toLong()), project: taskInstance?.project)}" />
                            <g:set var="birdsImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.birdsPicklistId?.toLong()), project: taskInstance?.project)}" />
                            <g:set var="otherImageInfos" value="${imageInfos(picklist: Picklist.get(template.viewParams.otherPicklistId?.toLong()), project: taskInstance?.project)}" />
                            <div class="row-fluid">
                                <div class="span12">
                                    <ul class="nav nav-tabs">
                                        <li class="active"><a href="#small-mammal" data-toggle="tab">Small Mammals</a></li>
                                        <li><a href="#large-mammal" data-toggle="tab">Large Mammals</a></li>
                                        <li><a href="#reptile" data-toggle="tab">Reptiles</a></li>
                                        <li><a href="#bird" data-toggle="tab">Birds</a></li>
                                        <li><a href="#unlisted" data-toggle="tab" class="ct-no-toolbar">Others</a></li>
                                        %{--<li><a href="#unlisted" data-toggle="pill">Unlisted</a></li>--}%
                                    </ul>
                                </div>
                            </div>
                            <div class="row-fluid">
                                <div class="span12">
                                    <div id="ct-animals-pill-content" class="tab-content">
                                        <div class="ct-toolbar">
                                            <div class="input-append" style="margin-bottom: 0;">
                                                <input id="ct-search-input" type="text" class="input-medium" style="margin-bottom: 0;" placeholder="${message(code: 'default.input.filter.placeholder', default: "Filter")}">
                                                <span class="add-on" style="height:18px;"><i class="icon-search"></i></span>
                                            </div>
                                            <button id="button-sort-items" type="button" class="btn btn-small" data-toggle="button" title="${message(code: 'default.button.alpha.sort.label', default: 'Sort alphabetically')}" data-placement="left"><i class="fa fa-sort-alpha-asc"></i></button>
                                        </div>
                                        <div class="tab-pane fade in active sortable text-center" id="small-mammal">
                                            <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: smImageInfos, picklistId: template.viewParams.smallMammalsPicklistId?.toLong()]}" />
                                        </div>
                                        <div class="tab-pane fade sortable text-center" id="large-mammal">
                                            <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: lmImageInfos, picklistId: template.viewParams.largeMammalsPicklistId?.toLong()]}" />
                                        </div>
                                        <div class="tab-pane fade sortable text-center" id="reptile">
                                            <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: reptilesImageInfos, picklistId: template.viewParams.reptilesPicklistId?.toLong()]}" />
                                        </div>
                                        <div class="tab-pane fade sortable text-center" id="bird">
                                            <g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: birdsImageInfos, picklistId: template.viewParams.birdsPicklistId?.toLong()]}" />
                                        </div>
                                        %{--<div class="pill-pane fade sortable text-center" id="other">--}%
                                            %{--<g:render template="/transcribe/cameratrapWidget" model="${[imageInfos: otherImageInfos, picklistId: template.viewParams.otherPicklistId?.toLong()]}" />--}%
                                        %{--</div>--}%
                                        <div class="tab-pane fade form-horizontal ct-no-toolbar" id="unlisted">
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
                        <div id="ct-animals-summary" class="ct-item">
                            <p><strong>Animals visible:</strong> <span>${step1}</span>.  <strong>Black and white:</strong> <span>${bnw}</span></p>
                            <p><strong>Selected animals</strong></p>
                            <div class="itemgrid ct-selection-grid">

                            </div>
                            <div class="ct-unknown-selections-unknown">
                                <span></span>
                            </div>
                            <div class="ct-unknown-selections">
                                <label style="font-weight: bold; display: inline-block;">${message(code: 'cameratrap.transcribe.unlisted.label', default: 'Others:')}</label> <span></span>
                            </div>
                        </div>
                        <div id="ct-full-image-container" class="ct-item clearfix"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span11">
            <h3 class="h3-small">My selections</h3>
        </div>
        <div class="span1">
            <div class="h3-small" style="line-height: 40px;">
                <g:if test="${!validator}">
                    <button type="button" id="btnSave" class="btn btn-primary bvp-submit-button hidden">${message(code: 'default.button.save.short.label', default: 'Submit')}</button>
                </g:if>
                <button type="button" id="btnNext" class="btn btn-primary">${message(code: 'default.button.next.label', default: 'Next')} <i class="fa fa-chevron-right"></i></button>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <div class="well">
                <div id="ct-selection-grid" class="itemgrid ct-selection-grid">

                </div>
                <div class="ct-unknown-selections-unknown">
                    <span></span>
                </div>
                <div class="ct-unknown-selections">
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
    <div class="thumbnail ct-thumbnail {{selected}}" data-image-select-key="{{key}}" data-image-select-value="{{value}}">
        <span class="ct-badge ct-badge-sure badge"><i class="fa fa-check-circle"></i></span>
        <span class="ct-badge ct-badge-uncertain badge"><i class="fa fa-question-circle"></i></span>
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

<script id="single-image-template" type="x-tmpl-mustache">
    <div id="ct-full-image" style="position:relative;" data-image-select-value="{{value}}" data-image-select-key="{{key}}">
        <span class="ct-badge ct-badge-sure badge {{sureSelected}}" data-container="body" title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: 'There is definitely a {{value}} in the image')}"><i class="fa fa-check-circle"></i></span>
        <span class="ct-badge ct-badge-uncertain badge {{uncertainSelected}}" data-container="body" title="${g.message(code: 'cameratrap.widget.uncertain.badge.title', default: 'There could possibly be a {{value}} in the image')}"><i class="fa fa-question-circle"></i></span>
        <span class="ct-full-image-carousel-close">&times;</span>
        <img src="{{url}}" title="${message(code:'camera.trap.carousel.dismiss', default:'Click on the image to dismiss')}" data-container="body"/>
    </div>
</script>

<script id="carousel-template" type="x-tmpl-mustache">
    <div id="ct-full-image-carousel" data-interval="0" class="carousel slide" style="margin-bottom: 0;" data-image-select-value="{{value}}" data-image-select-key="{{key}}">
        <span class="ct-badge ct-badge-sure badge {{sureSelected}}" data-container="body" title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: 'There is definitely a {{value}} in the image')}"><i class="fa fa-check-circle"></i></span>
        <span class="ct-badge ct-badge-uncertain badge {{uncertainSelected}}" data-container="body" title="${g.message(code: 'cameratrap.widget.uncertain.badge.title', default: 'There could possibly be a {{value}} in the image')}"><i class="fa fa-question-circle"></i></span>
        <span class="ct-full-image-carousel-close">&times;</span>
        <ol class="carousel-indicators">
            {{#imgs}}
                <li class="{{active}}" data-target="#ct-full-image-carousel" data-slide-to="{{idx}}"></li>
            {{/imgs}}
        </ol>
        <div class="carousel-inner" title="${message(code:'camera.trap.carousel.dismiss', default:'Click on the image to dismiss')}" data-container="body">
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