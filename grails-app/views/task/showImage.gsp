<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><cl:pageTitle title="${message(code: 'task.showImage.image_viewer')}"/></title>
    <asset:link rel="shortcut icon" href="favicon.ico" type="image/x-icon"/>

    <asset:stylesheet src="digivol" />
    <asset:stylesheet src="image-viewer"/>
    <style type="text/css">

    button:disabled {
        opacity: 0.4;
        filter: alpha(opacity=40);
    / / msie
    }

    button[disabled]:hover {
        opacity: 0.4;
        filter: alpha(opacity=40);
    / / msie
    }

    .imageviewer-controls {
        top: 10px !important;
    }

    </style>

</head>

<body>
<div class="container-fluid">
    <div id="imageViewerHeader">
        <div class="row">
            <div class="col-xs-12">
                <h4>${taskInstance?.project?.i18nName} - ${taskInstance?.externalIdentifier}</h4>
                <cl:messages/>
            </div>
        </div>

        <div class="row" style="margin-bottom: 10px">

            <div class="col-sm-9" id="journalPageButtons">
                <button class="btn btn-default btn-small" id="showPreviousJournalPage"
                        title="${message(code: 'task.showImage.previous.description')}" ${prevTask ? '' : 'disabled="true"'}>
                    <asset:image src="left_arrow.png"/> <g:message code="task.showImage.previous"/>
                </button>
                <button class="btn btn-default btn-small" id="showNextJournalPage"
                        title="${message(code: 'task.showImage.next.description')}" ${nextTask ? '' : 'disabled="true"'}>
                    <g:message code="task.showImage.next"/> <asset:image src="right_arrow.png"/>
                </button>
                <button class="btn btn-default btn-small" id="rotateImage" title="${message(code: 'task.showImage.rotate.description')}">
                    <g:message code="task.showImage.rotate"/>&nbsp;<asset:image src="rotate.png"/>
                </button>
                <button class="btn btn-default btn-small" id="closeWindow" title="${message(code: 'task.showImage.close.description')}">
                    <g:message code="task.showImage.close"/>
                </button>
            </div>

            <div class="col-sm-3">
                <g:if test="${sequenceNumber >= 0}">
                    <span class="pull-right label label-info"><g:message code="task.showImage.sequence_number"/> ${sequenceNumber}</span>
                </g:if>
            </div>

        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div id="imageWell" class="panel panel-default">
                <div class="panel-body">
                    <g:each in="${taskInstance?.multimedia}" var="multimedia" status="i">
                        <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                            <g:imageViewer multimedia="${multimedia}" hidePinImage="${true}"
                                           hideShowInOtherWindow="${true}"/>
                        </g:if>
                    </g:each>
                </div>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="digivol" />
<asset:javascript src="image-viewer" asset-defer=""/>

<asset:script type="text/javascript">

            $(document).ready(function () {

                $("#showPreviousJournalPage").click(function (e) {
                    e.preventDefault();
                    <g:if test="${prevTask}">
    var uri = "${createLink(controller: 'task', action: 'showImage', id: prevTask.id)}"
                    window.open(uri, "journalWindow");
</g:if>
    });

    $("#showNextJournalPage").click(function (e) {
        e.preventDefault();
    <g:if test="${nextTask}">
        var uri = "${createLink(controller: 'task', action: 'showImage', id: nextTask.id)}"
                    window.open(uri, "journalWindow");
    </g:if>
    });

    $("#closeWindow").click(function (e) {
        window.close();
    });

    $("#rotateImage").click(function (e) {
        e.preventDefault();
        rotateImage();
//                    $("#image-container img").toggleClass("rotate-image");
    });

    $(window).resize(function(e) {
        adjustHeight();
    });

    setupPanZoom();
    adjustHeight();

});

function adjustHeight() {
    var headerHeight = $("#imageViewerHeader").height();
    var newHeight = $(window).height() - headerHeight - 50;
    $("#image-container").css("height", newHeight +"px");
    $("#image-container img").panZoom('notifyResize');
}

var imageRotation = 0;

function rotateImage() {
    var image = $("#image-container img")
    if (image) {
        imageRotation += 90;
        if (imageRotation >= 360) {
            imageRotation = 0;
        }

        var height = $("#image-container").height();

        $.ajax("${createLink(controller: 'transcribe', action: 'imageViewerFragment', params: [multimediaId: taskInstance?.multimedia?.first()?.id])}&height=" + height +"&rotate=" + imageRotation + "&hideShowInOtherWindow=true&hidePinImage=true").done(function(html) {
                        $("#image-parent-container").replaceWith(html);
                        setupPanZoom();
                    });

                }
            }

</asset:script>

<!-- JS resources-->
<asset:deferredScripts/>

</body>
</html>
