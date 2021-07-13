<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body>

<content tag="pageTitle">General Settings</content>

<content tag="adminButtonBar">
</content>

<g:hasErrors>
    <div class="alert alert-danger">
        <ul>
            <g:eachError><li><g:message error="${it}"/></li></g:eachError>
        </ul>
    </div>
</g:hasErrors>

<g:form name="updateGeneralSettings" method="post" class="form-horizontal" action="updateGeneralSettings">
    <g:hiddenField name="id" id="projectId" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>

    <div class="form-group">
        <label class="control-label col-md-3" for="institutionId">Expedition institution</label>
        <div class="col-md-6">
        <g:select class="form-control" name="institutionId" id="institution" from="${institutionList}"
          optionKey="id"
          value="${projectInstance?.institution?.id}" noSelection="['':'- Select an Institution -']" />
        </div>
        <div id="institution-link-icon" class="col-md-3 control-label text-left">
            <i class="fa fa-home"></i> <a id="institution-link" href="${createLink(controller: 'institution',
                action: 'index', id: projectInstance?.institution?.id)}" target="_blank">Institution Page</a>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="name">Expedition name</label>

        <div class="col-md-6">
            <g:textField class="form-control" name="name" value="${projectInstance.name}"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="shortDescription">Short description</label>

        <div class="col-md-6">
            <g:textField class="form-control" name="shortDescription" value="${projectInstance.shortDescription}"/>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="description">Long description</label>

        <div class="col-md-9">
            <g:textArea name="description" class="mce form-control" rows="10" value="${projectInstance?.description}" />
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="template">Template</label>

        <div class="col-md-6">
            <select name="template" id="template" class="form-control">
                <cl:templateSelectOptions currentTemplateId="${projectInstance.template?.id}" templateList="${templates}" />
            </select>
        </div>

        <div class="col-md-3">
            <a class="btn btn-xs btn-default" title="Edit Template" style="margin: 5px;"
               href="${createLink(controller: 'template', action: 'edit', id: projectInstance?.template?.id)}">
                <i class="fa fa-pencil"></i>
            </a>
            <a class="btn btn-xs btn-default" title="View All Templates"
               href="${createLink(controller: 'template', action: 'list')}">
                <i class="fa fa-list"></i>
            </a>
        </div>
    </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="projectType">Expedition type</label>

        <div class="col-md-6">
            <g:select name="projectType" from="${projectTypes}" value="${projectInstance.projectType?.id}"
                      optionValue="label" optionKey="id" class="form-control"/>
        </div>
    </div>

        <div class="multipleTranscriptionsSupport">
            <div class="form-group">
                <label class="control-label col-md-3" for="transcriptionsPerTask">Number of Transcriptions</label>

                <div class="col-md-6">
                    <g:textField class="form-control" name="transcriptionsPerTask" value="${projectInstance.transcriptionsPerTask}"/>
                </div>
            </div>
            <div class="form-group">
                <label class="control-label col-md-3" for="thresholdMatchingTranscriptions">Threshold Of Matching Transcriptions (Auto Validation)</label>

                <div class="col-md-6">
                    <g:textField class="form-control" name="thresholdMatchingTranscriptions" value="${projectInstance.thresholdMatchingTranscriptions}"/>
                </div>
            </div>
        </div>

    <div class="form-group">
        <label class="control-label col-md-3" for="label">Tags</label>

        <div class="col-md-6">
            <input autocomplete="off" type="text" id="label" class="form-control typeahead"/>

        </div>

        <div id="labels" class="col-md-offset-3 col-md-9">
            <g:each in="${sortedLabels}" var="l">
                <span class="label ${labelColourMap[l.category]}" title="${l.category}">
                    ${l.value} <i class="fa fa-times-circle delete-label" data-label-id="${l.id}"></i>
                </span>
            </g:each>
        </div>

    </div>

    <div class="form-group">
        <div class="col-md-9 col-md-offset-3">
            <label for="imageSharingEnabled" class="checkbox">
                <g:checkBox name="imageSharingEnabled"
                            checked="${projectInstance.imageSharingEnabled}"/>&nbsp;Enable buttons to share images from this project to social networks
            </label>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-9 col-md-offset-3">
            <label for="harvestableByAla" class="checkbox">
                <g:checkBox name="harvestableByAla"
                            checked="${projectInstance.harvestableByAla}"/>&nbsp;Data from this expedition should be harvested by the Atlas of Living Australia
            </label>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-9 col-md-offset-3">
            <label for="extractImageExifData" class="checkbox">
                <g:checkBox name="extractImageExifData"
                            checked="${projectInstance.extractImageExifData}"/>&nbsp;EXIF data from staged images should be included in project exports
            </label>
        </div>
    </div>

    <div class="form-group">
        <div class="col-md-9 col-md-offset-3">
            <g:submitButton name="update" class="save btn btn-primary"
                            value="${message(code: 'default.button.update.label', default: 'Update')}"/>
        </div>
    </div>

</g:form>
<asset:javascript src="institution-dropdown" asset-defer=""/>
<asset:javascript src="label-autocomplete" asset-defer=""/>
<asset:script type="text/javascript">

    function setProjectDefaults() {
       var checkSupportMultipleTransUrl = "${createLink(controller: 'project', action: 'checkTemplateSupportMultiTranscriptions')}";

       var templateId = $('#template').val();
       const projectId = $('#projectId').val();
       $.ajax(checkSupportMultipleTransUrl, {type: 'POST', data: {templateId: templateId, projectId: projectId}}).done(function(data) {
           if (data && data.supportMultipleTranscriptions === 'true') {
               if (!$('#transcriptionsPerTask').val()) {
                   $('#transcriptionsPerTask').val('1');
               }

               if (!$('#thresholdMatchingTranscriptions').val()) {
                    $('#thresholdMatchingTranscriptions').val('0');
               }

               $('.multipleTranscriptionsSupport').show();
           } else {
               $('.multipleTranscriptionsSupport').hide();
           }
       });
    }

    setProjectDefaults();
    $('#template').change(function (e) {
        setProjectDefaults();
    });

    $('#updateGeneralSettings').submit(function(e) {
        if ($('.multipleTranscriptionsSupport').is(":visible")) {
            var transcriptionsPerTask = parseInt($('#transcriptionsPerTask').val());
            var thresholdMatchingTranscriptions = parseInt($('#thresholdMatchingTranscriptions').val());
            if ((!transcriptionsPerTask) || (!thresholdMatchingTranscriptions) ||
                (transcriptionsPerTask < 0) || (thresholdMatchingTranscriptions < 0)) {
                bootbox.alert("The template supports multiple transcriptions.<br><br> " +
                                "You must enter the number of transcriptions per task (1 or more) and set threshold of matching transcriptions to more than 0 and less than number of transcriptions.");
                e.preventDefault();
            } else if (thresholdMatchingTranscriptions > transcriptionsPerTask) {
                bootbox.alert("You must set threshold to more than 0 and less than number of transcriptions per task.");
                e.preventDefault();
            }
        }
    });

    jQuery(function($) {
        function onDeleteClick(e) {
            var deleteUrl = "${createLink(controller: 'project', action: 'removeLabel', id: projectInstance.id)}";
        //    showSpinner();
            $.ajax(deleteUrl, {type: 'POST', data: { labelId: e.target.dataset.labelId }})
                .done(function (data) {
                    var t = $(e.target);
                    var p = t.parent("span");
                    p.remove();
                })
                .fail(function() { alert("Couldn't remove label")});
                //.always(hideSpinner);
        }

        $('#labels').on('click', 'span.label i.delete-label', onDeleteClick);
    });
</asset:script>
</body>
</html>
