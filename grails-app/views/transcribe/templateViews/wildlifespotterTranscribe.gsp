<%@ page import="au.org.ala.volunteer.Picklist; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <title><cl:pageTitle title="${(validator) ? 'Validate' : 'Expedition'} ${taskInstance?.project?.name}" /></title>
        <asset:stylesheet src="wildlifespotter.css"/>
    </head>
    <content tag="templateView">
        <div id="ct-container" >

            <g:set var="wsParams" value="${template.viewParams2}" />
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
                    <div class="panel panel-default">
                        <div class="panel-heading"><h3 class="panel-title">Classification Status:</h3></div>
                        <div class="panel-body">
                            <div id="classification-status-no-animals-selected" class="form-horizontal">
                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <div class="checkbox">
                                            <label>
                                                <input type="checkbox" id="btn-animals-present" name="recordValues.0.noAnimalsVisible"
                                                       value="yes" ${'yes' == recordValues[0]?.noAnimalsVisible ? 'checked' : ''}> There's no animal in view
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <div class="checkbox">
                                            <label>
                                                <input type="checkbox" id="btn-problem-image" name="recordValues.0.problemWithImage"
                                                       value="yes" ${'yes' == recordValues[0]?.problemWithImage ? 'checked' : ''}> There's a problem with this image
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div id="classification-status-animals-selected" style="display: none;"></div>
                            <div class="text-right">
                                <g:if test="${!validator}">
                                    <button type="button" id="btnSave"
                                            class="btn btn-primary bvp-submit-button">${message(code: 'default.button.save.short.label', default: 'Submit')}</button>
                                </g:if>
                                <g:else>
                                    <button type="button" id="btnValidate"
                                            class="btn btn-success bvp-submit-button ${validator ? '' : 'hidden'}"><i
                                            class="glyphicon glyphicon-ok glyphicon glyphicon-white"></i>&nbsp;${message(code: 'default.button.validate.label', default: 'Mark as Valid')}
                                    </button>
                                    <button type="button" id="btnDontValidate"
                                            class="btn btn-danger bvp-submit-button ${validator ? '' : 'hidden'}"><i
                                            class="glyphicon glyphicon-remove glyphicon glyphicon-white"></i>&nbsp;${message(code: 'default.button.dont.validate.label', default: 'Mark as Invalid')}
                                    </button>
                                </g:else>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="ct-question-span" class="col-sm-6" style="">
                    <div id="camera-trap-questions" class="" data-interval="">
                        <div id="ct-item-container" class="ct-item-container">
                            <div id="ct-animals-present" class="ct-item active">
                                <div class="row">
                                    <div class="col-sm-12">
                                        <div class="btn-toolbar">
                                            <div class="btn-group">
                                                <input id="ct-search-input" type="text" class="form-control input-sm"
                                                       style="margin-bottom: 0; height: 34px;"
                                                       placeholder="${message(code: 'default.input.keywordSearch.placeholder', default: "Search by keyword")}">
                                            </div>
                                            <g:each var="cat" in="${wsParams.categories}" status="i">
                                                <div class="btn-group category-filter">
                                                    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" data-idx="$i">${cat.name} <span class="caret"></span></button>
                                                    <ul class="dropdown-menu">
                                                        <g:each var="entry" in="${cat.entries}" status="j">
                                                            <li>
                                                                <a role="button" tabindex="-1" data-cat-idx="${i}" data-entry-idx="${j}">
                                                                    <g:if test="${entry.hash}">
                                                                        <img src="${cl.imageUrlPrefix(type: 'wildlifespotter', name: "${entry.hash}_category.png")}" title="${entry.name}">
                                                                    </g:if>
                                                                    <g:else>
                                                                        ${entry.name}
                                                                    </g:else>
                                                                </a>
                                                            </li>
                                                        </g:each>
                                                    </ul>

                                                </div>
                                            </g:each>
                                        </div>
                                        <div id="ct-animals-no-filter">
                                            <p>Researchers are interested in the animals listed below.  If you spot
                                            an animal not on this list - choose the most appropriate of the general
                                            groups below.</p>
                                        </div>
                                        <div id="ct-animals-filter" style="display: none;">
                                        </div>
                                        <p class="sr-only">Click 'i' for more information about each animal</p>
                                        %{--, or press the 'i' key on your keyboard--}%
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-sm-12 ct-sub-item-container">
                                        <div class="ct-sub-item active sortable text-center" id="ct-animals-list">
                                            <g:set var="animalInfos"
                                                   value="${wsParams.animals}"/>
                                            <g:render template="/transcribe/wildlifeSpotterWidget"
                                                      model="${[imageInfos: animalInfos]}"/>
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

                            <div id="ws-dynamic-container" class="ct-item clearfix"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="ct-fields" style="display: none;"></div>
        </div>

        <script id="status-detail-list-template" type="text/x-mustache-template">
            <ul class="status_detail_list">
                {{#selectedAnimals}}
                <li data-item-index="{{index}}">
                    <div>
                        <div class="classificationRow">
                            <div class="animalName">{{name}}</div>
                            <button type="button" class="btn btn-mini btn-default animalDelete pull-right" tabindex="-1"><i aria-hidden="true" class="fa fa-close"></i><span class="sr-only">Delete selection</span></button>
                            <span class="animalNum pull-right">
                                <select tabindex="-1" name="numAnimals" class="numAnimals form-control">
                                    {{#options}}
                                    <option value="{{val}}" {{selected}}>{{val}}</option>
                                    {{/options}}
                                </select>
                            </span>
                            <button type="button" aria-expanded="false" class="btn btn-link saveCommentButton pull-right" tabindex="-1" style="display:none;">Save Comment</button>
                            <button type="button" aria-expanded="false" class="btn btn-link editCommentButton pull-right" tabindex="-1">Add Comment</button>
                        </div>
                        <div class="classificationComments">{{comment}}</div>
                        <div class="editClassificationComments" style="display: none;"><label class="sr-only">Comment on the {{name}} you found</label><textarea id="{{index}}-comment" class="form-control" rows="1">{{comment}}</textarea></div>
                    </div>
                </li>
                {{/selectedAnimals}}
            </ul>
        </script>

        <script id="selected-item-template" type="text/x-mustache-template">
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

        <script id="new-unlisted-template" type="text/x-mustache-template">
            <div class="form-group">
                <label class="col-sm-2 control-label" for="recordValues.{{index}}.unlisted">Species name</label>
                <div class="col-sm-10">
                    <input type="text" class="speciesName form-control autocomplete" data-picklist-id="${template.viewParams.animalsPicklistId}" id="recordValues.{{index}}.unlisted" name="recordValues.{{index}}.unlisted" placeholder="{{placeholder}}" />
                </div>
            </div>
        </script>

        <script id="input-template" type="text/x-mustache-template">
            <input id="{{id}}" name="{{id}}" type="hidden" value="{{value}}" />
        </script>

        <script id="detail-template" type="text/x-mustache-template">
            <div class="detail-animal" >
                <div id="ct-full-image-carousel" data-interval="0" class="carousel slide" data-item-index="{{itemIndex}}">
                    <span class="ct-badge ct-badge-large ct-badge-sure ws-selector ws-selected {{animal.selected}}" data-container="body" title="${g.message(code: 'wildlifespotter.widget.badge.title', default: 'There is a {0} in the image', args: ['{{animal.vernacularName}}'])}"><i class="fa fa-check-circle"></i></span>
                    <span class="ct-full-image-carousel-close">&times;</span>
                    <ol class="carousel-indicators">
                        {{#animal.images}}
                        <li class="{{active}}" data-target="#ct-full-image-carousel" data-slide-to="{{idx}}"></li>
                        {{/animal.images}}
                    </ol>
                    <div class="carousel-inner" data-container="body">
                        {{#animal.images}}
                        <div class="item {{active}}">
                            <cl:sizedImage prefix="wildlifespotter" name="{{hash}}" width="804" height="550" format="jpg" alt="{{animal.vernacularName}}" template="true"/>
                            %{--<img src="{{url}}" />--}%
                        </div>
                        {{/animal.images}}
                    </div>
                    <a class="carousel-control left" href="#ct-full-image-carousel" data-slide="prev">
                        <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
                        <span class="sr-only">Previous</span>
                    </a>
                    <a class="carousel-control right" href="#ct-full-image-carousel" data-slide="next">
                        <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
                        <span class="sr-only">Next</span>
                    </a>
                </div>
                <div class="description">
                    <h4 class="title">{{animal.vernacularName}}{{#animal.scientificName}} <span class="scientific-name">({{animal.scientificName}})</span>{{/animal.scientificName}}</h4>
                    <h4 class="features"><g:message code="wildlifespotter.detail.features" default="Distinguishing features"/></h4>
                    <div class="featurestext">{{{animal.description}}}</div>
                </div>
            </div>
        </script>

        <script id="filter-summary" type="text/x-mustache-template">
            <div class="filterInfo">
                <ul class="filterInfo show">
                    {{#categories}}
                    <li><strong>{{name}}:</strong><span>{{value}}</span></li>
                    {{/categories}}
                </ul>
                <a role="button" tabindex="-1" class="text clearall">Clear all</a>
            </div>
        </script>
        <asset:javascript src="transcribe/wildlifespotter" asset-defer=""/>
        <asset:script type="text/javascript">
            var imgPrefix = "<cl:imageUrlPrefix type="wildlifespotter" />";
            var wsParams = <cl:json value="${wsParams}"/>;
            var recordValues = <cl:json value="${recordValues}"/>;
            var placeholders = <cl:json value="${placeholders}"/>;
            wildlifespotter(wsParams, imgPrefix, recordValues, placeholders);
        </asset:script>
    </content>
</g:applyLayout>