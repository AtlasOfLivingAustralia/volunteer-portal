<style type="text/css">

#toolContentHeader, #currentTaskHeader {
    background: #3D464C;
    padding-left: 10px;
    padding-right: 10px;
    color: white;
}

#toolContentHeader {
    padding-top: 10px;
}

#currentTaskHeader h3 {
    color: white;
    margin: 0;
}

#toolContentHeader h3, #currentTaskHeader h3 {
    color: white;
    padding-bottom: 6px;
}

#taskImage {
    height: 200px;
    width: 670px;
}

#taskImage img {
    max-width: inherit !important;
}

</style>

<div id="toolContent" class="toolContent">

    <g:if test="${taskInstance}">
        <div class="row-fluid">
            <div class="span12" id="currentTaskHeader">
                <h3>Image from current task</h3>
            </div>
        </div>

        <div id="imagePane">
            <g:set var="mm" value="${taskInstance.multimedia?.first()}"/>
            <div id="taskImageViewer" style="height: 200px; overflow: hidden">
                <g:imageViewer multimedia="${mm}" elementId="taskImage" hideControls="${true}"/>
            </div>
        </div>

    </g:if>

    <div id="toolBody">
        <g:layoutBody/>
    </div>

    <script type="text/javascript">

        var target = $("#taskImage img");

        target.panZoom({
            pan_step: 10,
            zoom_step: 10,
            min_width: 100,
            min_height: 100,
            mousewheel: true,
            mousewheel_delta: 6
        });

    </script>

</div>