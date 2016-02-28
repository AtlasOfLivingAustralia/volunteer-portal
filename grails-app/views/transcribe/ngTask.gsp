<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="digivol-transcribe"/>

    <title><cl:pageTitle title="${(validator) ? 'Validate' : 'Expedition'} ${taskInstance?.project?.name}" /></title>
    %{--<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.4&sensor=false"></script></head>--}%
    <r:require module="angular-transcribe" />
    <r:script>
            // TODO Extract as reusable from taskGSP
            // global Object
            var VP_CONF = {
                taskId: "${taskInstance?.id}",
                picklistAutocompleteUrl: "${createLink(action: 'autocomplete', controller: 'picklistItem')}",
                updatePicklistUrl: "${createLink(controller: 'picklistItem', action: 'updateLocality')}",
                nextTaskUrl: "${createLink(controller: (validator) ? "validate" : "transcribe", action: 'showNextFromProject', id: taskInstance?.project?.id)}",
                isReadonly: "${isReadonly}",
                isValid: ${(taskInstance?.isValid) ? "true" : "false"}
        };

        <g:if test="${complete}">
            amplify.store("bvp_task_${complete}", null);
        </g:if>

        function saveFormState() {
            var dynamicDataSetFieldId = $("#observationFields").attr("entriesFieldId");

            var taskState = {
                action: $(".transcribeForm").attr('action'),
                taskId: ${taskInstance.id ?: 0},
                    dynamicDataSetFieldId: dynamicDataSetFieldId,
                    fields: []
                };
                $('[id*="recordValues\\."]').each(function (index, widget) {
                    var field = { id: $(widget).attr("id"), value: $(widget).val() };
                    taskState.fields.push(field);
            });

            amplify.store("bvp_task_${taskInstance.id ?: 0}", taskState);
        }

//taskInstance: taskInstance, recordValues: recordValues, isReadonly: isReadonly, template: project.template, nextTask: adjacentTasks.next, prevTask: adjacentTasks.prev, sequenceNumber: adjacentTasks.sequenceNumber, complete: params.complete

        angular.module('transcribe').constant("taskConfig", {
          task : <cl:json value="taskInstance" />,
          isReadOnly : <cl:json value="isReadOnly" />,
          template : <cl:json value="template" />,
          sequenceNumber : <cl:json value="sequenceNumber" />,
          fields : <cl:json value="fields" />,
          recordValues : <cl:json value="recordValues" />
        });
  </r:script>
</head>
<body>
<section id="transcription-template" data-ng-controller="TranscribeCtrl">
    <div class="container">
        <!-- Branding -->
        <div class="row branding-row">
            <div class="col-sm-5">


                <div class="transcription-branding">
                    <img src="<g:transcriptionLogoUrl id="${taskInstance?.project?.institution}"/>" class="img-responsive institution-logo-main pull-left">
                    <h1><g:link controller="project" action="show" id="${taskInstance?.project?.id}">${taskInstance?.project?.name}</g:link> ${taskInstance?.externalIdentifier}</h1>
                    <h2><g:transcribeSubheadingLine task="${taskInstance}" recordValues="${recordValues}" sequenceNumber="${sequenceNumber}"/></h2>
                </div>

            </div>
            <div class="col-sm-7 col-xs-12 transcription-controls">

                <div class="btn-group" role="group" aria-label="Transcription Controls">
                    <button type="button" class="btn btn-default" id="showNextFromProject" data-container="body"
                            title="Skip the to next image">Skip</button>
                    <vpf:taskTopicButton task="${taskInstance}" class="btn btn-default"/>
                    <g:link class="btn btn-default" controller="tutorials" action="index" target="_blank">View Tutorial</g:link>
                </div>

            </div>

        </div><!-- Branding Ends -->

        <div class="row">
            <div class="col-sm-6" data-ng-ctrl="ImageController" data-ng-cloak>
                <div class="media-container">
                    <leaflet center="center" layers="layers" defaults="defaults"></leaflet>
                </div>


                <div id="ct-image-sequence" class="faux-table text-center">
                    <div>
                        <div data-ng-repeat="img in preSeqImgs" data-ng-class="img.seqNo == -1 ? 'faux-empty-cell' : 'faux-img-cell'" data-seq-no="{{img.seqNo}}" data-ng-switch="img.seqNo == -1">
                            <img data-ng-switch-when="true" data-ng-src="img.thumbSrc"><img class="hidden" data-ng-src="img.fullSrc">
                        </div>
                        <div data-ng-class="faux-img-cell" data-seq-no="{{task.seqNo}}">
                            <img data-ng-src="task.thumbSrc"><img class="hidden" data-ng-src="task.fullSrc">
                        </div>
                        <div data-ng-repeat="img in postSeqImgs" data-ng-class="img.seqNo == -1 ? 'faux-empty-cell' : 'faux-img-cell'" data-seq-no="{{img.seqNo}}" data-ng-switch="img.seqNo == -1">
                            <img data-ng-switch-when="true" data-ng-src="img.thumbSrc"><img class="hidden" data-ng-src="img.fullSrc">
                        </div>

                    </div>
                </div>

                <div class="transcription-sharing">
                    See something interesting? Share it on <a href="#"><i class="fa fa-facebook fa-sm"></i></a> <a href="#"><i class="fa fa-twitter fa-sm"></i></a>
                </div>
            </div>
            <div class="col-sm-6" data-ng-controller="TranscriptionController">

                <uib-tabset>
                    <uib-tab ng-repeat="tab in tabs" heading="{{$index}}" active="tab.active" disabled="tab.disabled">
                        <legend ng-if="tab.title">{{tab.title}}</legend>

                        <dv-dynamic-field ng-repeat="field in tab.fields" field="field" />
                    </uib-tab>
                </uib-tabset>

            </div>
        </div>
    </div>
</section>

<script id="dv-bs-field-template" type="text/ng-template">
<div class="col-xs-{{field.colspan || 6}} form-group">
    <label>{{field.label}}</label>
    <a type="button" class="fa fa-question-circle input-hint" data-tooltip-placement="left" data-uib-tooltip="{{field.tooltip}}" ></a>
    <ng-transclude />
</div>
</script>

<script id="dv-field-text" type="text/ng-template">
<div class="col-xs-{{field.colspan || 6}} form-group">
    <label>{{field.label}}</label>
    <a type="button" class="fa fa-question-circle input-hint" data-tooltip-placement="left" data-uib-tooltip="{{field.tooltip}}" ></a>
    <input class="form-control" ng-required="field.required" type="{{field.type}}" value="field.value">
</div>
</script>
<script id="dv-field-select" type="text/ng-template">
<div class="col-xs-{{field.colspan || 6}} form-group">
    <label>{{field.label}}</label>
    <a type="button" class="fa fa-question-circle input-hint" data-tooltip-placement="left" data-uib-tooltip="{{field.tooltip}}" ></a>
    <select class="form-control" ng-required="field.required" ng-options="field.options"></select>
</div>
</script>
<script id="dv-field-latLong" type="text/ng-template">
<div class="col-xs-{{field.colspan || 6}}">
    <label>{{field.label}}</label>
    <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
    <div class="row">
        <div class="col-sm-3 col-xs-6">
            <input class="form-control" type="text" placeholder="H">
        </div>
        <div class="col-sm-3 col-xs-6">
            <input class="form-control" type="text" placeholder="M">
        </div>
        <div class="col-sm-3 col-xs-6">
            <input class="form-control" type="text" placeholder="S">
        </div>
        <div class="col-sm-3 col-xs-6">
            <select class="form-control" type="text" ng-options="['E','W']">
                <option value=""></option>
            </select>
        </div>
    </div>
</div>
</script>
<script id="dv-field-unknown" type="text/ng-template">
    <div class="alert">
        <p>This template doesn't support the field type.</p>
    </div>
</script>

<script id="dv-transcribe-page" type="text/ng-template">
    <legend>{{title}}</legend>

    <dv-dynamic-field ng-repeat="field in fields" field="field" />

    <div class="col-xs-12">
        <p>A collecting event is a unique combination of who (collector), when (date) and where (locality) a specimen was collected</p>
    </div>

    <div class="col-xs-6 form-group">
        <label>Verbatim Locality</label>
        <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
        <input class="form-control" type="text">
    </div>
    <div class="col-xs-6 form-group">
        <label>State Province</label>
        <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
        <input class="form-control" type="text">
    </div>
    <div class="col-xs-6 form-group">
        <label>Country</label>
        <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
        <select class="form-control">
            <option>1</option>
            <option>2</option>
            <option>3</option>
            <option>4</option>
            <option>5</option>
        </select>
    </div>

    <div class="col-xs-6 form-group">

        <label>City</label>
        <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
        <select class="form-control">
            <option>1</option>
            <option>2</option>
            <option>3</option>
            <option>4</option>
            <option>5</option>
        </select>


    </div>

    <div class="col-xs-6 form-group">

        <label>Collectors</label>
        <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
        <input class="form-control" type="text">
        <input class="form-control" type="text">


    </div>


    <div class="col-xs-6 form-group">
        <label>Donor</label>
        <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
        <input class="form-control" type="text">
    </div>

    <div class="col-xs-6 form-group">
        <label>Date Collected</label>
        <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
        <input class="form-control" type="text">
    </div>

    <div class="col-xs-6">
        <div class="row">
            <div class="col-xs-12 col-sm-6">
                <label>Depth from</label>
                <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
                <input class="form-control" type="text">
            </div>
            <div class="col-xs-12 col-sm-6">
                <label>Depth to</label>
                <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Tooltip on left"></a>
                <input class="form-control" type="text">
            </div>
        </div>
    </div>
    <div class="col-xs-6 form-group">
        <label>Time Collected</label>
        <a type="button" class="fa fa-question-circle input-hint" data-toggle="tooltip" data-placement="left" title="" data-original-title="Record exactly what appears on the label so that we have a searchable reference for the complete label set.

The symbols below can be used for degress (°), minutes and seconds, and make and female symbols, where needed."></a>
        <input class="form-control" type="text">
    </div>
    <div class="col-xs-12">
        Don't see any longtitude and latitude on the label? Use this <a type="button" data-toggle="modal" data-target="#myModal" class="btn btn-default" style="cursor: pointer;">mapping tool  <i class="fa fa-map-pin"></i></a>
    </div>
    <div class="col-xs-12">

        <div class="transcription-actions">
            <button type="submit" class="btn btn-default pull-right btn-next">Next <i class="fa fa-chevron-right fa-sm"></i></button>
            <button type="submit" class="btn btn-default pull-right">Save <i class="fa fa-check fa-sm"></i></button>
            <button type="submit" class="btn btn-default pull-left"><i class="fa fa-chevron-left fa-sm"></i> Back</button>
        </div>
    </div>
</script>
</body>
</html>