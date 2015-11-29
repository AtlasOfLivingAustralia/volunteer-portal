<%@ page import="au.org.ala.volunteer.Picklist; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<r:require modules="cameratrap, font-awesome"/>
<div id="ct-container" >

    <g:set var="sequences" value="${sequenceNumbers(project: taskInstance.project, number: sequenceNumber, count: 3)}"/>

    <div class="row">
        <div id="ct-image-span" class="col-sm-6">
            <div id="ct-image-well" class="panel panel-default">
                <div class="panel-body">
                    <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                        <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                            <g:imageViewer multimedia="${multimedia}"/>
                        </g:if>
                    </g:each>
                    <div class="form-horizontal" style="text-align: center;">
                        <div class="form-group">
                            <div class="controls" style="margin-left: initial; display: inline-block;">
                                <label class="checkbox" for="recordValues.0.interesting">
                                    <g:checkBox name="recordValues.0.interesting"
                                                checked="${recordValues[0]?.interesting == 'true'}"/> ${message(code: 'cameratrap.interesting.label', default: 'This image is particularly interesting – alert the WildCount team')}
                                </label>
                            </div>
                        </div>
                    </div>

                    <div id="ct-image-sequence" class="faux-table text-center">
                        <div>
                            <g:each in="${0..<(3 - sequences.previous.size())}">
                                <div class="faux-empty-cell">&nbsp;</div>
                            </g:each>
                            <g:each in="${sequences.previous}" var="p">
                                <div class="faux-img-cell" data-seq-no="${p}">
                                    <cl:sequenceThumbnail project="${taskInstance.project}" seqNo="${p}"/>
                                </div>
                            </g:each>
                            <div class="faux-img-cell active default">
                                <cl:taskThumbnail task="${taskInstance}" fixedHeight="${false}" withHidden="${true}"/>
                            </div>
                            <g:each in="${sequences.next}" var="n">
                                <div class="faux-img-cell" data-seq-no="${n}">
                                    <cl:sequenceThumbnail project="${taskInstance.project}" seqNo="${n}"/>
                                </div>
                            </g:each>
                            <g:each in="${0..<(3 - sequences.next.size())}">
                                <div class="faux-empty-cell">&nbsp;</div>
                            </g:each>
                        </div>
                    </div>

                    <div>
                        <p style="margin-top:10px"
                           class="text-center">${message(code: 'cameratrap.sequence.label', default: 'Move between the image sequence to see what\'s coming in or going out of the current image')}</p>
                    </div>
                </div>
            </div>
        </div>
        <g:set var="step1" value="${recordValues[0]?.animalsVisible}"/>
        <g:set var="bnw" value="${recordValues[0]?.photoBlackAndWhite}"/>
        <div id="ct-question-span" class="col-sm-6" style="">
            <div id="camera-trap-questions" class="" data-interval="">
                <div id="ct-questions-nav" class="stepwizard">
                    <div class="stepwizard-row">
                        <div class="stepwizard-step">
                            <button type="button" class="btn btn-circle btn-default ${validator ? '' : 'active'}" data-target="#ct-landing" data-toggle="nav">1</button>
                            <button type="button" class="btn btn-circle btn-default" data-target="#ct-animals-present" data-toggle="nav">2</button>
                            <button type="button" class="btn btn-circle btn-default ${validator ? 'active' : ''}" data-target="#ct-animals-summary" data-toggle="nav">3</button>
                        </div>
                    </div>
                </div>

                <div id="ct-item-container" class="ct-item-container">
                    <div id="ct-landing" class="ct-item ${validator ? '' : 'active'}">

                        <div class="row">
                            <div class="col-sm-12">
                                <p><strong>Are there any animals visible in the image?</strong></p>
                            </div>

                            <div class="col-sm-12">
                                <div id="ct-animals-question">
                                    <label class="radio-inline">
                                        <input type="radio" id="btn-animals-present" name="recordValues.0.animalsVisible"
                                               value="yes" ${'yes' == step1 ? 'checked' : ''}>Yes
                                    </label>
                                    <label class="radio-inline">
                                        <input type="radio" name="recordValues.0.animalsVisible"
                                               value="no" ${'no' == step1 ? 'checked' : ''}>No
                                    </label>
                                    <label class="radio-inline">
                                        <input type="radio" name="recordValues.0.animalsVisible"
                                               value="unsure" ${'unsure' == step1 ? 'checked' : ''}>Unsure
                                    </label>
                                </div>
                            </div>
                        </div>
                        <g:hiddenField name="skipNextAction" value="true"/>
                    </div>

                    <div id="ct-animals-present" class="ct-item">

                        <div class="row">
                            <div class="col-sm-12">
                                <p><strong>Select animals that are present in the image</strong></p>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-sm-12">
                                <div class="btn-toolbar">
                                    <div id="ct-animals-btn-group" class="btn-group btn-group-sm" data-toggle="buttons">
                                        <label class="btn btn-default active">
                                            <input type="radio" name="options" id="ct-btn-all" class="btn-animal-filter" autocomplete="off" data-filter-tag="" checked>All
                                        </label>
                                        <label class="btn btn-default">
                                            <input type="radio" name="options" id="ct-sm-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="small mammals (<500g)">Small Mammals
                                        </label>
                                        <label class="btn btn-default">
                                            <input type="radio" name="options" id="ct-mm-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="medium mammals (0.5-5kg)">Medium Mammals
                                        </label>
                                        <label class="btn btn-default">
                                            <input type="radio" name="options" id="ct-lm-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="large mammals (>5kg)">Large Mammals
                                        </label>
                                        <label class="btn btn-default">
                                            <input type="radio" name="options" id="ct-reptiles-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="reptiles">Reptiles
                                        </label>
                                        <label class="btn btn-default">
                                            <input type="radio" name="options" id="ct-birds-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="birds">Birds
                                        </label>
                                    </div>

                                    <div class="btn-group btn-group-sm">
                                        <button type="button" id="ct-other-btn" class="btn btn-default btn-sm"
                                                data-toggle="button">Other</button>
                                    </div>

                                    <div class="btn-group btn-group-sm" style="height: 28px">
                                        <input id="ct-search-input" type="text" class="form-control input-sm"
                                               style="margin-bottom: 0;"
                                               placeholder="${message(code: 'default.input.filter.placeholder', default: "Filter")}">
                                    </div>

                                    <div id="ct-sort-btn-group" class="btn-group btn-group-sm" data-toggle="buttons">
                                        <label class="btn btn-default active" title="${message(code: 'default.button.default.sort.label', default: 'Default order')}" data-container="body">
                                            <input type="radio" name="options" id="button-sort-initial" autocomplete="off" data-sort-fn="initial" checked><i class="fa fa-random"></i>
                                        </label>
                                        <label class="btn btn-default" title="${message(code: 'default.button.alpha.sort.label', default: 'Sort alphabetically')}" data-container="body">
                                            <input type="radio" name="options" id="button-sort-alpha" autocomplete="off" data-sort-fn="alpha" checked><i class="fa fa-sort-alpha-asc"></i>
                                        </label>
                                        <label class="btn btn-default" title="${message(code: 'default.button.popularity.sort.label', default: 'Sort by most common in expedition')}" data-container="body">
                                            <input type="radio" name="options" id="button-sort-pop" autocomplete="off" data-sort-fn="common" checked><i class="fa fa-sort-numeric-asc"></i>
                                        </label>
                                        <label class="btn btn-default" title="${message(code: 'default.button.mychoices.sort.label', default: 'Sort by my previous choices')}" data-container="body">
                                            <input type="radio" name="options" id="button-sort-mychoices" autocomplete="off" data-sort-fn="previous" checked><i class="fa fa-sort-amount-desc"></i>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-sm-12 ct-sub-item-container">
                                <div class="ct-sub-item active sortable text-center" id="ct-animals-list">
                                    <g:set var="animalInfos"
                                           value="${ct.cameraTrapImageInfos(picklist: Picklist.get(template.viewParams.animalsPicklistId?.toLong()), project: taskInstance?.project)}"/>
                                    <g:render template="/transcribe/cameratrapWidget"
                                              model="${[imageInfos: animalInfos, picklistId: template.viewParams.animalsPicklistId?.toLong()]}"/>
                                </div>

                                <div class="ct-sub-item form-horizontal" id="ct-unlisted">

                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-sm-offset-2 col-sm-10">
                                                <div class="checkbox">
                                                    <label>
                                                        <g:checkBox name="recordValues.0.unknown" checked="${recordValues[0]?.unknown}"/> ${message(code: 'cameratrap.unknown.radio.yes.label', default: 'I don\'t know what the animal is')}
                                                    </label>
                                                </div>
                                            </div>
                                            <div class="col-sm-offset-2 col-sm-10">
                                                <div class="checkbox">
                                                    <label>
                                                        <g:checkBox name="recordValues.0.otherunlisted" checked="${recordValues[0]?.unknown}"/> ${message(code: 'cameratrap.unknown.radio.no.label', default: 'I know what the animal is but it is not in the lists.  Enter details below:')}
                                                    </label>
                                                </div>
                                            </div>
                                        </div>

                                        <g:set var="placeholders"
                                               value="${['Quokka (Setonix brachyurus)', 'Short-beaked Echidna (Tachyglossus aculeatus)', 'Western Quoll (Dasyurus geoffroii)', 'Platypus (Ornithorhynchus anatinus)', 'Forest kingfisher (Todiramphus macleayii)', 'Sand goanna (Varanus gouldii )', 'Central bearded dragon (Pogona vitticeps)']}"/>
                                        ${Collections.shuffle(placeholders)}
                                        <g:set var="unlisteds"
                                               value="${recordValues.findAll { it.value?.unlisted != null }.findAll {
                                                   it.value.unlisted
                                               }.collect { [i: it.key, v: it.value.unlisted] }.sort { it.i }.collect {
                                                   it.v
                                               }}"/>
                                        <g:each in="${unlisteds}" var="u" status="s">
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label" for="recordValues.${s}.unlisted">Species name</label>

                                                <div class="col-sm-10">
                                                    <g:textField class="speciesName form-control autocomplete"
                                                                 data-picklist-id="${template.viewParams.animalsPicklistId}"
                                                                 name="recordValues.${s}.unlisted"
                                                                 placeholder="${placeholders[s % placeholders.size()]}"
                                                                 value="${recordValues[s]?.unlisted}"/>
                                                </div>
                                            </div>
                                        </g:each>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label" for="recordValues.${unlisteds.size()}.unlisted">Species name</label>

                                            <div class="col-sm-10">
                                                <g:textField class="speciesName form-control autocomplete"
                                                             data-picklist-id="${template.viewParams.animalsPicklistId}"
                                                             name="recordValues.${unlisteds.size()}.unlisted"
                                                             placeholder="${placeholders[unlisteds.size() % placeholders.size()]}"/>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>

                    <div id="ct-animals-summary" class="ct-item ${validator ? 'active' : ''}">
                        <div class="row">
                            <div class="col-sm-12">
                                <p><strong>Animals visible:</strong> <span id="ct-animals-question-summary">${step1}</span>.
                                <p><strong>Selected animals</strong></p>
                            </div>

                            <div class="col-sm-12">
                                <div class="itemgrid ct-selection-grid"></div>
                            </div>

                            <div class="col-sm-12">
                                <div class="ct-unknown-selections-unknown">
                                    <span></span>
                                </div>
                            </div>

                            <div class="col-sm-12">
                                <div class="ct-unknown-selections">
                                    <label style="font-weight: bold; display: inline-block;">${message(code: 'cameratrap.transcribe.unlisted.label', default: 'Others:')}</label> <span></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div id="ct-full-image-container" class="ct-item clearfix"></div>
                </div>
            </div>

            <div class="text-right" style="margin-top: 20px; margin-bottom: 20px;">
                <button type="button" id="btnNext"
                        class="btn btn-primary btn-lg ${validator ? 'hidden' : ''}">${message(code: 'default.button.next.label', default: 'Next Step')} <i
                        class="fa fa-chevron-right"></i></button>
                <g:if test="${!validator}">
                    <button type="button" id="btnSave"
                            class="btn btn-primary btn-lg bvp-submit-button hidden">${message(code: 'default.button.save.short.label', default: 'Submit')}</button>
                </g:if>
                <g:else>
                    <button type="button" id="btnValidate"
                            class="btn btn-success btn-lg bvp-submit-button ${validator ? '' : 'hidden'}"><i
                            class="glyphicon glyphicon-ok glyphicon glyphicon-white"></i>&nbsp;${message(code: 'default.button.validate.label', default: 'Mark as Valid')}
                    </button>
                    <button type="button" id="btnDontValidate"
                            class="btn btn-danger btn-lg bvp-submit-button ${validator ? '' : 'hidden'}"><i
                            class="glyphicon glyphicon-remove glyphicon glyphicon-white"></i>&nbsp;${message(code: 'default.button.dont.validate.label', default: 'Mark as Invalid')}
                    </button>
                </g:else>
            </div>
        </div>
    </div>

    <div id="ct-fields" style="display: none;"></div>
</div>

<script id="selected-item-template" type="x-tmpl-mustache">
<div class="griditem bvpBadge">
    <div class="thumbnail ct-thumbnail {{selected}}" data-image-select-key="{{key}}" data-image-select-value="{{value}}">
        <span class="ct-badge ct-badge-sure"><i class="fa fa-check-circle"></i></span>
        <span class="ct-badge ct-badge-uncertain"><i class="fa fa-question-circle"></i></span>
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
    <div class="form-group">
        <label class="col-sm-2 control-label" for="recordValues.{{index}}.unlisted">Species name</label>
        <div class="col-sm-10">
            <input type="text" class="speciesName form-control autocomplete" data-picklist-id="${template.viewParams.animalsPicklistId}" id="recordValues.{{index}}.unlisted" name="recordValues.{{index}}.unlisted" placeholder="{{placeholder}}" />
        </div>
    </div>
</script>

<script id="input-template" type="x-tmpl-mustache">
    <input id="{{id}}" name="{{id}}" type="hidden" value="{{value}}" />
</script>

<script id="single-image-template" type="x-tmpl-mustache">
    <div id="ct-full-image" class="{{selected}}" style="position:relative;" data-image-select-value="{{value}}" data-image-select-key="{{key}}">
        <span class="ct-badge ct-badge-large ct-badge-sure" data-container="body" title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: 'There is definitely a {0} in the image', args: ['{{value}}'])}"><i class="fa fa-check-circle"></i></span>
        <span class="ct-badge ct-badge-large ct-badge-uncertain" data-container="body" title="${g.message(code: 'cameratrap.widget.uncertain.badge.title', default: 'There could possibly be a {0} in the image', args: ['{{value}}'])}"><i class="fa fa-check-circle"></i></span>
        {{#similarSpecies}}
            <span class="ct-info ct-info-large" data-container="body" title="${g.message(code: 'cameratrap.widget.similar.badge.title', default: "The {0} looks very similar to the {1}.  Please consider these other options before submitting your choices.", args: ['{{value}}', '{{similarSpecies}}'])}"><i class="fa fa-info-circle"></i></span>
        {{/similarSpecies}}
        <span class="ct-full-image-carousel-close">&times;</span>
        <img src="{{url}}" title="${message(code: 'cameratrap.carousel.dismiss', default: 'Click on the image to dismiss')}" data-container="body"/>
    </div>
</script>

<script id="carousel-template" type="x-tmpl-mustache">
    <div id="ct-full-image-carousel" data-interval="0" class="carousel slide {{selected}}" data-image-select-value="{{value}}" data-image-select-key="{{key}}">
        <span class="ct-badge ct-badge-large ct-badge-sure" data-container="body" title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: 'There is definitely a {0} in the image', args: ['{{value}}'])}"><i class="fa fa-check-circle"></i></span>
        <span class="ct-badge ct-badge-large ct-badge-uncertain" data-container="body" title="${g.message(code: 'cameratrap.widget.uncertain.badge.title', default: 'There could possibly be a {0} in the image', args: ['{{value}}'])}"><i class="fa fa-check-circle"></i></span>
        {{#similarSpecies}}
            <span class="ct-info ct-info-large" data-container="body" title="${g.message(code: 'cameratrap.widget.similar.badge.title', default: "The {0} looks very similar to the {1}.  Please consider these other options before submitting your choices.", args: ['{{value}}', '{{similarSpecies}}'])}"><i class="fa fa-info-circle"></i></span>
        {{/similarSpecies}}
        <span class="ct-full-image-carousel-close">&times;</span>
        <ol class="carousel-indicators">
            {{#imgs}}
                <li class="{{active}}" data-target="#ct-full-image-carousel" data-slide-to="{{idx}}"></li>
            {{/imgs}}
        </ol>
        <div class="carousel-inner" title="${message(code: 'cameratrap.carousel.dismiss', default: 'Click on the image to dismiss')}" data-container="body">
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
var imageInfos = <cl:json value="${animalInfos.infos}"/>;

var items = <cl:json value="${animalInfos.items}"/>;

var recordValues = <cl:json value="${recordValues}"/>;

var placeholders = <cl:json value="${placeholders}"/>;

cameratrap(imageInfos, items, recordValues, placeholders);
</r:script>