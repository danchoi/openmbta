function initialize() {
  var latlng = new google.maps.LatLng(-34.397, 150.644);
  var myOptions = {
    zoom: 8,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  var sw_latlng = new google.maps.LatLng(sw[0], sw[1]);
  var ne_latlng = new google.maps.LatLng(ne[0], ne[1]);
  var zoom_bounds = new google.maps.LatLngBounds(sw_latlng, ne_latlng);
  map.fitBounds(zoom_bounds)

	for (var i = 0;i < 2;i++) {
		var stop = stops[i];
		
		var lat = stop.lat;
		var lng = stop.lng;
		
		var stopLatLng = new google.maps.LatLng(lat, lng);
		var stopMarker = new google.maps.Marker({
			position:stopLatLng,
			map:map
		})
	}
}