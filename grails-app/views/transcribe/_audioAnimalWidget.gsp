<div class="audio-item-list">
<g:each in="${imageInfos}" var="piItem" status="st">
    <div class="audio-row" data-item-index="${st}" style="display: flex; align-content: flex-end; padding: 0.1em;">
        <div class="audio-badge <g:if test="${!isAnswers}">ws-selector</g:if>" aria-selected="false"
             data-image-select-key="${st}"
             style="width: 100px;"
             title="${g.message(code: 'audiotranscribe.widget.badge.title', args: [piItem.vernacularName])}">

                <span class="ws-selected"><i class="fa fa-check"></i></span>

                <g:each in="${piItem.images}" var="key" status="j">
                    <cl:sizedImage class="ct-thumbnail-image ws-thumbnail-image${j == 0 ? ' active' : ' '}"
                                   prefix="wildlifespotter" name="${key.hash}" width="100" height="100" format="jpg"
                                   alt="${piItem.vernacularName}" />
                </g:each>

        </div>
        <div style="flex-grow: 1; text-align: justify; padding-left: 0.5em;">
            <span class="audio-badge-title">${piItem.vernacularName} (${piItem.scientificName})</span>
            <span class="audio-info" style="display: inline-block; "><i class="fa fa-info-circle" title="More details"></i></span>

            <div class="row" style="padding-bottom: 0.5em; padding-top: 1em; margin-right: 0px; margin-left: 0px;">
                <g:set var="audioSample" value="${piItem.audio?.first()}" />
                <div class="col-sm-1"><a class="btn btn-next audio-sample-list-play" data-action-play="${audioSample.hash}"><i class="fa fa-2x fa-play-circle-o"></i></a></div>
                <div class="col-sm-4 audio-sample-list" style="border-radius: 4px; border: 1px solid #ddd;"
                     data-play-link="${audioSample.hash}"
                     data-audio-file='<cl:audioUrl prefix="audiotranscribe" name="${audioSample.hash}" format="${audioSample.ext}" template="true"/>'>
                </div>
            </div>
        </div>
    </div>
</g:each>
</div>