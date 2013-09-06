modules = {

//    'style' {
//        resource url:'/less/bvp-bootstrap.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style', deposition: 'head'
//    }

    'qtip' {
        dependsOn "jquery"
        resource url:'/js/jquery.qtip-1.0.0-rc3.min.js'
    }

    'mouseWheel' {
        dependsOn "jquery"
        resource url:'/js/jquery.mousewheel.min.js'
    }

    'panZoom' {
        dependsOn "jquery,jquery-ui,mouseWheel"
        resource url:'/js/jquery-panZoom.js'
    }

    overrides {
        'jquery-theme' {
            resource id:'theme', url:'/css/smoothness/ui.all.css'
        }
    }

    'bootstrap-js' {
        resource url:[dir:'js', file:'bootstrap.js', plugin: 'ala-web-theme', disposition: 'head']
    }

    'jqZoom' {
        dependsOn "jquery"
        resource url:'/js/jquery.jqzoom-core.js'
        resource url:'/css/jquery.jqzoom.css'
    }

    'gmaps' {
        dependsOn 'jquery'
        resource url:'/js/gmaps.js'
    }

    'imageViewerCss' {
        resource url:'/css/imageViewer.css'
    }

    'transcribeWidgets' {
        resource url: '/js/transcribeWidgets.js'
    }

}