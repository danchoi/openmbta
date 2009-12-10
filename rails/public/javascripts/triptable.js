var myLat;
var myLng;

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
	
    $("#" + closestStop.stop_id).addClass("closestStop");

}
function noLocation()
{
  alert('Could not find location');
}

function initialize() {
	if (navigator && navigator.geolocation)
	{	
		navigator.geolocation.getCurrentPosition(foundLocation, noLocation);
	}
}
