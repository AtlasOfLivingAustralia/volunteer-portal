<div class="latLongWidget ${cssClass}" targetField="${field.fieldType}">
    <div class="row form-group">
        <div class="col-md-3">
            <g:select tabindex="${tabindex}" class="form-control latLongFormatSelector" optionKey="value"
                      optionValue="label" name="${field.fieldType}.format" value=""
                      from="${[[label: "D°M'S\"", value: "DMS"], [label: "Decimal", value: "DD"]]}"/>
        </div>

        <div class="latLongWidget_DMS col-md-9">
            <div class="row">
                <div class="col-md-3">
                    <g:textField tabindex="${tabindex}" name="${field.fieldType}.degrees" placeholder="D"
                                 class="form-control degrees" value="" validationRule="${field.validationRule}"/>
                </div>

                <div class="col-md-3">
                    <g:textField tabindex="${tabindex}" name="${field.fieldType}.minutes" placeholder="M"
                                 class="form-control minutes" value="" validationRule="${field.validationRule}"/>
                </div>

                <div class="col-md-3">
                    <g:textField tabindex="${tabindex}" name="${field.fieldType}.seconds" placeholder="S"
                                 class="form-control seconds" value="" validationRule="${field.validationRule}"/>
                </div>

                <div class="col-md-3">
                    <g:if test="${field.fieldType?.toString()?.toLowerCase().contains("lat")}">
                        <g:set var="directionFrom" value="${["", "N", "S"]}"/>
                    </g:if>
                    <g:else>
                        <g:set var="directionFrom" value="${["", "E", "W"]}"/>
                    </g:else>
                    <g:select tabindex="${tabindex}" class="form-control direction" name="${field.fieldType}.direction"
                              value="" from="${directionFrom}"/>
                </div>
            </div>
        </div>

        <div class="latLongWidget_DD col-md-9" style="display: none">
            <g:textField tabindex="${tabindex}" name="${field.fieldType}.decimalDegrees"
                         class="form-control decimalDegrees" placeholder="Decimal" value=""
                         validationRule="${field.validationRule}"/>
        </div>
    </div>
    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}"
                   class="${field.fieldType}"/>
</div>

