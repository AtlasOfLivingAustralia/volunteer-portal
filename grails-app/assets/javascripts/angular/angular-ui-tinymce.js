//= encoding UTF-8
//= require angular-assets
//= require tinymce
//= require compile/angular-ui-tinymce/0.0.19/tinymce.js
//= require_self
angular.module('ui.tinymce')
  .value('uiTinymceConfig', {
    baseUrl: BVP_JS_URLS.contextPath + 'assets/tinymce/4.6.5/'
  });