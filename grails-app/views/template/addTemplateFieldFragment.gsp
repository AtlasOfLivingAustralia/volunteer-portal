<%@ page import="au.org.ala.volunteer.FieldType; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.DarwinCoreField" %>

<div class="form-horizontal">

    <div class="control-group">
        <label class="control-label" for="fieldName">Field:</label>
        <div class="controls">
            <g:select name="fieldName" from="${DarwinCoreField.values().sort({ it.name() })}"/>
        </div>
    </div>
    <div class="control-group">
        <label class="control-label" for="fieldTypeClassifier">Classifier:</label>
        <div class="controls">
            <g:textField name="fieldTypeClassifier" value=""/>
        </div>
    </div>
    <div class="control-group">
        <label class="control-label" for="label">Label (blank for default):</label>
        <div class="controls">
            <g:textField name="label" value="" />
        </div>
    </div>
    <div class="control-group">
        <label class="control-label" for="category">Category:</label>
        <div class="controls">
            <g:select name="category" from="${FieldCategory?.values()}" value="${FieldCategory.none}" />
        </div>
    </div>
    <div class="control-group">
        <label class="control-label" for="type">Type:</label>
        <div class="controls">
            <g:select name="type" from="${FieldType?.values()}" keys="${FieldType?.values()*.name()}" value="${FieldType.text}" />
        </div>
    </div>

    <div class="control-group">
        <div class="controls">
            <button id="btnCancelAddField" class="btn">Cancel</button>
            <button id="btnSaveField" class="btn btn-primary">Add field</button>
        </div>
    </div>

</div>

<script>
    $('#btnSaveField').click(function(e) {
        e.preventDefault();
        var fieldType = encodeURIComponent($("#fieldName").val());
        if (fieldType) {
            var url = "${createLink(controller:'template', action:'addField', id:templateInstance.id)}?fieldType=" + fieldType;

            var classifier = $('#fieldTypeClassifier').val();
            if (classifier) {
                url += "&fieldTypeClassifier=" + encodeURIComponent(classifier);
            }

            var label= $("#label").val();
            if (label) {
                url += "&label=" + encodeURIComponent(label);
            }
            var category = $("#category").val();
            if (category) {
                url += "&category=" + encodeURIComponent(category);
            }
            var type = $("#type").val();
            if (type) {
                url += "&type=" + encodeURIComponent(type);
            }
            window.location = url;
        }

    });

    $("#btnCancelAddField").click(function(e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>

