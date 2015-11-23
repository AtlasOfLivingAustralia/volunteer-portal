<%@ page import="au.org.ala.volunteer.AggregationType; au.org.ala.volunteer.AchievementType; au.org.ala.volunteer.AchievementDescription" %>
<r:require modules="codemirror-json, codemirror-groovy, codemirror-codeedit, codemirror-sublime, codemirror-monokai"/>

<div class="form-group ${hasErrors(bean: achievementDescriptionInstance, field: 'name', 'has-error')} required">
    <label class="control-label col-md-3" for="name">
        <g:message code="achievementDescription.name.label" default="Name"/>
    </label>

    <div class="col-md-6">
        <g:textField class="form-control" name="name" required="" value="${achievementDescriptionInstance?.name}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: achievementDescriptionInstance, field: 'description', 'has-error')} required">
    <label class="control-label col-md-3" for="description">
        <g:message code="achievementDescription.description.label" default="Description"/>    </label>

    <div class="col-md-6">
        <g:textArea class="form-control" rows="5" name="description" required=""
                    value="${achievementDescriptionInstance?.description}"/>
    </div>
</div>

<div class="form-group required">
    <label class="control-label col-md-3" for="type">
        <g:message code="achievementDescription.type.label" default="Type"/>    </label>

    <div class="col-md-6">
        <g:select name="type" class="form-control" from="${AchievementType?.values()}" keys="${AchievementType.values()*.name()}" required=""
                  value="${achievementDescriptionInstance?.type?.name()}"/>
    </div>
</div>

<div class="form-group esType ${hasErrors(bean: achievementDescriptionInstance, field: 'searchQuery', 'has-error')}">
    <label class="control-label col-md-3" for="searchQuery">
        <g:message code="achievementDescription.searchQuery.label" default="Search Query"/>    </label>

    <div class="col-md-9">
        <g:textArea class="input-block-level" rows="10" name="searchQuery"
                    value="${achievementDescriptionInstance?.searchQuery}"/>
    </div>
</div>

<div class="form-group esType ${hasErrors(bean: achievementDescriptionInstance, field: 'count', 'has-error')}">
    <label class="control-label col-md-3" for="count">
        <g:message code="achievementDescription.count.label" default="Count"/>    </label>

    <div class="col-md-6">
        <g:field class="form-control" name="count" type="number" min="0"
                 value="${achievementDescriptionInstance?.count}"/>
    </div>
</div>

<div class="form-group agType ${hasErrors(bean: achievementDescriptionInstance, field: 'aggregationQuery', 'has-error')}">
    <label class="control-label col-md-3" for="aggregationQuery">
        <g:message code="achievementDescription.aggregationQuery.label" default="Aggregation Query"/>    </label>

    <div class="col-md-9">
        <g:textArea class="form-control" rows="10" name="aggregationQuery"
                    value="${achievementDescriptionInstance?.aggregationQuery}"/>
    </div>
</div>

<div class="form-group grType ${hasErrors(bean: achievementDescriptionInstance, field: 'code', 'has-error')}">
    <label class="control-label col-md-3" for="code">
        <g:message code="achievementDescription.badge.label" default="Code"/>
        <span class="hidden required-indicator">*</span>
    </label>

    <div class="col-md-9">
        <g:textArea class="form-control" rows="10" name="code" value="${achievementDescriptionInstance?.code}"/>
    </div>
</div>

<div class="form-group ${hasErrors(bean: achievementDescriptionInstance, field: 'badge', 'has-error')}">
    <label class="control-label col-md-3" for="badge">
        <g:message code="achievementDescription.badge.label" default="Badge"/>
    </label>

    <div class="col-md-9">
        <g:hiddenField name="badge" value="${achievementDescriptionInstance?.badge}"/>
        <img id="badge-image" src="<cl:achievementBadgeUrl achievement="${achievementDescriptionInstance}"/>"
             width="140" height="140"/>
        <input type="file" id="file-select" data-filename-placement="inside"/>
        <input type="button" id="upload-button" class="btn btn-success" value="Upload"/>
    </div>
</div>

<div id="upload-progress" class="fieldcontain hidden">
    <div class="progress progress-striped active">
        <div class="bar" style="width: 0%;"></div>
    </div>
</div>

<r:script>
jQuery(function($) {
    var id = "${achievementDescriptionInstance?.id ?: 0}"
    var badgeBase = "${cl.achievementBadgeBase()}";
    var noBadgeUrl = "<g:resource dir="/images/achievements" file="blank.png"/>";

    function toggleTypeFields() {
        var type = $('#type').val();
        switch (type) {
            case "ELASTIC_SEARCH_QUERY":
                toggleEsFields(true);
                toggleGroovyFields(false);
                toggleEsAgFields(false);
                break;
            case "GROOVY_SCRIPT":
                toggleEsFields(false);
                toggleGroovyFields(true);
                toggleEsAgFields(false);
                break;
            case "ELASTIC_SEARCH_AGGREGATION_QUERY":
                toggleEsFields(true);
                toggleEsAgFields(true);
                toggleGroovyFields(true);
                break;
        }
    }

    function toggleEsFields(on) { toggleFields('.esType', on) }
    function toggleEsAgFields(on) { toggleFields('.agType', on) }
    function toggleGroovyFields(on) { toggleFields('.grType', on) }

    function toggleFields(selector, on) {
        $(selector).toggleClass('required', on).toggleClass('hidden', !on);
        $(selector + ' span.required-indicator').toggleClass('hidden', !on);
        //$(selector + ' input, ' + selector + ' textarea').prop('required', on);
        //else $(selector + ' input').removeProp('required');
    }

    var searchEditor = CodeMirror.fromTextArea(document.getElementById("searchQuery"), {
        matchBrackets: true,
        autoCloseBrackets: true,
        mode: "application/json",
        lineWrapping: true,
        theme: 'monokai'
    });
    var aggEditor = CodeMirror.fromTextArea(document.getElementById("aggregationQuery"), {
        matchBrackets: true,
        autoCloseBrackets: true,
        mode: "application/json",
        lineWrapping: true,
        theme: 'monokai'
    });
    var codeEditor = CodeMirror.fromTextArea(document.getElementById("code"), {
        matchBrackets: true,
        autoCloseBrackets: true,
        mode: "text/x-groovy",
        lineWrapping: true,
        theme: 'monokai'
    });

    function updateTextArea(editor, event) {
        var ta = editor.getTextArea();
        var val = editor.getValue();
        ta.value = val;
        //editor.getTextArea().value = editor.getValue()
    }

    searchEditor.on('change', updateTextArea);
    aggEditor.on('change', updateTextArea);
    codeEditor.on('change', updateTextArea);

    toggleTypeFields();
    $('#type').change(function(e) { toggleTypeFields(); });

    function upload(event) {
        event.preventDefault();
        // Get the selected files from the input.
        var files = $('#file-select').prop('files');
        // Create a new FormData object.
        var formData = new FormData();
        // Loop through each of the selected files.
        if (files.length == 0) return;

        var file = files[0];

        // Check the file type.
        if (!file.type.match('image.*')) {
            alert("File type " + file.type + "doesn't match image.*");
            return;
        }

        if (id != 0) formData.append('id', id);

        // Add the file to the request.
        formData.append('imagefile', file, file.name);
        var r = $.ajax({
            type: 'POST',
            headers: {
                Accept : "application/json"
            },
            url: '${createLink(controller: 'achievementDescription', action: 'uploadBadgeImage')}?format=json',
            data: formData,
            processData: false,
            contentType: false,
            xhr: uploadProgressXhrFactory
        });

        event.target.innerHTML = 'Uploading...';
        r.done(function( data, textStatus, jqXHR ) {
            $('#upload-progress').addClass('hidden');
            $('#badge').val(data.filename).trigger('change');
        });

        r.fail(function ( jqXHR, textStatus, errorThrown ) {
            $('#upload-progress').addClass('hidden');
            alert("Upload failed :(");
            console.log(errorThrown);
        });
    }

    function uploadProgressXhrFactory()
    {
        var xhr = new window.XMLHttpRequest();
        //Upload progress
        xhr.upload.addEventListener("progress", function(evt){
            if (evt.lengthComputable) {
                var percentComplete = evt.loaded / evt.total;
                $('#upload-progress').removeClass('hidden');
                $('#upload-progress bar').width(percentComplete*100+"%");
            }
        }, false);
        return xhr;
    }

    $('#upload-button').click(upload);

    $('#badge').change(function (e) {
        var i = $(e.target).val();
        var src = i ? badgeBase + i : noBadgeUrl;
        $('#badge-image').attr('src',src);
    });

});
</r:script>