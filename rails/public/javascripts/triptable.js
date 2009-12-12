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


// * paging through trip sets

function pageRight() {
  if (currentTripSet < numTripSets - 1) {
    $(".trip-set_" + (currentTripSet + 1)).fadeIn();
    $(".trip-set_" + currentTripSet).hide();
    currentTripSet += 1;
    togglePageLinks();
  }
}
function pageLeft() {
  if (currentTripSet > 0) {
    $(".trip-set_" + (currentTripSet - 1)).fadeIn();
    $(".trip-set_" + currentTripSet).hide();
    currentTripSet -= 1;
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




/**
 * You can identify a swipe gesture as follows:
 * 1. Begin gesture if you receive a touchstart event containing one target touch.
 * 2. Abort gesture if, at any time, you receive an event with >1 touches.
 * 3. Continue gesture if you receive a touchmove event mostly in the x-direction.
 * 4. Abort gesture if you receive a touchmove event mostly the y-direction.
 * 5. End gesture if you receive a touchend event.
 * 
 * @author Dave Dunkin
 * @copyright public domain
 */
function addSwipeListener(el, listener)
{
 var startX;
 var dx;
 var direction;
 
 function cancelTouch()
 {
  el.removeEventListener('touchmove', onTouchMove);
  el.removeEventListener('touchend', onTouchEnd);
  startX = null;
  startY = null;
  direction = null;
 }
 
 function onTouchMove(e)
 {
  if (e.touches.length > 1)
  {
   cancelTouch();
  }
  else
  {
   dx = e.touches[0].pageX - startX;
   var dy = e.touches[0].pageY - startY;
   if (direction == null)
   {
    direction = dx;
    e.preventDefault();
   }
   else if ((direction < 0 && dx > 0) || (direction > 0 && dx < 0) || Math.abs(dy) > 15)
   {
    cancelTouch();
   }
  }
 }

 function onTouchEnd(e)
 {
  cancelTouch();
  if (Math.abs(dx) > 50)
  {
   listener({ target: el, direction: dx > 0 ? 'right' : 'left' });
  }
 }
 
 function onTouchStart(e)
 {
  if (e.touches.length == 1)
  {
   startX = e.touches[0].pageX;
   startY = e.touches[0].pageY;
   el.addEventListener('touchmove', onTouchMove, false);
   el.addEventListener('touchend', onTouchEnd, false);
  }
 }
 
 el.addEventListener('touchstart', onTouchStart, false);
}



function initialize() {
	if (navigator && navigator.geolocation)
	{	
		navigator.geolocation.getCurrentPosition(foundLocation, noLocation);
	}
  togglePageLinks();
  addSwipeListener(document.body, function(e) { 
      if (e.direction == 'left') 
        pageRight();
      else if (e.direction == 'right') 
        pageLeft();

      //alert(e.direction); 
  });
}

