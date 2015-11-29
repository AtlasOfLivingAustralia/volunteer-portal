<g:if test="${localities}">
    <div id="">
        <g:each in="${localities}" var="locality" status="i">
            <g:set var="rowclass" value="${i % 2 == 0 ? 'even' : 'odd'}"/>
            <table class="${rowclass} localitySearchResult" localityId="${locality.id}" lat="${locality.latitude}"
                   lng="${locality.longitude}" locality="${locality.locality}">
                <tr>
                    <td colspan="2" class="locality">${locality.locality}</td>
                    <td class="buttonCell">
                        <button class="btn selectLocalityButton" localityId="${locality.id}"
                                title="Use this locality">Select&nbsp;locality</button>
                    </td>
                </tr>
                <tr>
                    <td class="localityPoliticalRegion">
                        ${locality.township}
                        <g:if test="${locality.township}">
                            <span>,</span>
                        </g:if>
                        ${locality.state}
                        <g:if test="${locality.state && locality.country}">
                            <span>,</span>
                        </g:if>
                        ${locality.country}
                    </td>
                    <td class="localityLatlong"><a href="#" class="findOnMapLink"
                                                   title="Locate on map">[${locality.latitude}, ${locality.longitude}]</a>
                    </td>
                    <td>
                    </td>
                </tr>
            </table>
        </g:each>
    </div>

    <script type="text/javascript">

        $(".selectLocalityButton").click(function (e) {
            e.preventDefault();
            bindToLocality($(this).attr("localityId"));
            bvp.hideModal();
        });


        $('#searchResultsStatus').text('${localities.size()} matching ${localities.size() == 1 ? "locality" : "localities"}');

        localityMap.removeMarkers();

        $(".localitySearchResult").each(function (e) {

            var elementId = $(this).attr('localityId');

            if (localityMap) {
                try {
                    localityMap.addMarker({
                        lat: $(this).attr('lat'),
                        lng: $(this).attr('lng'),
                        title: $(this).attr('locality'),
                        localityId: $(this).attr('localityId'),
                        animation: google.maps.Animation.DROP,
                        mouseover: function (e, y) {
                            $('table[localityId="' + elementId + '"]').css("background", "orange");

                            var container = $('#localitySearchResults');
                            var scrollTo = $('table[localityId="' + elementId + '"]');

                            container.scrollTop(
                                    scrollTo.offset().top - container.offset().top + container.scrollTop() - 20
                            );
                        },
                        mouseout: function (e, y) {
                            $('table[localityId="' + elementId + '"]').css("background", "");
                        }
                    });

                    localityMap.fitZoom();
                    correctZoom(localityMap);
                } catch (ex) {
                }
            }
        });

        $('.localitySearchResult').mouseenter(function (e) {
            var localityId = $(this).attr('localityId');
            if (localityId) {
                $(this).css("background", "orange");
                setMarkerAnimation(localityMap, localityId, google.maps.Animation.BOUNCE);
            }
        });

        $('.localitySearchResult').mouseleave(function (e) {
            var localityId = $(this).attr('localityId');
            if (localityId) {
                $(this).css('background', '');
                setMarkerAnimation(localityMap, localityId, null);
            }
        });

        $('.findOnMapLink').click(function (e) {
            e.preventDefault();
            var node = $(this).closest('.localitySearchResult')
            if (node) {
                var localityId = node.attr('localityId');
                if (localityId) {
                    zoomToLocalityMarker(localityId);
                }
            }
        });

        function correctZoom(map) {
            var zoom = map.map.getZoom();
            if (zoom > 10) {
                map.setZoom(10);
            }
        }

        function zoomToLocalityMarker(localityId) {
            for (index in localityMap.markers) {
                var marker = localityMap.markers[index];
                if (marker.localityId == localityId) {
                    var latLngs = [marker.getPosition()];
                    localityMap.fitBounds(latLngs);
                    correctZoom(localityMap);
                    break;
                }
            }
        }

        function setMarkerAnimation(map, localityId, animation) {
            // Find the marker...
            for (index in map.markers) {
                var marker = map.markers[index];
                if (marker.localityId == localityId) {
                    marker.setAnimation(animation);
                    break;
                }
            }
        }

    </script>

    <style type="text/css">

    .localitySearchResult {
        width: 100%;
    }

    .selectLocalityButton {
        width: 100%;
    }

    .even {
        background: #F0F0E8
    }

    .buttonCell {
        width: 100px;
    }

    .localityLatlong {
        text-align: right !important;
    }

    #localitySearchResults td {
        text-align: left;
        padding: 5px;
    }

    .localityPoliticalRegion {
        text-align: left;
    }

    </style>
</g:if>
<g:else>
    <span>There are no matching localities.</span>
</g:else>
