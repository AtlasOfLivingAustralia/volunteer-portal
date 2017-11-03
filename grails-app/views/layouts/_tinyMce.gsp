<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="org.springframework.context.i18n.LocaleContextHolder" %>
<asset:javascript src="tinymce-simple.js" asset-defer="" />
<asset:script>
    $(function(){
        tinymce.baseURL = BVP_JS_URLS.contextPath + 'assets/tinymce/4.3.13/';
        tinymce.init({
          selector: 'textarea.mce',
          convert_urls: false,
          plugins: 'link anchor hr charmap',
          menubar: false,
          toolbar: [
            'bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | table | fontsizeselect ',
            'styleselect | undo redo | link unlink anchor hr charmap'
          ],
          statusbar: false,
          language: '${ LocaleContextHolder.getLocale().getLanguage()}'
        });
    });
</asset:script>