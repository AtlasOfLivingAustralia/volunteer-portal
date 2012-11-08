<style type="text/css">

  #toolContentHeader, #currentTaskHeader {
    background: #3D464C;
    color: white;
  }

  #toolContentHeader h3,#currentTaskHeader h3 {
    color: white;
    padding-bottom: 6px;
  }

  #toolContentHeader hr, #currentTaskHeader hr {
    clear: both;
    height: 1px;
    width: auto;
    background-color: #D1D1D1;
    margin-bottom: 6px;
    border:none;
  }

  #toolContentHeader td {
    /*padding-top: 0px;*/
    padding-bottom: 0px;
  }

  .toolContent table {
    width: 100%;
    margin-bottom: 0px;
  }

  .toolContent td {
    text-align: left;
    padding: 5px
  }

  .toolContent td[colspan="2"] {
    border-bottom: none;
  }

</style>

<script type="text/javascript">

  var toolOpts = {
    doSearch: function(e) {
      alert("Default search action!")
    }
  }


</script>

<div id="toolContent" class="toolContent">

  <g:if test="${taskInstance}">
    <div id="currentTaskHeader">
      <h3>Image from current task</h3>
      <hr/>
    </div>
    <div class="dialog" id="imagePane" >
      <g:each in="${taskInstance.multimedia}" var="m" status="i">
        <g:if test="${!m.mimeType || m.mimeType.startsWith('image/')}">
          <g:set var="imageUrl" value="${grailsApplication.config.server.url}${m.filePath}"/>
            <a href="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_medium.$1')}" class="image_viewer" title="">
                <img src="${imageUrl.replaceFirst(/\.([a-zA-Z]*)$/, '_small.$1')}" title="" style="height: 150px">
            </a>
        </g:if>
      </g:each>
    </div>
    <div style="height: 6px"></div>
  </g:if>

  <div id="toolBody">
    <g:layoutBody />
  </div>

  <script type="text/javascript">

    var imageWidth = $('.image_viewer').first().width();
    var zoomWidth = 500;
    if (imageWidth > 0) {
      zoomWidth = 800 - imageWidth;
    }

    var zopts = {
        zoomType: 'drag',
        zoomWidth: zoomWidth - 15,
        zoomHeight: 150,
        lens:true
    }
    $('.image_viewer').jqzoom(zopts);

    $('.closeFancyBoxButton').click(function(e) {
      e.preventDefault();
      $.fancybox.close();
    });

    $('.toolSearchButton').click(function(e) {
      e.preventDefault();
      if (toolOpts && toolOpts.doSearch) {
        toolOpts.doSearch(e);
      }
    });

  </script>

</div>