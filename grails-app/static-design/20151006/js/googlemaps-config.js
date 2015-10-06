// Initializing Google Map
var map;
function initMap() {
  // Init the Map object
  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: -33.513, lng: 151.022},
    zoom: 12,
    mapTypeControl: false,
    scaleControl: false,
    zoomControl: true,
    streetViewControl: false,
    scrollwheel: false,
  });

  // Init the markers on the map
  var markers = [
    { id: 1, lat: -33.52078905, lng: 151.11351013},
    { id: 2, lat: -33.47956309, lng: 151.042099},
    { id: 3, lat: -33.51391942, lng: 151.02287292},
    { id: 4, lat: -33.53338196, lng: 151.05308533},
    { id: 5, lat: -33.53338196, lng: 151.08192444},
    { id: 6, lat: -33.55398457, lng: 151.11763},
    { id: 7, lat: -33.51849924, lng: 150.97343445}
  ];

  _.each(markers, function(marker) {
    addMarkerToMap(marker, map);
  })
}

// Reusable function to add markers to a map
var addMarkerToMap = function (marker, map) {
  var latLng = {lat: marker.lat, lng: marker.lng};
  new google.maps.Marker({
    position: latLng,
    map: map,
    icon: 'img/mapMarker.png',
    title: marker.id.toString()
  });
}