<%@ page import="au.org.ala.volunteer.Field; au.org.ala.volunteer.TemplateField" %>
<div class="row">

    <div class="col-md-12">

            <g:set var="multimedia" value="${taskInstance.multimedia.first()}"/>
            <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('audio/')}">
                <div class="card">
                    <div class="card-body">
                        <g:audioWaveViewer multimedia="${multimedia}" waveColour="${taskInstance.project.institution?.themeColour}"/>
                    </div>
                </div>
            </g:if>
            <g:else>
                <div class="card">
                    <div class="card-body">
                        <g:imageViewer multimedia="${multimedia}" preserveWidthWhenPinned="true" hideShowInOtherWindow="${true}"/>
                    </div>
                </div>
            </g:else>

    </div>

</div>
<asset:javascript src="image-viewer" asset-defer=""/>
%{--<asset:javascript src="transcribe/audiotranscribe" asset-defer=""/>--}%
<script src="https://unpkg.com/wavesurfer.js@6.1.0/dist/wavesurfer.js"></script>
<asset:script>
    $(document).ready(function () {
        setupPanZoom();
    });
</asset:script>
