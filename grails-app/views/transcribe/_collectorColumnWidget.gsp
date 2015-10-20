<div class="collectorColumnWidget form-group ${cssClass}" fieldType="${field.fieldType}">%{-- col-md-12 --}%

    <div class="row">
        <div class="col-md-12">
            <g:textField tabindex="${tabindex}" name="recordValues.0.${field.fieldType}"
                         class="form-control autocomplete ${field.fieldType.toString()}"
                         validationRule="${validationRule?.name}"
                         value="${recordValues.get(0)?.get(field.fieldType.toString())}"/>
            <g:hiddenField name="recordValues.0.recordedByID" class="recordedByID" id="recordValues.0.recordedByID"
                           value="${recordValues[0]?.recordedByID?.encodeAsHTML()}"/>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <g:textField tabindex="${tabindex}" name="recordValues.1.${field.fieldType}"
                         class="form-control autocomplete ${field.fieldType.toString()}"
                         validationRule="${validationRule?.testEmptyValues ? "" : validationRule?.name}"
                         value="${recordValues.get(1)?.get(field.fieldType.toString())}"/>
            <g:hiddenField name="recordValues.1.recordedByID" class="recordedByID" id="recordValues.1.recordedByID"
                           value="${recordValues[1]?.recordedByID?.encodeAsHTML()}"/>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <g:textField tabindex="${tabindex}" name="recordValues.2.${field.fieldType}"
                         class="form-control autocomplete ${field.fieldType.toString()}"
                         validationRule="${validationRule?.testEmptyValues ? "" : validationRule?.name}"
                         value="${recordValues.get(2)?.get(field.fieldType.toString())}"/>
            <g:hiddenField name="recordValues.2.recordedByID" class="recordedByID" id="recordValues.2.recordedByID"
                           value="${recordValues[2]?.recordedByID?.encodeAsHTML()}"/>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <g:textField tabindex="${tabindex}" name="recordValues.3.${field.fieldType}"
                         class="form-control autocomplete ${field.fieldType.toString()}"
                         validationRule="${validationRule?.testEmptyValues ? "" : validationRule?.name}"
                         value="${recordValues.get(3)?.get(field.fieldType.toString())}"/>
            <g:hiddenField name="recordValues.3.recordedByID" class="recordedByID" id="recordValues.3.recordedByID"
                           value="${recordValues[3]?.recordedByID?.encodeAsHTML()}"/>
        </div>
    </div>

</div>