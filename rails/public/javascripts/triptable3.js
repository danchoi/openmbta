var myLat;
var myLng;


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
function toStart() {
  if (currentTripSet > 0) {
    $(".trip-set_" + (0)).fadeIn();
    $(".trip-set_" + currentTripSet).hide();
    currentTripSet = 0;
    togglePageLinks();
  }
}

function toEnd() {
  if (currentTripSet < numTripSets - 1) {
    $(".trip-set_" + (numTripSets - 1)).fadeIn();
    $(".trip-set_" + currentTripSet).hide();
    currentTripSet = numTripSets - 1;
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





function initialize() {
  togglePageLinks();
}

