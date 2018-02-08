//= encoding UTF-8
//= require tinymce
//= require_self
$(function(){
    tinymce.baseURL = BVP_JS_URLS.contextPath + 'assets/tinymce/4.3.13/';
    /*tinymce.init({
      selector: 'textarea.mce',
      convert_urls: false,
      plugins: 'link anchor hr charmap',
      menubar: false,
      toolbar: [
        'bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | table | fontsizeselect ',
        'styleselect | undo redo | link unlink anchor hr charmap'
      ],
      statusbar: false
    });
    This has moved to tinyMce.gsp
    */
});