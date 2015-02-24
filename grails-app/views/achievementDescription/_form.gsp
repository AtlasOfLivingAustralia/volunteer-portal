<%@ page import="au.org.ala.volunteer.AggregationType; au.org.ala.volunteer.AchievementType; au.org.ala.volunteer.AchievementDescription" %>


<div class="fieldcontain ${hasErrors(bean: achievementDescriptionInstance, field: 'name', 'error')} required">
    <label for="name">
        <g:message code="achievementDescription.name.label" default="Name" />
        <span class="required-indicator">*</span>
    </label>
    <g:textField class="input-xlarge" name="name" required="" value="${achievementDescriptionInstance?.name}"/>

</div>

<div class="fieldcontain ${hasErrors(bean: achievementDescriptionInstance, field: 'description', 'error')}">
    <label for="description">
        <g:message code="achievementDescription.description.label" default="Description" />
        <span class="required-indicator">*</span>
    </label>
    <g:textArea class="input-xxlarge" rows="5" name="description" value="${achievementDescriptionInstance?.description}"/>

</div>


<div class="fieldcontain required">
    <label for="type">
        <g:message code="achievementDescription.type.label" default="Type" />
        <span class="required-indicator">*</span>
    </label>
    <g:select name="type" from="${AchievementType?.values()}" keys="${AchievementType.values()*.name()}" required="" value="${achievementDescriptionInstance?.type?.name()}" />
    
</div>

<div class="fieldcontain esType ${hasErrors(bean: achievementDescriptionInstance, field: 'searchQuery', 'error')}">
    <label for="searchQuery">
        <g:message code="achievementDescription.searchQuery.label" default="Search Query" />
        <span class="required-indicator">*</span>
    </label>
    <g:textArea class="input-block-level" rows="10" name="searchQuery" value="${achievementDescriptionInstance?.searchQuery}"/>

</div>

<div class="fieldcontain esType ${hasErrors(bean: achievementDescriptionInstance, field: 'count', 'error')}">
    <label for="count">
        <g:message code="achievementDescription.count.label" default="Count" />
        <span class="required-indicator">*</span>
    </label>
    <g:field class="input-mini" name="count" type="number" min="0" value="${achievementDescriptionInstance?.count}"/>

</div>

<div class="fieldcontain agType ${hasErrors(bean: achievementDescriptionInstance, field: 'aggregationQuery', 'error')}">
    <label for="aggregationQuery">
        <g:message code="achievementDescription.aggregationQuery.label" default="Aggregation Query" />
        <span class="required-indicator">*</span>
    </label>
    <g:textArea class="input-block-level" rows="10" name="aggregationQuery" value="${achievementDescriptionInstance?.aggregationQuery}"/>

</div>

<div class="fieldcontain agType ${hasErrors(bean: achievementDescriptionInstance, field: 'aggregationType', 'error')}">
    <label for="aggregationType">
        <g:message code="achievementDescription.aggregationType.label" default="Aggregation Type" />
        <span class="required-indicator">*</span>
    </label>
    <g:select name="type" from="${AggregationType?.values()}" keys="${AggregationType.values()*.name()}" value="${achievementDescriptionInstance?.aggregationType?.name()}" />

</div>

<div class="fieldcontain grType ${hasErrors(bean: achievementDescriptionInstance, field: 'code', 'error')}">
    <label for="code">
        <g:message code="achievementDescription.badge.label" default="Code" />
        <span class="hidden required-indicator">*</span>
    </label>
    <g:textArea class="input-block-level" rows="10" name="code" value="${achievementDescriptionInstance?.code}"/>

</div>

<g:hiddenField name="badge" value="${achievementDescriptionInstance?.badge}" />

<img id="badge-image" src="<cl:achievementBadgeUrl achievement="${achievementDescriptionInstance}" />" width="140" height="140" />

<div class="fieldcontain ${hasErrors(bean: achievementDescriptionInstance, field: 'badge', 'error')}">
    <label for="badge">
        <g:message code="achievementDescription.badge.label" default="Badge" />
    </label>
    <input type="file" id="file-select" />
    <input type="button" id="upload-button" class="btn" value="Upload"/>
</div>

<div id="upload-progress" class="fieldcontain hidden">
    <div class="progress progress-striped active">
        <div class="bar" style="width: 0%;"></div>
    </div>
</div>

<%--div class="fieldcontain ${hasErrors(bean: achievementDescriptionInstance, field: 'badge', 'error')} required">
	<label for="badge">
		<g:message code="achievementDescription.badge.label" default="Badge" />
		<span class="required-indicator">*</span>
	</label>
	<g:textField name="badge" required="" value="${achievementDescriptionInstance?.badge}"/>

</div--%>

<r:script>
jQuery(function($) {
    var badgeBase = "${cl.achievementBadgeBase()}";
    var noBadgeUrl = "<g:resource dir="/images/achievements" file="blank.png" />";

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
        $(selector + ' input, ' + selector + ' textarea').prop('required', on);
        //else $(selector + ' input').removeProp('required');
    }

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