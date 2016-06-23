tinymce.init({
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