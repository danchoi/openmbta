
var myLat;
var myLng;
var map;
var red_pin = '/images/map/PinDown1.png';
var green_pin = '/images/map/PinDown1Green.png';
var purple_pin = '/images/map/PinDown1Purple.png';
var currentSelectedStop;
var stopMarkers = {};

Number.prototype.toRad = function() {  // convert degrees to radians 
  return this * Math.PI / 180; 
}

function haversineDistance(lat1, lon1, lat2, lon2)
{
	var R = 6371; // km 
	var dLat = (lat2-lat1).toRad(); 
	var dLon = (lon2-lon1).toRad(); 
	var a = Math.sin(dLat/2) * Math.sin(dLat/2) + 
	        Math.cos(lat1.toRad()) * Math.cos(lat2.toRad()) * 
	        Math.sin(dLon/2) * Math.sin(dLon/2); 
	var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
	var d = R * c;
	return d;
}

function foundLocation(position)
{
  myLat = position.coords.latitude;
  myLng = position.coords.longitude;
  //alert('Found location: ' + myLat + ', ' + myLng);
	var currentLatLng = new google.maps.LatLng(myLat, myLng);
	var currentMarker = new google.maps.Marker({
		position:currentLatLng,
		map:map,
		icon: "/images/map/TrackingDot.png"
	})
	
    /*
	var closestStop;
	var closestDistance;
	var currentDistance;
	for (var i = 0;i < stops.length;i++)
	{
		if (closestStop == null) {
			closestStop = stops[i];
			closestDistance = haversineDistance(myLat, myLng, stops[i].lat, stops[i].lng);
		} else {
			currentDistance = haversineDistance(myLat, myLng, stops[i].lat, stops[i].lng);
			if (currentDistance < closestDistance)
			{
				closestStop = stops[i];
				closestDistance = currentDistance;
			}
		}
	}
	
	var message = closestStop.name + '<br/>' + closestStop.next_arrivals;
	document.getElementById('stop_info').innerHTML = message;
	//map.setCenter(stopLatLng);
	if (currentSelectedStop)
	{
		currentSelectedStop.setIcon(pin)
	}
	var closestStopMarker = stopMarkers[closestStop.name];
	closestStopMarker.setIcon("/images/map/PinDown1Green.png")
	currentSelectedStop = closestStop;
    */
}
function noLocation()
{
  alert('Could not find location');
}

function createMarker(stop, map) {

	var lat = stop.lat;
	var lng = stop.lng;
	var stopLatLng = new google.maps.LatLng(lat, lng);

    var icon;
    if (parseInt(current_stop_id) === parseInt(stop.stop_id)) 
      icon = green_pin;
    else 
      icon = red_pin;

    var stopMarker = new google.maps.Marker({
      position:stopLatLng,
      map:map,
      icon: icon
    });
	
	stopMarkers[stop.name] = stopMarker;

  //var message = stop.name + '<br/>' + stop.next_arrivals;
  google.maps.event.addListener(stopMarker, 'click', function () {
      var newUrl = location.href.replace(/stop_id=(\d+)/, "stop_id=" + stop.stop_id);
      location.href = newUrl; 
  });

  return stopMarker;
}

function initialize() {
  var latlng = new google.maps.LatLng(center_lat, center_lng);
 
  var myOptions = {
    zoom: zoomLevel,
    center: latlng,
    mapTypeControl: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
		draggable: true,
		navigationControl: true,
		navigationControlOptions: {
			position: google.maps.ControlPosition.TOP_LEFT,
			style: google.maps.NavigationControlStyle.SMALL
		},
		disableDoubleClickZoom: true
  };
  map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

	if (navigator && navigator.geolocation)
	{	
		navigator.geolocation.getCurrentPosition(foundLocation, noLocation);
	}

	for (var i = 0;i < stops.length ;i++) {
		var stop = stops[i];
		createMarker(stop, map);
	}
}
