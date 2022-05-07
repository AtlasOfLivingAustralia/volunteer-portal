<%@ page import="au.org.ala.volunteer.Picklist; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.TemplateField; au.org.ala.volunteer.DarwinCoreField" %>
<sitemesh:parameter name="useFluidLayout" value="${true}"/>
<g:applyLayout name="digivol-task" model="${pageScope.variables}">
    <head>
        <title><cl:pageTitle title="${(validator) ? 'Validate' : 'Expedition'} ${taskInstance?.project?.name}" /></title>
        <asset:stylesheet src="audiotranscribe.css"/>
        <asset:stylesheet src="inline-player.css"/>
    </head>
    <content tag="templateView">
        <div id="ct-container" >

            <g:set var="wsParams" value="${template.viewParams2}" />
            <div class="row">
                <div id="ct-image-span" class="col-sm-6">
                    <div id="ct-image-well" class="panel panel-default">
                        <div class="panel-body">
                            <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                                <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('audio/')}">
                                    <g:audioWaveViewer multimedia="${multimedia}" waveColour="${taskInstance.project.institution?.themeColour}"/>
                                </g:if>
                            </g:each>
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
                                                <input type="checkbox" id="btn-animals-present" name="recordValues.0.noAudibleAnimal"
                                                       value="yes" ${'yes' == recordValues[0]?.noAudibleAnimal ? 'checked' : ''}> There was no audible animal call.
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <div class="checkbox">
                                            <label>
                                                <input type="checkbox" id="btn-problem-image" name="recordValues.0.problemWithAudio"
                                                       value="yes" ${'yes' == recordValues[0]?.problemWithAudio ? 'checked' : ''}> There's a problem with this audio clip.
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
                                            class="btn btn-success bvp-submit-button ${validator ? '' : 'hidden'}">
                                        ${message(code: 'default.button.validate.label', default: 'Submit validation')}
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
                                                                        <img src="${cl.imageUrlPrefix(type: 'wildlifespotter', name: "${entry.hash}.${entry.ext?:'png'}")}" height="100" width="100" title="${entry.name}">
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
                                            <div class="btn-group pull-right" role="group" aria-label="...">
                                                <a href="${createLink(controller: pageController, action: pageAction, params:[id: params.id])}" aria-label="Display items as grid" class="btn btn-default btn-xs ${params.mode == 'list' ? '' : 'active'}"><i class="glyphicon glyphicon-th-large "></i></a>
                                                <a href="${createLink(controller: pageController, action: pageAction, params:[id: params.id, mode:'list'])}" aria-label="Display items as list" class="btn btn-default btn-xs ${params.mode != 'list' ? '' : 'active'}"><i class="glyphicon glyphicon-th-list"></i></a>
                                            </div>
                                        </div>
                                        <div id="ct-animals-no-filter">
                                            <p>Researchers are interested in the animals listed below.  If you can hear
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
                                        <div class="ct-sub-item active sortable" id="ct-animals-list">
                                            <g:set var="animalInfos"
                                                   value="${wsParams.animals}"/>
                                            <g:if test="${mode == 'list'}">
                                                <g:render template="/transcribe/audioAnimalWidget"
                                                          model="${[imageInfos: animalInfos]}"/>
                                            </g:if>
                                            <g:else>
                                                <g:render template="/transcribe/wildlifeSpotterWidget"
                                                          model="${[imageInfos: animalInfos]}"/>
                                            </g:else>
                                        </div>
                                    </div>
                                </div>

                                <g:hiddenField name="skipNextAction" value="true"/>
                            </div>

                            <g:if test="${validator && transcribersAnswers && transcribersAnswers.size() > 0}">
                                <br>
                                <h4>Transcribers answers</h4>

                                <div class="row">
                                    <div class="col-sm-12">
                                        <table class="table table-striped confirmation-table">
                                            <tr>
                                                <th>Transcriber</th>
                                                <th>Problem With Image</th>
                                                <th>Animals Visible?</th>
                                                <th>Selected Animal</th>
%{--                                                <th>Individual Count</th>--}%
                                                <th>Comment</th>
                                            </tr>
                                            <tbody id="tbody-answer-summary">
                                                <g:each in="${transcribersAnswers}" var="answers" status="st">
                                                    <g:set var="answer" value="${answers}"/>
                                                    <tr>
                                                        <th><cl:userDisplayName userId="${answer.get('fullyTranscribedBy')}"/></th>

                                                        <g:set var="ans" value="${answer.get('fields')[0]}" />
                                                        <td>${ans.get('problemWithImage') ?: 'No'}</td>
                                                        <g:if test="${ans.get('noAnimalsVisible') || ans.get('noAnimalsVisible') == 'yes'}">
                                                            <td>No</td>
                                                        </g:if>

                                                        <g:elseif test="${ans.get('vernacularName') || ans.get('scientificName')}">
                                                            <g:each var="recordIdx" in="${ (0 ..(answer.get('fields').size() -1)) }" >
                                                                <g:set var="selectedAnimalAns" value="${answer.get('fields')?.get(recordIdx)}" />
                                                                <g:set var="selectedAnimalInfos"
                                                                       value="${[wsParams.animals.find{t -> return ((selectedAnimalAns?.get('vernacularName') && t.vernacularName == selectedAnimalAns?.get('vernacularName')) || (selectedAnimalAns?.get('scientificName') && t.scientificName == selectedAnimalAns?.get('scientificName')))}]}"/>

                                                                <g:if test="${selectedAnimalInfos?.size() > 0 && selectedAnimalInfos[0] == null}">
                                                                    <g:if test="${recordIdx > 0}"><tr></g:if>
                                                                    <td>
                                                                        <span style="color: red;">Invalid Transcription</span><br/>
                                                                        Animal option no longer in template
                                                                    </td>
                                                                    <td colspan="2"></td>
                                                                    <td>
                                                                        <g:render template="/transcribe/wildlifeSpotterWidgetInvalid"
                                                                                  model="${[invalidVernacularName: selectedAnimalAns?.get('vernacularName')]}"/>
                                                                    </td>
%{--                                                                    <td>${selectedAnimalAns?.get('individualCount')}</td>--}%
                                                                    <td>${selectedAnimalAns?.get('comment')}</td>
                                                                    <g:if test="${recordIdx > 0}"></tr></g:if>
                                                                </g:if>
                                                                <g:else>
                                                                    <g:if test="${recordIdx == 0}">
                                                                        <td>Yes</td>
                                                                        <td>
                                                                            <g:render template="/transcribe/wildlifeSpotterWidget"
                                                                                      model="${[imageInfos: selectedAnimalInfos, isAnswers: true]}"/>
                                                                        </td>
%{--                                                                        <td>${selectedAnimalAns?.get('individualCount')}</td>--}%
                                                                        <td>${selectedAnimalAns?.get('comment')}</td>
                                                                    </g:if>
                                                                    <g:else>
                                                                        <tr>
                                                                            <th colspan="3"></th>
                                                                            <td>
                                                                                <g:render template="/transcribe/wildlifeSpotterWidget"
                                                                                          model="${[imageInfos: selectedAnimalInfos, isAnswers: true]}"/>
                                                                            </td>
%{--                                                                            <td>${selectedAnimalAns?.get('individualCount')}</td>--}%
                                                                            <td>${selectedAnimalAns?.get('comment')}</td>
                                                                        </tr>
                                                                    </g:else>
                                                                </g:else>


                                                            </g:each>
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
                            <div class="animalName">{{name}} <i>({{scientificName}})</i></div>
                            <button type="button" class="btn btn-mini btn-default animalDelete pull-right" tabindex="-1"><i aria-hidden="true" class="fa fa-close"></i><span class="sr-only">Delete selection</span></button>
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
                            <cl:sizedImage prefix="wildlifespotter" name="{{hash}}" width="402" height="275" format="jpg" alt="{{animal.vernacularName}}" template="true"/>
                            %{--<img src="{{url}}" />--}%
                        </div>
                        {{/animal.images}}
                    </div>
                </div>
                <div class="description">
                    <h4 class="title">{{animal.vernacularName}}{{#animal.scientificName}} <span class="scientific-name">({{animal.scientificName}})</span>{{/animal.scientificName}}</h4>
                    <h4 class="features"><g:message code="wildlifespotter.detail.features" default="Distinguishing features"/></h4>
                    <div class="featurestext">{{{animal.description}}}</div>
                    <h4 class="audio-samples"><g:message code="wildlifespotter.detail.audio.samples" default="Audio Samples"/></h4>
%{--                    <div class="audio-samples-audio">--}%
%{--                        <ul class="flat">--}%
%{--                            {{#animal.audio}}--}%
%{--                            <li class="sm2_link" style="padding-bottom: 0.3em;">--}%
%{--                                <cl:audioSample prefix="audiotranscribe" name="{{hash}}" format="{{ext}}" linkText="Audio Sample {{idx + 1}}" template="true"/>--}%
%{--                            </li>--}%
%{--                            {{/animal.audio}}--}%
%{--                        </ul>--}%
%{--                    </div>--}%
                    <div class="audio-samples-wave" style="padding-bottom: 2em;">

                        {{#animal.audio}}
                        %{-- do a list, then put URL in data attr or something. Write JS method to pull URL from attr and load wavesurfer... --}%
                        <div class="row" style="padding-bottom: 0.5em;">
                            <div class="col-sm-1"><a class="btn btn-next audio-sample-detail-play" data-action-play="{{hash}}"><i class="fa fa-2x fa-play-circle-o"></i></a></div>
                            <div class="col-sm-4 audio-sample-detail" style="border-radius: 4px; border: 1px solid #ddd;"
                                 data-play-link="{{hash}}"
                                 data-audio-file='<cl:audioUrl prefix="audiotranscribe" name="{{hash}}" format="{{ext}}" template="true"/>'></div>
                        </div>
                        {{/animal.audio}}

                    </div>
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

        <asset:javascript src="transcribe/audiotranscribe" asset-defer=""/>
        <script src="https://unpkg.com/wavesurfer.js"></script>

        <asset:script type="text/javascript">
            var imgPrefix = "<cl:imageUrlPrefix type="wildlifespotter" />";
            var wsParams = <cl:json value="${wsParams}"/>;
            var recordValues = <cl:json value="${recordValues}"/>;
            var placeholders = <cl:json value="${placeholders}"/>;
            wildlifespotter(wsParams, imgPrefix, recordValues, placeholders);
        </asset:script>

        <asset:script type="text/javascript">
            $(document).ready(function () {

            });
        </asset:script>
    </content>
</g:applyLayout>