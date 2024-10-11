<%@ page import="au.org.ala.volunteer.FieldType; au.org.ala.volunteer.FieldCategory; au.org.ala.volunteer.DarwinCoreField" %>

<form>
    <div class="form-group">
        <label class="control-label" for="fieldName">Field:</label>
        <g:select name="fieldName" class="form-control" from="${DarwinCoreField.values().sort({ it.name() })}"/>
    </div>

    <div class="form-group">
        <label class="control-label" for="fieldTypeClassifier">Classifier:<cl:helpText><g:message code="field.classifier.help" default="Distinguishes multiple fields with the same type but only works on select templates"/></cl:helpText></label>
        <g:textField class="form-control" name="fieldTypeClassifier" value=""/>
    </div>

    <div class="form-group">
        <label class="control-label" for="label">Label (blank for default):</label>
        <g:textField class="form-control" name="label" value=""/>
    </div>

    <div class="form-group">
        <label class="control-label" for="category">Category:</label>
        <g:select class="form-control" name="category" from="${FieldCategory?.values()}" value="${FieldCategory.none}"/>
    </div>

    <div class="form-group">
        <label class="control-label" for="type">Type:</label>
        <g:select class="form-control" name="type" from="${FieldType?.values()}" keys="${FieldType?.values()*.name()}"
                  value="${FieldType.text}"/>
    </div>

    <div class="modal-footer">
        <button id="btnCancelAddField" class="btn btn-default">Cancel</button>
        <button id="btnSaveField" class="btn btn-primary">Add field</button>
    </div>

</form>

<script>

    $('#btnSaveField').click(function (e) {
        e.preventDefault();

        const fieldType = encodeURIComponent($("#fieldName").val());
        if (fieldType) {
            $('#btnCancelAddField').prop('disabled', 'disabled');
            $('#btnSaveField').prop('disabled', 'disabled');

            const url = "${createLink(controller: 'template', action: 'addField')}";
            let data = {
                id: ${templateInstance.id},
                fieldType: fieldType
            }

            let classifier = $('#fieldTypeClassifier').val();
            if (classifier) data.fieldTypeClassifier = encodeURIComponent(classifier);

            let label = $("#label").val();
            if (label) data.label = encodeURIComponent(label);

            let category = $("#category").val();
            if (category) data.category = encodeURIComponent(category);

            let type = $("#type").val();
            if (type) data.type = encodeURIComponent(type);

            $.ajax({
                type: "POST",
                url: url,
                data: data,
                dataType: "json"
            }).done(function(data, textStatus, jqXHR) {
                if (data['result'] === true) {
                    window.location.reload();
                    return false;
                } else {
                    if (data.message) {
                        alert(data.message);
                    }
                    $('#btnCancelAddField').prop('disabled', '');
                    $('#btnSaveField').prop('disabled', '');
                }
            }).fail(function(jqXHR, textStatus, errorThrown) {
                console.log("Error textStatus: " + textStatus);
                console.log("errorThrown: " + errorThrown);
                $('#btnCancelAddField').prop('disabled', '');
                $('#btnSaveField').prop('disabled', '');

                alert('There was an error adding the field: ' + errorThrown);
            });
        }
    });

    $("#btnCancelAddField").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>

