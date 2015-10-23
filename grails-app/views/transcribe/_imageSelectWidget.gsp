<g:set var="picklistInfo" value="${g.imageInfos(field: field, project: taskInstance?.project)}"/>
<g:if test="${picklistInfo.error}">
    <div class="alert alert-danger alert-block">
        Could not load images for field ${field.fieldType} (${field.fieldTypeClassifier}) because ${picklistInfo.error}
    </div>
</g:if>
<g:else>
    <g:if test="${picklistInfo.warnings}">
        <div class="alert alert-block">
            <a href="#" class="close" data-dismiss="alert">&times;</a>
            Warnings:
            <ul>
                <g:each in="${picklistInfo.warnings}" var="w">
                    <li>${w}</li>
                </g:each>
            </ul>
        </div>
    </g:if>
    <g:set var="values" value="${(value ?: '').split(',')}"/>
    <div class="imageSelectWidget ${cssClass} ${field.type.name()}" targetField="${widgetName}">
        <div class="itemgrid">
            <g:each in="${picklistInfo.items}" var="piItem">
                <g:set var="aclass" value="${values.contains(piItem.value) ? 'selected' : ''}"/>
                <div class="griditem bvpBadge">
                    <a href="javascript:void(0)" class="thumbnail ${aclass}" data-image-select-value="${piItem.value}">
                        <img src="${picklistInfo.infos[piItem.key[0]]?.squareThumbUrl}" alt="${piItem.value}">

                        <div class="caption-table">
                            <div class="caption-cell">
                                <div class="is-caption dotdotdot" title="${piItem.value}">${piItem.value}</div>
                            </div>
                        </div>
                        %{--<span class="is-caption dotdotdot" title="${piItem.value}">${piItem.value}</span>--}%
                    </a>
                </div>
            </g:each>
        </div>
        <g:hiddenField id="${widgetName}" name="${widgetName}" value="${value}" class="${field.fieldType}"
                       validationRule="${field.validationRule}"/>
    </div>
</g:else>