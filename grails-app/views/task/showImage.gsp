<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/style.css" type="text/css" media="screen"/>
        <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/css/bvp.css" type="text/css" media="screen"/>
        <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/css/wp-styles.css" type="text/css" media="screen"/>
        <link rel="stylesheet" href="http://www.ala.org.au/wp-content/themes/ala2011/css/buttons.css" type="text/css" media="screen"/>
        <link rel="icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico"/>
        <link rel="shortcut icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico"/>
        <link rel="stylesheet" type="text/css" media="screen" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"/>
        <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/jquery.autocomplete.css"/>
        <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/search.css"/>
        <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/skin.css"/>
        <link rel="stylesheet" type="text/css" media="screen" href="http://www.ala.org.au/wp-content/themes/ala2011/css/sf-blue.css"/>


        <link rel="stylesheet" href="${resource(dir: 'css', file: 'public.css')}"/>

        <script type="text/javascript" src="${resource(dir: 'js/jquery-ui-1.9.1.custom/js', file: 'jquery-1.8.2.js')}"></script>
        <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.mousewheel.min.js')}"></script>
        <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
        <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>
        <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.scrollview.js')}"></script>
        <g:javascript library="jquery.tools.min"/>

        <link rel="stylesheet" type="text/css" href="${resource(dir: 'css', file: 'rangeSlider.css')}"/>

        <style type="text/css">

        div#wrapper > div#content {
            background-color: transparent !important;
        }

        .volunteerportal #page-header {
            background: #f0f0e8 url(${resource(dir:'images/vp',file:'bg_volunteerportal.jpg')}) center top no-repeat;
            padding-bottom: 12px;
            border: 1px solid #d1d1d1;
        }

        button:disabled {
            opacity: 0.4;
            filter: alpha(opacity=40); // msie
        }

        button[disabled]:hover {
            opacity: 0.4;
            filter: alpha(opacity=40); // msie
        }

        #imageContainer {
            overflow: auto;
        }

        </style>

        <r:script type="text/javascript">

            $(document).ready(function () {

                $(":range").rangeinput({
                    onSlide: zoomJournalImage
                }).change(zoomJournalImage);

                // display previous journal page in new window
                $("#showPreviousJournalPage").click(function (e) {
                    e.preventDefault();
                    <g:if test="${prevTask}">
                    var uri = "${createLink(controller: 'task', action:'showImage', id: prevTask.id)}"
                    window.open(uri, "journalWindow");
                    </g:if>
                });

                // display next journal page in new window
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

                $("#imageContainer").scrollview({
                    grab: "${resource(dir: 'images', file: 'openhand.cur')}",
                    grabbing: "${resource(dir: 'images', file: 'closedhand.cur')}"
                });

                $("#rotateImage").click(function (e) {
                    e.preventDefault();
                    $("#image_0").toggleClass("rotate-image");
                });

            });

            function zoomJournalImage(event, value) {
                console.info("value changed to", value);
                $("#journalPageImg").css("width", value + "%");
                $("#journalPageImg").css("height", value + "%");
            }


        </r:script>

    </head>

    <body class="sublevel sub-site volunteerportal" style="overflow-x: hidden; overflow-y: scroll;">
        <div>
            <div class="inner">
                <cl:messages/>
                <h2>Task image: ${taskInstance?.project?.featuredLabel} - ${taskInstance?.externalIdentifier}</h2>
                <g:if test="${sequenceNumber >= 0}">
                    <span>Image sequence number: ${sequenceNumber}</span>
                </g:if>
            </div>

            <div>
                <div style="float:left;margin-top:5px;">Zoom image:&nbsp;</div>
                <g:set var="defaultWidthPercent" value="100"/>
                <input type="range" name="width" min="50" max="150" value="100"/>
                <span id="journalPageButtons">
                    <button id="showPreviousJournalPage" title="displays page in new window" ${prevTask ? '' : 'disabled="true"'}><img src="${resource(dir: 'images', file: 'left_arrow.png')}"> show previous
                    </button>
                    <button id="showNextJournalPage" title="displays page in new window" ${nextTask ? '' : 'disabled="true"'}>show next <img src="${resource(dir: 'images', file: 'right_arrow.png')}">
                    </button>
                    <button id="rotateImage" title="Rotate the page 180 degrees">Rotate&nbsp;<img style="vertical-align: middle; margin: 0 !important;" src="${resource(dir: 'images', file: 'rotate.png')}">
                    </button>
                    <button id="closeWindow" title="Close this window">Close</button>
                </span>


                <div id="imageContainer">
                    <g:set var="imageIndex" value="0"/>
                    <g:each in="${taskInstance.multimedia}" var="m" status="i">
                        <g:if test="${!m.mimeType || m.mimeType.startsWith('image/')}">
                            <g:set var="imageUrl" value="${grailsApplication.config.server.url}${m.filePath}"/>

                            <div class="pageViewer" id="journalPageImg">
                                <img id="image_${imageIndex++}" src="${imageUrl}" style="width:100%;"/>
                            </div>

                        </g:if>
                    </g:each>
                </div>

            </div>
        </div>
    </body>
</html>
