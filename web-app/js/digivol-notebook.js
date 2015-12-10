"use strict";

var notebook = {
    // Tab indexes that do not require Ajax loading for its content
    nonAjaxTabs: ["4"],

    map: null,

    infowindow: null,

    initMap: function (){
        notebook.map = new google.maps.Map(document.getElementById('map'), {
            scaleControl: true,
            center: new google.maps.LatLng(-24.766785, 134.824219), // centre of Australia
            zoom: 3,
            minZoom: 1,
            streetViewControl: false,
            scrollwheel: false,
            mapTypeControl: true,
            mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
            },
            navigationControl: true,
            navigationControlOptions: {
                style: google.maps.NavigationControlStyle.SMALL // DEFAULT
            },
            mapTypeId: google.maps.MapTypeId.ROADMAP
        });

        notebook.infowindow = new google.maps.InfoWindow();

        // load markers via JSON web service
        var tasksJsonUrl = $('#map').attr('markers-url');
        $.get(tasksJsonUrl, {}, notebook.drawMarkers);
    },

    drawMarkers: function (data) {

        if (data) {
            var markers = [];
            $.each(data, function (i, task) {
                var latlng = new google.maps.LatLng(task.lat, task.lng);
                var marker = new google.maps.Marker({
                    position: latlng,
                    map: notebook.map,
                    title: "record: " + task.taskId,
                    animation: google.maps.Animation.DROP
                });
                markers.push(marker);
                google.maps.event.addListener(marker, 'click', function () {
                    notebook.infowindow.setContent("[loading...]");
                    // load info via AJAX call
                    load_content(marker, task.taskId);
                });
            }); // end each

            new MarkerClusterer(notebook.map, markers, { maxZoom: 18 });
        }

        /**
         * Function to load info windows content via Ajax
         * @param marker
         * @param id
         */
        function load_content(marker, id) {
            $.ajax($('#map').attr('infowindow-url') + "/" + id).done(function(data) {
                var content =
                    "<div style='font-size:12px;line-height:1.3em;'>Catalogue No.: " + data.cat + "<br/>Taxon: " + data.name + "<br/>Transcribed by: " + data.transcriber +
                    "</div>";
                notebook.infowindow.close();
                notebook.infowindow.setContent(content);
                notebook.infowindow.open(notebook.map, marker);
            });

        }
    },

    /**
     * Function to load tabs content via Ajax if required
     */
    loadContent: function () {
        var currentSelectedTab = $('#profileTabsList li.active a');
        // This is a workaround to show the static content of the tab that was selected when no Ajax is involved
        $('#profileTabsList li:eq(0) a').tab('show');
        currentSelectedTab.tab('show');
        if ($.inArray(currentSelectedTab.attr('tab-index'), notebook.nonAjaxTabs) == -1) {
            var url = $('#profileTabsList li.active a').attr('content-url');
            $.ajax(url).done(function (content) {
                $("#profileTabsContent .tab-pane.active").html(content);
            });
        }
    },

    /**
     * Function to add a query string parameter safely
     */
    updateQueryStringParameter: function (uri, key, value) {
        var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
        var separator = uri.indexOf('?') !== -1 ? "&" : "?";
        if (uri.match(re)) {
            return uri.replace(re, '$1' + key + "=" + value + '$2');
        } else {
            return uri + separator + key + "=" + value;
        }
    }
};

$(function() {
    notebook.loadContent();
    notebook.initMap();

    // Every time a tab is selected the page is refreshed and the content loading is deferred via Ajax
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        e.preventDefault();
        location.replace(notebook.updateQueryStringParameter(window.location.pathname, 'selectedTab', $(this).attr('tab-index')) + '#profileTabs');
    });
});