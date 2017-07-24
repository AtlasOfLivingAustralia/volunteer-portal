<div class="form-horizontal">

    <div class="control-group">
        <g:textField name="search" class="form-control" value="" placeholder="Search"/>
        <button id="btnSearchProjects" class="btn btn-primary"><i class="icon-search"></i> <g:message code="default.search"/></button>
        <button class="btn btn-default" id="btnCancelProjectSearch"><g:message code="default.cancel"/></button>
    </div>

    <div id="searchResults" style="height: 300px; overflow-y: auto">

    </div>

</div>
<script>

    $("#search").keypress(function (e) {
        if (e.keyCode == 13) {
            e.preventDefault();
            doProjectSearch();
        }
    });

    $("#btnSearchProjects").click(function (e) {
        e.preventDefault();
        doProjectSearch();
    });

    function doProjectSearch() {
        $("#searchResults").html("${message(code:'default.searching')}");
        $.ajax("${createLink(action:"findProjectResultsFragment")}?q=" + $("#search").val()).done(function (content) {
            $("#searchResults").html(content);
        });
    }

    $("#btnCancelProjectSearch").click(function (e) {
        e.preventDefault();
        bvp.hideModal();
    });

</script>