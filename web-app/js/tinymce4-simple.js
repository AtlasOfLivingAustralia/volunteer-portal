tinymce.init({
  selector: 'textarea.mce',
  convert_urls: false,
  plugins: 'link anchor hr charmap',
  menubar: false,
  toolbar: [
    'styleselect | bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | table | fontsizeselect ',
    'undo redo | link unlink anchor hr charmap'
    ],
  statusbar: false
});