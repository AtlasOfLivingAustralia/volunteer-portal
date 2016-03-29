modules = {

    'admin-stats' {
        dependsOn 'angular, jquery, jquery-ui'
        resource url: '/js/admin-stats.js'
    }


    'digivol' {
        dependsOn 'bootstrap', 'jquery', 'font-awesome', 'qtip', 'digivol-notifications'
        resource url: '/css/main.css'
        resource url: '/css/digivol-custom.css'
    }

    'digivol-stats' {
        dependsOn 'angular'
        resource url: '/js/digivol-stats.js'
        resource url: '/css/digivol-stats.css'
    }

    'digivol-notebook' {
        dependsOn 'digivol', 'marker-clusterer'
        resource url: 'js/digivol-notebook.js'
    }

    'digivol-transcribe' {
        dependsOn 'digivol', 'bootbox'
        resource url: '/css/digivol-expedition.css'
    }

    'digivol-new-project-wizard' {
        dependsOn 'angular', 'angular-ui-router', 'angular-qtip', 'angular-google-maps', 'ng-file-upload', 'angular-bootstrap-show-errors', 'typeahead' // 'angular-typeahead',
        resource url: '/js/new-project-wizard.js'
    }

    'digivol-image-resize' {
        dependsOn 'jquery.resizeAndCrop'
        resource url: '/js/imageResize.js'
    }

    'digivol-notifications' {
        resource url: '/css/animate.css/3.4.0/animate.min.css'
        resource url: '/js/eventsource/polyfill.js'
        resource url: '/js/bootstrap-notify/3.1.3/bootstrap-notify.min.js'
        resource url: '/js/digivol-notify.js'
    }

    'qtip' {
        dependsOn "jquery"
        resource url:'/js/qtip.2.2.1/jquery.qtip.css'
        resource url:'/js/qtip.2.2.1/jquery.qtip.js'
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
        resource url: 'js/bootstrap-switch/bootstrap-switch.min.css'
        resource url: 'js/bootstrap-switch/bootstrap-switch.min.js'
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
        resource url: 'js/bootbox/4.4.0/bootbox.js'
    }

    "labelAutocomplete" {
        dependsOn "bootstrap-js, jquery, typeahead"
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
        resource url: 'css/cameratrap.css'
    }

    'bootstrap-file-input' {
        dependsOn 'jquery', 'bootstrap'
        resource url: 'js/bootstrap.file-input/bootstrap.file-input.js'
    }

    'bootstrap-colorpicker' {
        dependsOn 'jquery', 'bootstrap'
        resource url: 'js/bootstrap-colorpicker/2.3/js/bootstrap-colorpicker.min.js'
        resource url: 'js/bootstrap-colorpicker/2.3/css/bootstrap-colorpicker.min.css'
    }

    "moment" {
        resource url: 'js/moment/2.10.6/moment.min.js'
    }

    "livestamp" {
        dependsOn 'jquery', 'moment'
        resource url: 'js/livestamp/1.1.2/livestamp.min.js'
    }

    'marker-clusterer' {
        resource url: 'js/markerclusterer.js'

    }

    'typeahead' {
        resource url: 'js/typeahead/0.11.1/typeahead.bundle.js'
        resource url: 'js/typeahead/0.11.1/typeaheadjs.css'
    }

    'jquery.resizeAndCrop' {
        resource url: 'js/jquery.resizeandcrop.0.4.0/jquery.resizeandcrop.css'
        resource url: 'js/jquery.resizeandcrop.0.4.0/jquery.resizeandcrop.js'
    }

    'angular' {
        resource url: 'js/angular/1.4.7/angular.min.js'
        resource url: 'js/angular/1.4.7/angular-csp.css'
    }

    'angular-ui-router' {
        dependsOn 'angular'
        resource url: '/js/angular/ui-router/0.2.15/angular-ui-router.min.js'
    }

    'angular-typeahead' {
        dependsOn 'jquery', 'angular', 'typeahead'
        resource url: '/js/angular/typeahead/0.2.4/angular-typeahead.min.js'
    }

    'angular-qtip' {
        dependsOn 'jquery', 'angular', 'qtip'
        resource url: '/js/angular/qtip/angular-qtip.js'
    }

    'angular-simple-logger' {
        dependsOn 'angular'
        resource url: '/js/angular/simple-logger/0.1.5/angular-simple-logger.light.min.js'
    }

    'angular-google-maps' {
        dependsOn 'angular', 'underscore', 'angular-simple-logger'
        resource url: '/js/angular/google-maps/2.2.1/angular-google-maps.min.js'
    }

    'ng-file-upload' {
        dependsOn 'angular'
        resource url: '/js/angular/file-upload/9.1.2/ng-file-upload.min.js'
    }

    'angular-bootstrap-show-errors' {
        dependsOn 'angular'
        resource url: '/js/angular/bootstrap-show-errors/2.3.0/showErrors.min.js'
    }

    'angular-moment' {
        dependsOn 'angular', 'moment'
        resource url: '/js/angular/moment/1.0.0-beta.3/angular-moment.min.js'
    }
}
