<div class="unitRangeWidget control-group ${cssClass}" targetField="${field.fieldType}">

    <div class="row-fluid" style="vertical-align: bottom">

        <div class="span2">
            (from)
        </div>
        <div class="span2">
            <g:textField name="${field.fieldType}.minValue" class="span12 rangeMinValue" value="" />
        </div>
        <div class="span1">
            (to)
        </div>
        <div class="span2">
            <g:textField name="${field.fieldType}.maxValue" class="span12 rangeMaxValue" value="" />
        </div>
        <div class="span4">
            <g:select class="span12 rangeUnits" name="${field.fieldType}.units" value="" from="${["", "Metres", "Feet"]}" />
        </div>

    </div>
    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}" validationRule="${field.validationRule}" />
</div>