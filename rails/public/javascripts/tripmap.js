function initialize() {
  var latlng = new google.maps.LatLng(-34.397, 150.644);
  var sw_latlng = new google.maps.LatLng(sw[0], sw[1]);
  var ne_latlng = new google.maps.LatLng(ne[0], ne[1]);
  var zoom_bounds = new google.maps.LatLngBounds(sw_latlng, ne_latlng);
 
 var myOptions = {
    zoom: 8,
    center: latlng,
    mapTypeControl: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  map.fitBounds(zoom_bounds)

  var pin = '/images/map/PinDown1.png';

	for (var i = 0;i < stops.length ;i++) {
		var stop = stops[i];
		
		var lat = stop.lat;
		var lng = stop.lng;
		
		var stopLatLng = new google.maps.LatLng(lat, lng);
		var stopMarker = new google.maps.Marker({
			position:stopLatLng,
			map:map,
      icon: pin
		})
	}
}
