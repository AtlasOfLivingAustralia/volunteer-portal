<%
    def sheetNumberData = [sheet: value, of: ''];
    if (value) {
        if (value.contains('/')) {
            sheetNumberData.sheet = value.substring(0, value.indexOf('/'))
            sheetNumberData.of = value.substring(value.indexOf('/') + 1)
        }
    }
%>
<div class="sheetNumberWidget" targetField="${field.fieldType}" >

    <div class="control-group" >
        <div class="span3">
            <g:textField name="${field.fieldType}.sheetNumber" class="span12 sheetNumber" value="${sheetNumberData.sheet}" validationRule="${field.validationRule}" />
        </div>
        <div class="span1">
            of
        </div>
        <div class="span3">
            <g:textField name="${field.fieldType}.sheetNumberOf" class="span12 sheetNumberOf" value="${sheetNumberData.of}" validationRule="${field.validationRule}" />
        </div>
        <div class="span3">
            (if noted)
        </div>
    </div>
    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}" />
</div>