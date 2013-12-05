<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <link rel="icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico"/>
        <link rel="shortcut icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico"/>

        <link rel="stylesheet" type="text/css" href="${resource(dir: 'css', file: 'bootstrap.css', plugin:'ala-web-theme')}">

        <r:require module="jquery" />
        <r:require module="bootstrap-js" />
        <r:require module="panZoom" />
        <r:require module="imageViewerCss" />

        <style type="text/css">

            button:disabled {
                opacity: 0.4;
                filter: alpha(opacity=40); // msie
            }

            button[disabled]:hover {
                opacity: 0.4;
                filter: alpha(opacity=40); // msie
            }

            .imageviewer-controls {
                top: 10px !important;
            }

        </style>

        <r:layoutResources/>

    </head>

    <body>
        <div class="container-fluid">
            <div id="imageViewerHeader">
                <div class="row-fluid">
                    <div class="span12">
                        <h4>${taskInstance?.project?.featuredLabel} - ${taskInstance?.externalIdentifier}</h4>
                        <cl:messages/>
                    </div>
                </div>

                <div class="row-fluid" style="margin-bottom: 10px">

                    <div class="span9" id="journalPageButtons">
                        <button class="btn btn-small" id="showPreviousJournalPage" title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}>
                            <img src="${resource(dir: 'images', file: 'left_arrow.png')}"> show previous
                        </button>
                        <button class="btn btn-small" id="showNextJournalPage" title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>
                            show next <img src="${resource(dir: 'images', file: 'right_arrow.png')}">
                        </button>
                        <button class="btn btn-small" id="rotateImage" title="Rotate the page 180 degrees">
                            Rotate&nbsp;<img src="${resource(dir: 'images', file: 'rotate.png')}">
                        </button>
                        <button class="btn btn-small" id="closeWindow" title="Close this window">
                            Close
                        </button>
                    </div>

                    <div class="span3">
                        <g:if test="${sequenceNumber >= 0}">
                            <span class="pull-right label label-info">Sequence number: ${sequenceNumber}</span>
                        </g:if>
                    </div>

                </div>
            </div>

            <div class="row-fluid">
                <div class="span12">
                    <div id="imageWell" class="well well-small">
                        <g:each in="${taskInstance.multimedia}" var="multimedia" status="i">
                            <g:if test="${!multimedia.mimeType || multimedia.mimeType.startsWith('image/')}">
                                <g:imageViewer multimedia="${multimedia}" hidePinImage="${true}" hideShowInOtherWindow="${true}" />
                            </g:if>
                        </g:each>
                    </div>
                </div>
            </div>
        </div>

        <r:script type="text/javascript">

            $(document).ready(function () {

                $("#showPreviousJournalPage").click(function (e) {
                    e.preventDefault();
                    <g:if test="${prevTask}">
                    var uri = "${createLink(controller: 'task', action:'showImage', id: prevTask.id)}"
                    window.open(uri, "journalWindow");
                    </g:if>
                });

                $("#showNextJournalPage").click(function (e) {
                    e.preventDefault();
                    <g:if test="${nextTask}">
                    var uri = "${createLink(controller: 'task', action:'showImage', id: nextTask.id)}"
                    window.open(uri, "journalWindow");
                    </g:if>
                });

                $("#closeWindow").click(function (e) {
                    window.close();
                });

                $("#rotateImage").click(function (e) {
                    e.preventDefault();
                    $("#image-container img").toggleClass("rotate-image");
                });

                $(window).resize(function(e) {
                    adjustHeight();
                });

                function adjustHeight() {
                    var headerHeight = $("#imageViewerHeader").height();
                    var newHeight = $(window).height() - headerHeight - 50;
                    $("#image-container").css("height", newHeight +"px");
                    var target = $("#image-container img").panZoom('notifyResize');
                }

                setupPanZoom();
                adjustHeight();

            });

            function setupPanZoom() {
                var target = $("#image-container img");
                if (target.length > 0) {
                    target.panZoom({
                        pan_step:10,
                        zoom_step:10,
                        min_width:200,
                        min_height:200,
                        mousewheel:true,
                        mousewheel_delta:5,
                        'zoomIn':$('#zoomin'),
                        'zoomOut':$('#zoomout'),
                        'panUp':$('#pandown'),
                        'panDown':$('#panup'),
                        'panLeft':$('#panright'),
                        'panRight':$('#panleft')
                    });

                    target.panZoom('fit');
                }
            }


        </r:script>

        <!-- JS resources-->
        <r:layoutResources/>

    </body>
</html>
