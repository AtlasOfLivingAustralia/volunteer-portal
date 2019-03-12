<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Picklist; au.org.ala.volunteer.FieldCategory;au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField; org.springframework.context.i18n.LocaleContextHolder" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>

        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title><cl:pageTitle title="${(validator) ? message(code: 'transcribe.templateViews.all.validate') : message(code: 'transcribe.templateViews.all.expedition')} ${taskInstance?.project?.i18nName}" /></title>
        <asset:stylesheet src="cameratrap"/>
    </head>
    <content tag="templateView">
        <div id="ct-container" >

            <g:set var="sequences" value="${sequenceNumbers(project: taskInstance.project, number: sequenceNumber, count: (Math.floor(Integer.parseInt(template.viewParams.showNImages)/2)))}"/>

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
                                                        checked="${recordValues[0]?.interesting == 'true'}"/> ${message(code: 'cameratrap.interesting.label', default: 'This image is particularly interesting')}
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
                                    <div class="faux-img-cell default">
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
                                <span style="display: none;" id="cameratrap_doYouWishAsAnswer"><g:message code="cameratrap.doYouWishAsAnswer"/></span>
                                <span style="display: none;" id="cameratrap_YouMustSelectOneAnimal"><g:message code="transcribe.templateViews.YouMustSelectOneAnimal"/></span>
                                <span style="display: none;" id="cameratrap_InvalidChoices"><g:message code="transcribe.templateViews.InvalidChoices"/></span>
                                <span style="display: none;" id="default_cancel"><g:message code="default.cancel"/></span>
                                <span style="display: none;" id="cameratrap_YesProcess"><g:message code="cameratrap.YesProcess"/></span>


                                <div class="row">
                                    <div class="col-sm-12">
                                        <p><strong><g:message code="transcribe.templateViews.cameratrapTranscribe.are_there_animals_visible"/></strong></p>
                                    </div>

                                    <div class="col-sm-12">
                                        <div id="ct-animals-question">
                                            <label class="radio-inline">
                                                <input type="radio" id="btn-animals-present" name="recordValues.0.animalsVisible"
                                                       value="<g:message code="default.yes"/>" ${'yes' == step1 ? 'checked' : ''}
                                                       label="${message(code:'default.yes')}"><g:message code="default.yes"/>
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="recordValues.0.animalsVisible"
                                                       label="${message(code:'default.no')}"
                                                       value="<g:message code="default.no"/>" ${'no' == step1 ? 'checked' : ''}><g:message code="default.no"/>
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="recordValues.0.animalsVisible"
                                                       label="${message(code:'transcribe.templateViews.cameratrapTranscribe.unsure')}"
                                                       value="<g:message code="transcribe.templateViews.cameratrapTranscribe.unsure"/>" ${'unsure' == step1 ? 'checked' : ''}><g:message code="transcribe.templateViews.cameratrapTranscribe.unsure"/>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                <g:hiddenField name="skipNextAction" value="true"/>
                            </div>

                            <div id="ct-animals-present" class="ct-item">

                                <div class="row">
                                    <div class="col-sm-12">
                                        <p><strong><g:message code="transcribe.templateViews.cameratrapTranscribe.select_animals_that_are_present"/></strong></p>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-sm-12">
                                        <div class="btn-toolbar">
                                            <div id="ct-animals-btn-group" class="btn-group btn-group-sm" data-toggle="buttons">
                                                <label class="btn btn-default active">
                                                    <input type="radio" name="options" id="ct-btn-all" class="btn-animal-filter" autocomplete="off" data-filter-tag="" checked><g:message code="transcribe.templateViews.cameratrapTranscribe.all"/>
                                                </label>
                                                <label class="btn btn-default">
                                                    <input type="radio" name="options" id="ct-sm-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="small_mammals"><g:message code="transcribe.templateViews.cameratrapTranscribe.small_mammals"/>
                                                </label>
                                                <label class="btn btn-default">
                                                    <input type="radio" name="options" id="ct-mm-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="medium_mammals"><g:message code="transcribe.templateViews.cameratrapTranscribe.medium_mammals"/>
                                                </label>
                                                <label class="btn btn-default">
                                                    <input type="radio" name="options" id="ct-lm-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="large_mammals"><g:message code="transcribe.templateViews.cameratrapTranscribe.large_mammals"/>
                                                </label>
                                                <label class="btn btn-default">
                                                    <input type="radio" name="options" id="ct-reptiles-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="reptiles"><g:message code="transcribe.templateViews.cameratrapTranscribe.reptiles"/>
                                                </label>
                                                <label class="btn btn-default">
                                                    <input type="radio" name="options" id="ct-birds-btn" class="btn-animal-filter" autocomplete="off" data-filter-tag="birds"><g:message code="transcribe.templateViews.cameratrapTranscribe.birds"/>
                                                </label>
                                            </div>

                                            <div class="btn-group btn-group-sm">
                                                <button type="button" id="ct-other-btn" class="btn btn-default btn-sm"
                                                        data-toggle="button"><g:message code="transcribe.templateViews.cameratrapTranscribe.other"/></button>
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
                                                   value="${dct.cameraTrapImageInfos(picklist: Picklist.get(template.viewParams.animalsPicklistId?.toLong()), project: taskInstance?.project)}"/>
                                            <g:render template="/transcribe/multiLanguageCameratrapWidget"
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
                                                       value="${[message(code: 'transcribe.templateViews.cameratrapTranscribe.placeholders.1'),
                                                                 message(code: 'transcribe.templateViews.cameratrapTranscribe.placeholders.2'),
                                                                 message(code: 'transcribe.templateViews.cameratrapTranscribe.placeholders.3'),
                                                                 message(code: 'transcribe.templateViews.cameratrapTranscribe.placeholders.4'),
                                                                 message(code: 'transcribe.templateViews.cameratrapTranscribe.placeholders.5'),
                                                                 message(code: 'transcribe.templateViews.cameratrapTranscribe.placeholders.6'),
                                                                 message(code: 'transcribe.templateViews.cameratrapTranscribe.placeholders.7')]}"/>
                                                ${Collections.shuffle(placeholders)}
                                                <g:set var="unlisteds"
                                                       value="${recordValues.findAll { it.value?.unlisted != null }.findAll {
                                                           it.value.unlisted
                                                       }.collect { [i: it.key, v: it.value.unlisted] }.sort { it.i }.collect {
                                                           it.v
                                                       }}"/>
                                                <g:each in="${unlisteds}" var="u" status="s">
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label" for="recordValues.${s}.unlisted"><g:message code="transcribe.templateViews.cameratrapTranscribe.species_name"/></label>

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
                                                    <label class="col-sm-2 control-label" for="recordValues.${unlisteds.size()}.unlisted"><g:message code="transcribe.templateViews.cameratrapTranscribe.species_name"/></label>

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
                                        <p><strong><g:message code="transcribe.templateViews.cameratrapTranscribe.animals_visible"/></strong>
                                            <span id="ct-animals-question-summary">${step1}</span> <!-- placeholder, will be filled by cameratraps.js -->
                                        </p>
                                        <p><strong><g:message code="transcribe.templateViews.cameratrapTranscribe.selected_animals"/></strong></p>
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
                <span class="ct-badge ct-badge-sure"><i class="fa fa-square-o"></i></span>
                <span class="ct-badge ct-badge-uncertain"><i class="fa fa-square-o"></i></span>
                <img src="{{squareThumbUrl}}" alt="{{value}}">
                <div class="ct-caption-table">
                    <div class="ct-caption-cell">
                        <div class="ct-caption" title="{{value}}">{{value}}</div>
                    </div>
                </div>
            </div>
        </div>
        </script>

        <script id="new-unlisted-template" type="x-tmpl-mustache">
            <div class="form-group">
                <label class="col-sm-2 control-label" for="recordValues.{{index}}.unlisted"><g:message code="transcribe.templateViews.cameratrapTranscribe.species_name"/></label>
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
                <span class="ct-badge ct-badge-large ct-badge-sure" data-container="body" title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: 'There is definitely a {0} in the image', args: ['{{value}}'])}"><i class="fa fa-square-o"></i></span>
                <span class="ct-badge ct-badge-large ct-badge-uncertain" data-container="body" title="${g.message(code: 'cameratrap.widget.uncertain.badge.title', default: 'There could possibly be a {0} in the image', args: ['{{value}}'])}"><i class="fa fa-square-o"></i></span>
                {{#similarSpecies}}
                    <span class="ct-info ct-info-large" data-container="body" title="${g.message(code: 'cameratrap.widget.similar.badge.title', default: "The {0} looks very similar to the {1}.  Please consider these other options before submitting your choices.", args: ['{{value}}', '{{similarSpecies}}'])}"><i class="fa fa-info-circle"></i></span>
                {{/similarSpecies}}
                <span class="ct-full-image-carousel-close">&times;</span>
                <img src="{{url}}" title="${message(code: 'cameratrap.carousel.dismiss', default: 'Click on the image to dismiss')}" data-container="body"/>
            </div>
        </script>

        <script id="carousel-template" type="x-tmpl-mustache">
            <div id="ct-full-image-carousel" data-interval="0" class="carousel slide {{selected}}" data-image-select-value="{{value}}" data-image-select-key="{{key}}">
                <span class="ct-badge ct-badge-large ct-badge-sure" data-container="body" title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: 'There is definitely a {0} in the image', args: ['{{value}}'])}"><i class="fa fa-square-o"></i></span>
                <span class="ct-badge ct-badge-large ct-badge-uncertain" data-container="body" title="${g.message(code: 'cameratrap.widget.uncertain.badge.title', default: 'There could possibly be a {0} in the image', args: ['{{value}}'])}"><i class="fa fa-square-o"></i></span>
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
        <asset:javascript src="transcribe/cameratrap" asset-defer=""/>
        <asset:script type="text/javascript">
            var imageInfos = <cl:json value="${animalInfos.infos}"/>;
            var items = <cl:json value="${animalInfos.items}"/>;
            var recordValues = <cl:json value="${recordValues}"/>;
            var placeholders = <cl:json value="${placeholders}"/>;
            cameratrap(imageInfos, items, recordValues, placeholders, "${LocaleContextHolder.getLocale().getLanguage()}","dct");
        </asset:script>
    </content>
</g:applyLayout>