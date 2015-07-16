<div class="itemgrid">
    <g:if test="${imageInfos.error}">
        <div class="alert alert-block alert-error">
            Images for picklist id: ${picklistId} could not be loaded because ${imageInfos.error}
        </div>
    </g:if>
    <g:else>
        <g:if test="${imageInfos.warnings}">
            <div class="alert alert-block">
                Warnings:
                <ul>
                    <g:each in="${imageInfos.warnings}" var="w">
                        <li>${w}</li>
                    </g:each>
                </ul>
            </div>
        </g:if>
        <g:each in="${imageInfos.items}" var="piItem" status="st">
            <div class="griditem bvpBadge" data-item-index="${st}">
                <div class="thumbnail ct-thumbnail" data-image-select-key="${piItem.key}" data-image-select-value="${piItem.value}">
                    <span class="ct-badge ct-badge-sure badge" data-container="body" title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: "There is definitely a ${piItem.value} in the image")}"><i class="fa fa-check-circle"></i></span>
                    <span class="ct-badge ct-badge-uncertain badge" data-container="body" title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: "There could possibly be a ${piItem.value} in the image")}"><i class="fa fa-check-circle"></i></span>
                    <div class="bvpBadgeMain cycler">
                        <g:each in="${piItem.key}" var="key" status="j">
                            <img class="ct-thumbnail-image${j == 0 ? ' active': ' '}" src="${imageInfos.infos[key]?.squareThumbUrl}" alt="${piItem.value}">
                        </g:each>
                    </div>
                    <div class="ct-caption-table">
                        <div class="ct-caption-cell" >
                            <div class="ct-caption dotdotdot" title="${piItem.value}">${piItem.value}</div>
                        </div>
                    </div>
                    %{--<div>--}%
                        %{--<span class="ct-caption" title="${piItem.value}">${piItem.value}</span>--}%
                    %{--</div>--}%
                </div>
            </div>
        </g:each>
        <g:each in="${imageInfos.infos}">
            <link rel="prefetch" href="${it.value.imageUrl}" data-key="${it.key}"/>
        </g:each>
    </g:else>
</div>