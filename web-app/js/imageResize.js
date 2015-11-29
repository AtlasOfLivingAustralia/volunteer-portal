jQuery(function($) {
  $('img').on("error", function(){
    //console.log('missing img','${g.createLink(uri:'/images/project-placeholder.jpg')}');
    $(this).attr('src', $(this).data('errorUrl'));
  });

  $('img.cropme').resizeAndCrop({
    forceResize: true
  });
});