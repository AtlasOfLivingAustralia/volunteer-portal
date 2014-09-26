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
            resource id:'theme', url:'/js/jquery-ui-1.10.4.custom/css/smoothness/jquery-ui-1.10.4.custom.min.css'
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

    'imageViewer' {
        dependsOn "panZoom"
        resource url:'/js/imageViewer.js'
        resource url:'/css/imageViewer.css'
    }

    'transcribeWidgets' {
        resource url: '/js/transcribeWidgets.js'
        resource url: '/js/transcribeValidation.js'
    }

    'timezone' {
        resource url: '/js/jstz-1.0.4.min.js'
    }

    'amplify' {
        dependsOn 'jquery'
        resource url: '/js/amplify.js'
    }

    'bvp-js' {
        dependsOn('jquery, qtip')
        resource url: '/js/bvp-common.js'
    }

    "bootstrap-switch" {
        dependsOn "jquery"
        resource url: 'js/bootstrap-switch/bootstrap-switch.css'
        resource url: 'js/bootstrap-switch/bootstrap-switch.js'
    }

    "institution-dropdown" {
        dependsOn "jquery,jquery-ui"
        resource url: 'js/institutions-dropdown.js'
        resource url: 'css/institution-dropdown.css'
    }

    "slickgrid" {
        dependsOn "jquery, jquery-ui"
        resource url: 'js/slickgrid/jquery.event.drag-2.2.js'
        resource url: 'js/slickgrid/slick.core.js'
        resource url: 'js/slickgrid/slick.grid.js'
        resource url: 'js/slickgrid/slick.dataview.js'
        resource url: 'js/slickgrid/slick.formatters.js'
        resource url: 'js/slickgrid/slick.editors.js'
        resource url: 'js/slickgrid.bvp.js' // BVP Specific editors/formatters for slickgrid
        resource url: 'js/slickgrid/slick.grid.css'
    }

}