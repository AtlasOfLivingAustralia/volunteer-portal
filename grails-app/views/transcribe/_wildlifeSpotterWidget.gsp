<div class="itemgrid">%{--
    display: inline-block, so no spaces between the divs
    --}%<g:each in="${imageInfos}" var="piItem" status="st"><div class="griditem bvpBadge"
                                                                           data-item-index="${st}">
        <div class="thumbnail ct-thumbnail ws-selector" data-image-select-key="${st}">
            %{--<span class="ct-badge ct-badge-sure" data-container="body"--}%
                  %{--title="${g.message(code: 'cameratrap.widget.sure.badge.title', default: "There is definitely a {0} in the image", args: [piItem.key])}"><i--}%
                    %{--class="fa fa-check-circle"></i></span>--}%
            %{--<span class="ct-badge ct-badge-uncertain" data-container="body"--}%
                  %{--title="${g.message(code: 'cameratrap.widget.uncertain.badge.title', default: "There could possibly be a {0} in the image", args: [piItem.key])}"><i--}%
                    %{--class="fa fa-check-circle"></i></span>--}%
            %{--<g:if test="${piItem.value.similarSpecies}">--}%
                <span class="ws-selected"><i class="fa fa-check-circle-o"></i></span>
                <span class="ws-info" data-container="body"><i class="fa fa-info-circle"></i></span>
            %{--</g:if>--}%
            <div class="bvpBadgeMain cycler">
                <g:each in="${piItem.images}" var="key" status="j">
                    <cl:sizedImage class="ct-thumbnail-image ws-thumbnail-image${j == 0 ? ' active' : ' '}"
                         prefix="wildlifespotter" name="${key.hash}" width="150" height="150" format="jpg"
                         alt="${piItem.vernacularName}" />
                </g:each>
            </div>

            <div class="ct-caption-table">
                <div class="ct-caption-cell">
                    <div class="ct-caption dotdotdot" title="${piItem.vernacularName}">${piItem.vernacularName}</div>
                </div>
            </div>
        </div>
    </div></g:each>
</div>