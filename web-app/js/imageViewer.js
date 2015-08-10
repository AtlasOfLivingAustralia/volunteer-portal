function setupPanZoom(target) {

    if (!target) {
        target = $("#image-container img");
    }

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

function setImageViewerHeight(height) {
    $("#image-container").css("height", "" + height + "px");
    //$(".imageviewer-controls").css("top", "" + (height - 70) + "px");
    //$(".pin-image-control").css("top", "" + (height - 30) + "px");
    //$(".show-image-control").css("top", "" + (height - 60) + "px");
}
