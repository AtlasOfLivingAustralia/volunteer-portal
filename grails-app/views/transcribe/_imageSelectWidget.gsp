<g:set var="picklistInfo" value="${g.imageInfos(field: field)}" />
<div class="imageSelectWidget ${cssClass}" targetField="${widgetName}">
    <div class="row-fluid control-group">
        <ul class="thumbnails">
            <g:each in="${picklistInfo.items}" var="piItem">
            <g:set var="aclass" value="${piItem.value == value ? 'selected' : ''}" />
            <li class="span2">
                <a href="javascript:void(0)" class="thumbnail ${aclass}" data-image-select-value="${piItem.value}">
                    <img src="${picklistInfo.infos[piItem.key].squareThumbUrl}" alt="${piItem.value}">
                    <span>${piItem.value}</span>
                </a>
            </li>
            </g:each>
        </ul>
        %{--<div class="span12">--}%
            %{--<div class="span4">--}%
                %{--<g:select tabindex="${tabindex}" class="span12 latLongFormatSelector" optionKey="value" optionValue="label" name="${field.fieldType}.format" value="" from="${[[label:"D°M'S\"",value:"DMS"], [label:"Decimal", value:"DD"]]}" />--}%
            %{--</div>--}%
            %{--<div class="latLongWidget_DMS span8">--}%
                %{--<div class="span3">--}%
                    %{--<g:textField tabindex="${tabindex}" name="${field.fieldType}.degrees" placeholder="D" class="span12 degrees" value="" validationRule="${field.validationRule}" />--}%
                %{--</div>--}%
                %{--<div class="span3">--}%
                    %{--<g:textField tabindex="${tabindex}" name="${field.fieldType}.minutes" placeholder="M" class="span12 minutes" value="" validationRule="${field.validationRule}" />--}%
                %{--</div>--}%
                %{--<div class="span2">--}%
                    %{--<g:textField tabindex="${tabindex}" name="${field.fieldType}.seconds" placeholder="S" class="span12 seconds" value="" validationRule="${field.validationRule}"/>--}%
                %{--</div>--}%
                %{--<div class="span4">--}%
                    %{--<g:if test="${field.fieldType?.toString()?.toLowerCase().contains("lat")}">--}%
                        %{--<g:set var="directionFrom" value="${["", "N", "S"]}" />--}%
                    %{--</g:if>--}%
                    %{--<g:else>--}%
                        %{--<g:set var="directionFrom" value="${["", "E", "W"]}" />--}%
                    %{--</g:else>--}%
                    %{--<g:select tabindex="${tabindex}" class="span12 direction" name="${field.fieldType}.direction" value="" from="${directionFrom}" />--}%
                %{--</div>--}%
            %{--</div>--}%
            %{--<div class="latLongWidget_DD span8" style="display: none">--}%
                %{--<g:textField tabindex="${tabindex}" name="${field.fieldType}.decimalDegrees" class="span12 decimalDegrees" placeholder="Decimal" value="" validationRule="${field.validationRule}" />--}%
            %{--</div>--}%
        %{--</div>--}%
    </div>
    <g:hiddenField id="${widgetName}" name="${widgetName}" value="${value}" class="${field.fieldType}" />
</div>

%{--<div class="row-fluid">--}%
%{--<div class="span12">--}%
%{--<small class="muted">${value}</small>--}%
%{--</div>--}%
%{--</div>--}%
