<g:set var="picklistInfo" value="${g.imageInfos(field: field, project: taskInstance?.project)}" />
<g:if test="${picklistInfo.error}">
    <div class="alert alert-error alert-block">
    Could not load images for field ${field.fieldType} (${field.fieldTypeClassifier}) because ${picklistInfo.error}
    </div>
</g:if>
<div class="imageSelectWidget ${cssClass} ${field.type.name()}" targetField="${widgetName}">
    <div class="itemgrid">
        <g:each in="${picklistInfo.items}" var="piItem">
        <g:set var="aclass" value="${piItem.value == value ? 'selected' : ''}" />
        <div class="griditem bvpBadge">
            <a href="javascript:void(0)" class="thumbnail ${aclass}" data-image-select-value="${piItem.value}">
                <img src="${picklistInfo.infos[piItem.key].squareThumbUrl}" alt="${piItem.value}">
                <span>${piItem.value}</span>
            </a>
        </div>
        </g:each>
    </div>
    <g:hiddenField id="${widgetName}" name="${widgetName}" value="${value}" class="${field.fieldType}" />
</div>