//= encoding UTF-8
//= require tinymce
//= require_self
tinymce.baseURL = BVP_JS_URLS.contextPath + 'assets/tinymce/4.6.5';
tinymce.init({
  selector: 'textarea.mce',
  convert_urls: false,
  plugins: 'link anchor hr charmap paste',
  menubar: false,
  toolbar: [
    'bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | table | fontsizeselect ',
    'styleselect | undo redo | link unlink anchor hr charmap | paste'
  ],
  statusbar: false,
  target_list: [
    {title: 'None', value: ''},
    {title: 'New page', value: '_blank'}
  ]
});
