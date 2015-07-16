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
        dependsOn 'underscore'
        resource url: '/js/transcribeWidgets.js'
        resource url: '/js/transcribeValidation.js'
        resource url: '/css/transcribeWidgets.css'
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

    "url" {
        resource url: 'js/uri.js'
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

    "greyscale" {
        dependsOn "jquery"
        resource url: 'css/grey/1.4.2/gray.min.css'
        resource url: 'js/grey/1.4.2/jquery.gray.min.js'
    }

    "bootbox" {
        dependsOn "bootstrap-js, jquery"
        resource url: 'js/bootbox/3.3.0/bootbox.js'
    }

    "labelAutocomplete" {
        dependsOn "bootstrap-js, jquery"
        resource url: 'js/label.autocomplete.js'
        resource url: 'css/label.autocomplete.css'
    }

    "codemirror" {
        resource url: 'js/codemirror/5.0/codemirror.css'
        resource url: 'js/codemirror/5.0/codemirror.js'
    }

    "codemirror-codeedit" {
        dependsOn "codemirror"
        resource url: "js/codemirror/5.0/addon/edit/matchbrackets.js"
        resource url: "js/codemirror/5.0/addon/edit/closebrackets.js"
        resource url: "js/codemirror/5.0/addon/comment/continuecomment.js"
        resource url: "js/codemirror/5.0/addon/comment/comment.js"
    }

    "codemirror-json" {
        dependsOn "codemirror"
        resource url: 'js/codemirror/5.0/mode/javascript/javascript.js'
    }

    "codemirror-groovy" {
        dependsOn "codemirror"
        resource url: 'js/codemirror/5.0/mode/groovy/groovy.js'
    }

    "codemirror-sublime" {
        dependsOn "codemirror"
        resource url: 'js/codemirror/5.0/keymap/sublime.js'
    }

    "codemirror-monokai" {
        dependsOn "codemirror"
        resource url: 'js/codemirror/5.0/theme/monokai.css'
    }

    "mustache" {
        resource url: 'js/mustache/2.0.0/mustache.min.js'
    }

    "mustache-util" {
        dependsOn "jquery", "mustache"
        resource url: 'js/mustache-util.js'

    }

    "underscore" {
        resource url: 'js/underscore/1.8.3/underscore-min.js'
    }

    "dotdotdot" {
        resource url: 'js/dotdotdot/1.7.3/jquery.dotdotdot.min.js'
    }

    "transitionend" {
        resource url: 'js/transitionend/1.0.2/transition-end.min.js';
    }

    "cameratrap" {
        dependsOn 'jquery', 'mustache-util', 'underscore', 'dotdotdot', 'bootbox', 'transitionend'
        resource url: 'js/cameratrap.js'
    }

    "fontawesome" {
        resource url: 'css/font-awesome/4.3.0/css/font-awesome.min.css'
    }
}