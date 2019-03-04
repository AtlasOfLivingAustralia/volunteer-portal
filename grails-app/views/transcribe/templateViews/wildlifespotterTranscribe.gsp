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
            <div class="row">
                <div id="ct-image-span" class="col-sm-6">
                    <div id="ct-image-well" class="panel panel-default">
                        <div class="panel-body">
                            <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                                <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                                    <g:imageViewer multimedia="${multimedia}"/>
                                </g:if>
                            </g:each>
                            <g:render template="/transcribe/cameraTrapImageSequence"/>

                            <div style="margin-top:10px" class="text-center">
                                <markdown:renderHtml><g:message code="wildlifespotter.sequenceImages.helpText" /></markdown:renderHtml>
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
                                                                        <img src="${cl.imageUrlPrefix(type: 'wildlifespotter', name: "${entry.hash}.png")}" title="${entry.name}">
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

                            <g:if test="${validator && transcribersAnswers && transcribersAnswers.size() > 0}">
                                Transcribers answers

                                <div class="row">
                                    <div class="col-sm-12">
                                        <table class="table table-striped confirmation-table">
                                            <tr>
                                                <td>Transcriber</td>
                                                <td>Problem With Image</td>
                                                <td>Animals Visible?</td>
                                                <td>Selected Animal</td>
                                                <td>Individual Count</td>
                                                <td>Comment</td>
                                            </tr>
                                            <tbody id="tbody-answer-summary">
                                            <g:each in="${transcribersAnswers}" var="answers" status="st">
                                                <g:set var="answer" value="${answers}"/>
                                                <tr>
                                                    <td><cl:userDisplayName userId="${answer.get('fullyTranscribedBy')}"/></td>
                                                    <g:set var="ans" value="${answer.get('fields')[0]}" />
                                                    <td>${ans.get('problemWithImage') ?: 'No'}</td>
                                                    <g:if test="${ans.get('noAnimalsVisible') || ans.get('noAnimalsVisible') == 'yes'}">
                                                        <td>No</td>
                                                    </g:if>
                                                    <g:elseif test="${ans.get('vernacularName') || ans.get('scientificName')}">
                                                        <td>Yes</td>
                                                        <td>
                                                            <g:set var="selectedAnimalInfos"
                                                                   value="${[wsParams.animals.find{t -> return ((ans.get('vernacularName') && t.vernacularName == ans.get('vernacularName')) || (ans.get('scientificName') && t.scientificName == ans.get('scientificName')))}]}"/>
                                                            <g:render template="/transcribe/wildlifeSpotterWidget"
                                                                      model="${[imageInfos: selectedAnimalInfos, isAnswers: true]}"/>
                                                        </td>
                                                       %{-- <td><div class="itemgrid ct-selection-transcribers" transcribedBy="${answer.get('fullyTranscribedBy')}"></div></td>--}%
                                                        %{--<td>${answer.get('fields')[0].get('vernacularName')} <i>(${(answer.get('fields')[0].get('scientificName'))})</i></td>--}%
                                                        <td>${ans.get('individualCount')}</td>
                                                        <td>${ans.get('comment')}</td>
                                                    </g:elseif>
                                                </tr>

                                            </g:each>
                                            </tbody>
                                        </table>

                                    </div>
                                </div>
                            </g:if>


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

        <script id="input-template" type="text/x-mustache-template">
            <input id="{{id}}" name="{{id}}" type="hidden" value="{{value}}" />
        </script>

        <script id="detail-template" type="text/x-mustache-template">
            <div class="detail-animal" >
                <div id="ct-full-image-carousel" data-interval="0" class="carousel slide" data-item-index="{{itemIndex}}">
                    <span class="ws-selector ws-selected ws-selected-large {{animal.selected}}" data-container="body" aria-selected="{{animal.isSelected}}" title="${g.message(code: 'wildlifespotter.widget.badge.title', args: ['{{animal.vernacularName}}'])}"><i class="fa fa-check"></i></span>
                    <span class="ws-full-image-carousel-close">&times;</span>
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