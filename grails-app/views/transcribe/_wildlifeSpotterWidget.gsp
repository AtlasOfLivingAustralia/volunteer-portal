<div class="itemgrid">%{--
    display: inline-block, so no spaces between the divs
    --}%<g:each in="${imageInfos}" var="piItem" status="st"><div class="griditem bvpBadge"
                                                                           data-item-index="${st}">
        <g:if test="${piItem?.audio?.size() > 0}">
            <div class="thumbnail ct-thumbnail <g:if test="${!isAnswers}">ws-selector</g:if>" aria-selected="false" data-image-select-key="${st}" title="${g.message(code: 'audiotranscribe.widget.badge.title', args: [piItem.vernacularName])}">
        </g:if>
        <g:else>
            <div class="thumbnail ct-thumbnail <g:if test="${!isAnswers}">ws-selector</g:if>" aria-selected="false" data-image-select-key="${st}" title="${g.message(code: 'wildlifespotter.widget.badge.title', args: [piItem.vernacularName])}">
        </g:else>
                <g:if test="${!isAnswers}">
                    %{-- If Audio --}%
                    <g:if test="${piItem?.audio?.size() > 0}">
                        <g:set var="audioSample" value="${piItem.audio[0]}" />
                        <cl:audioSample prefix="audiotranscribe" name="${audioSample.hash}" format="${audioSample.ext}"/>
                    </g:if>
                    <span class="ws-selected"><i class="fa fa-check"></i></span>
                    <span class="ws-info" data-container="body"><i class="fa fa-info-circle"></i></span>
                </g:if>
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