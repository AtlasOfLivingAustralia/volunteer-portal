<div class="itemgrid">
    <g:if test="${imageInfos.error}">
        <div class="alert alert-block alert-danger">
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
        </g:if>%{--
        display: inline-block, so no spaces between the divs
        --}%<g:each in="${imageInfos.items}" var="piItem" status="st"><div class="griditem bvpBadge"
                                                                           data-item-index="${st}">
        <div class="thumbnail ct-thumbnail" data-image-select-key="${piItem.value.imageIds}"
             data-image-select-value="${piItem.key}"
             data-tags="${piItem.value.tags} data-day-images=" ${piItem.value.dayImageIds}
             data-night-images="${piItem.value.nightImageIds}" data-popularity="${piItem.value.popularity}"
             data-last-used="${piItem.value.lastUsed}">
            <span class="ct-badge ct-badge-sure" data-container="body"
                  title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: "There is definitely a {0} in the image", args: [piItem.key])}"><i
                    class="fa fa-check-circle"></i></span>
            <span class="ct-badge ct-badge-uncertain" data-container="body"
                  title="${g.message(code: 'cameratrap.widget.uncertain.badge.title', default: "There could possibly be a {0} in the image", args: [piItem.key])}"><i
                    class="fa fa-check-circle"></i></span>
            <g:if test="${piItem.value.similarSpecies}">
                <span class="ct-info" data-container="body"
                      title="${g.message(code: 'cameratrap.widget.similar.badge.title', default: "The {0} looks very similar to the {1}.  Please consider these other options before submitting your choices.", args: [piItem.key, piItem.value.similarSpecies.join(', ')])}"><i
                        class="fa fa-info-circle"></i></span>
            </g:if>
            <div class="bvpBadgeMain cycler">
                <g:each in="${piItem.value.imageIds}" var="key" status="j">
                    <img class="ct-thumbnail-image${j == 0 ? ' active' : ' '}"
                         src="${imageInfos.infos[key]?.squareThumbUrl}" alt="${piItem.value.value}">
                </g:each>
                <div class="wash"></div>
            </div>

            <div class="ct-caption-table">
                <div class="ct-caption-cell">
                    <div class="ct-caption dotdotdot" title="${piItem.key}">${piItem.key}</div>
                </div>
            </div>
        </div>
    </div></g:each>
    %{--<g:each in="${imageInfos.infos}">--}%
    %{--<link rel="prefetch" href="${it.value.imageUrl}" data-key="${it.key}"/>--}%
    %{--</g:each>--}%
    </g:else>
</div>