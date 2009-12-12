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
  $(".closestStop").removeClass("closestStop");
	$("#" + closestStop.stop_id).addClass("closestStop");
  // find row index of closesstStop 
  var closestStopRow = $("#" + closestStop.stop_id).parent();
  closestStopRowIndex = $(".row-header").index(closestStopRow);

  if (closestStopRowIndex > 4) {
    $("#closestStopFound").html("Jump to closest stop: <span style='font-weight:bold'>" +
        "<a href='#" + closestStop.stop_id + "'>" + closestStop.name + "</span></a>");

  }
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
  togglePageLinks();
}


// * paging through trip sets

function pageRight() {
  if (currentTripSet < numTripSets - 1) {
    $(".trip-set_" + currentTripSet).hide();
    currentTripSet += 1;
    $(".trip-set_" + currentTripSet).show();
    togglePageLinks();
  }
}
function pageLeft() {
  if (currentTripSet > 0) {
    $(".trip-set_" + currentTripSet).hide();
    currentTripSet -= 1;
    $(".trip-set_" + currentTripSet).show();
    togglePageLinks();
  }
}
function togglePageLinks() {
    if (currentTripSet == 0) {
      $(".pageLeftLink").addClass("disabled"); 
    } else {
      $(".pageLeftLink").removeClass("disabled");

    }
    if (currentTripSet == numTripSets -1) {
      $(".pageRightLink").addClass("disabled");
    } else {
      $(".pageRightLink").removeClass("disabled");

    }
}
