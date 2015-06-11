<div class="itemgrid">
    <g:if test="${imageInfos.error}">
        <div class="alert alert-block alert-error">
            Images for picklist id: ${picklistId} could not be loaded because ${imageInfos.error}
        </div>
    </g:if>
    <g:else>
        <g:if test="${picklistInfo.warnings}">
            <div class="alert alert-block">
                Warnings:
                <ul>
                    <g:each in="${picklistInfo.warnings}" var="w">
                        <li>${w}</li>
                    </g:each>
                </ul>
            </div>
        </g:if>
        <g:each in="${imageInfos.items}" var="piItem">
            <div class="griditem bvpBadge">
                <div class="thumbnail ct-thumbnail" data-image-select-key="${piItem.key}" data-image-select-value="${piItem.value}">
                    <span class="ct-badge ct-badge-sure badge"><i class="icon-white icon-ok-sign"></i></span>
                    <span class="ct-badge ct-badge-uncertain badge"><i class="icon-white icon-question-sign"></i></span>
                    <img src="${imageInfos.infos[piItem.key].squareThumbUrl}" alt="${piItem.value}">
                    <div>
                        <span>${piItem.value}</span>
                    </div>
                </div>
            </div>
        </g:each>
    </g:else>
</div>