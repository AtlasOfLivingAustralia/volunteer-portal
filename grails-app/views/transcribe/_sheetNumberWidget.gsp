<div class="sheetNumberWidget" targetField="${field.fieldType}" >

    <div class="control-group" >
        <div class="span3">
            <g:textField name="${field.fieldType}.sheetNumber" class="span12 sheetNumber" value="" validationRule="${field.validationRule}" />
        </div>
        <div class="span1">
            of
        </div>
        <div class="span3">
            <g:textField name="${field.fieldType}.sheetNumberOf" class="span12 sheetNumberOf" value="" validationRule="${field.validationRule}" />
        </div>
        <div class="span3">
            (if&nbsp;noted)
        </div>
    </div>
    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}" />
</div>