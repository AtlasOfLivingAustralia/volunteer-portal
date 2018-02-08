<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="transcribeTool"/>
</head>

<body>

<style type="text/css">

#localityMap {
    float: left;
    height: 250px;
    width: 250px;
    margin-right: 5px;
}

#localityMap img {
    max-width: none !important;
}

#localitySearchResults {
    overflow-y: auto;
    height: 250px
}

</style>

<div id="toolContentHeader">
    <div class="row-fluid">
        <div class="span2">
            <g:message code="collectionEvent.search.locality"/>
        </div>

        <div class="span4">
            <input style="width:100%" type="text" id="localitySearch" value="${verbatimLocality}"/>
        </div>

        <div class="span1" style="vertical-align: middle">
            <a href="#" class="btn btn-default btn-xs fieldHelp"
               title="${message(code:'locality.search.description')}"><i
                    class="fa fa-question help-container"></i></a>
        </div>

        <div class="span5">
            <button class="btnSearch btn"><g:message code="default.search"/></button>
            <button class="btnClose btn"><g:message code="default.cancel"/></button>
        </div>
    </div>
</div>

<div id="localityMap">
</div>

<div id="localitySearchResults">
</div>

<script type="text/javascript">

    function doLocalitySearch() {

        $('#localitySearchResults').html("<div>${message(code:'locality.search.searching')}</div>")

        var searchTerm = $('#localitySearch').val();
        if (searchTerm == '') {
            alert("${message(code:'locality.search.error1')}");
            return;
        }

        var queryParams = '&searchLocality=' + encodeURIComponent(searchTerm);

        var searchUrl = "${createLink(controller: 'locality', action:'searchResultsFragment', params: [taskId:taskInstance.id])}" + queryParams;
        $.ajax(searchUrl).done(function (data) {
            $("#localitySearchResults").html(data);
        });

    }

    var localityMap;

    $(document).ready(function (e) {

        localityMap = new GMaps({
            div: '#localityMap',
            lat: ${grailsApplication.config.location.default.latitude},
            lng: ${grailsApplication.config.location.default.longitude},
            zoom: 10
        });

        $('#localitySearch').keydown(function (e) {
            if (e.keyCode == 13) {
                doLocalitySearch();
            }
        });

        var searchTerm = $('#localitySearch').val();
        if (searchTerm != '') {
            doLocalitySearch();
        }

        // Context sensitive help popups
        $("a.fieldHelp").qtip({
            tip: true,
            position: {
                my: 'bottomRight',
                at: 'topMiddle'
            },
            style: {
                width: 400,
                classes: 'qtip-bootstrap'
            }
        }).bind('click', function (e) {
            e.preventDefault();
            return false;
        });

        $(".btnClose").click(function (e) {
            e.preventDefault();
            bvp.hideModal();
        });

        $(".btnSearch").click(function (e) {
            e.preventDefault();
            doLocalitySearch();
        });

    });

</script>
</body>
</html>