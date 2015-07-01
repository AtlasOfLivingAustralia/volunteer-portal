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
        <g:each in="${imageInfos.items}" var="piItem">
            <div class="griditem bvpBadge">
                <div class="thumbnail ct-thumbnail" data-image-select-key="${piItem.key}" data-image-select-value="${piItem.value}">
                    <span class="ct-badge ct-badge-sure badge"><i class="icon-white icon-ok-sign"></i></span>
                    <span class="ct-badge ct-badge-uncertain badge"><i class="icon-white icon-question-sign"></i></span>
                    <img class="ct-thumbnail-image" src="${imageInfos.infos[piItem.key]?.squareThumbUrl}" alt="${piItem.value}">
                    <div class="ct-caption-table" style="display:table;height:40px;line-height:0;">
                        <div class="ct-caption-cell" style="display:table-cell;vertical-align:middle;">
                            <div style="text-align:center;" class="ct-caption dotdotdot" title="${piItem.value}">${piItem.value}</div>
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