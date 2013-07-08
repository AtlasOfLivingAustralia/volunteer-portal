modules = {

    'style' {
        resource url:'/less/bvp-bootstrap.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style', deposition: 'head'
    }

    'qtip' {
        dependsOn "jquery"
        resource url:'/js/jquery.qtip-1.0.0-rc3.min.js'
    }

}