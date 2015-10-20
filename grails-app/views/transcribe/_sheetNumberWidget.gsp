<div class="sheetNumberWidget" targetField="${field.fieldType}">

    <div class="form-group">
        <div class="col-md-3">
            <g:textField tabindex="${tabindex}" name="${field.fieldType}.sheetNumber" class="form-control sheetNumber"
                         value="" validationRule="${field.validationRule}"/>
        </div>

        <div class="col-md-1">
            of
        </div>

        <div class="col-md-3">
            <g:textField tabindex="${tabindex}" name="${field.fieldType}.sheetNumberOf" class="form-control sheetNumberOf"
                         value="" validationRule="${field.validationRule}"/>
        </div>

        <div class="col-md-3">
            (if&nbsp;noted)
        </div>
    </div>
    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}"/>
</div>