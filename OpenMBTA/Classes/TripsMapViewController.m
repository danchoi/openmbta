#import "TripsMapViewController.h"
#import "TimePickerViewController.h"
#import "HelpViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Preferences.h"


// Set this to 1 to show a demo location in the simulator
// Set to 0 in production
#define USE_DEMO_LOCATION 0

@interface TripsMapViewController (Private)
- (void)stopSelected:(NSString *)stopId;
- (void)addChangeTimeButton;
- (void)removeChangeTimeButton;
- (void)showTimePicker:(id)sender;
- (void)annotateDemoLocation;
- (void)loadWebView;
- (void)addButtons;
- (void)showLoadingIndicators;
- (void)hideLoadingIndicators;

- (void)addSegmentedControl;
- (void)toggleView:(id)sender;
- (BOOL)isBookmarked;
@end


@implementation TripsMapViewController
@synthesize imminentStops, firstStops, orderedStopIds, stopAnnotations, nearestStopAnnotation;
@synthesize stops;
@synthesize mapView;
@synthesize regionInfo, shouldReloadRegion, shouldReloadData;
@synthesize headsign;
@synthesize route_short_name, transportType;
@synthesize selected_stop_id, nearest_stop_id, baseTime;
@synthesize triggerCalloutTimer;
@synthesize bookmarkButton, changeTimeButton;
@synthesize webView, request;
@synthesize firstStop;
@synthesize location;

- (void)viewDidLoad {
    [super viewDidLoad];

    operationQueue = [[NSOperationQueue alloc] init];    
    self.stopAnnotations = [NSMutableArray array];
    mapView.hidden = YES;
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    mapView.showsUserLocation = YES;
    mapView.mapType = MKMapTypeStandard;

    self.location = nil;

    shouldReloadRegion = YES;
    shouldReloadData = YES;    
//    [self addChangeTimeButton];
 //   [self addBookmarkButton];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(baseTimeDidChange:)
                                                name:@"BaseTimeChanged"
                                               object: nil];
    
    [self addSegmentedControl];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.triggerCalloutTimer != nil)
        self.triggerCalloutTimer.invalidate;

    
    if (self.shouldReloadData) {
      [self loadWebView];
        self.stops = [NSArray array];
        [mapView removeAnnotations:self.stopAnnotations];
        [self.stopAnnotations removeAllObjects];
        [self startLoadingData];
        self.shouldReloadData = NO;        
        headsignLabel.text = self.headsign;
        if ([self.transportType isEqualToString: @"Bus"]) {
            routeNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.transportType, self.route_short_name];

        } else if (self.transportType == @"Subway") {
            routeNameLabel.text = [NSString stringWithFormat:@"%@ (times are only approximate)", self.route_short_name];        

        } else if ([self.transportType isEqualToString: @"Commuter Rail"]) {
            routeNameLabel.text = [NSString stringWithFormat:@"%@ Line", self.route_short_name];     

        } else {
            routeNameLabel.text = self.route_short_name;            

        }
        [self addButtons];
    }
    /*
    if (bookmarkButton) {
        if ([self isBookmarked]) {
            [bookmarkButton setTitle:@"Bookmarked" forState:UIControlStateNormal];
        } else {
            [bookmarkButton setTitle:@"Bookmark" forState:UIControlStateNormal];
        }
    }
    */
 
    [super viewWillAppear:animated];

    // initialize location manager
    /*
    if (location == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
    }
    */
}

- (void)loadWebView {
    // http://openmbta.org/trips.html?transport_type=bus&route_short_name=1&headsign=Dudley%20Station%20via%20Mass.%20Ave.&first_stop=
    // HTML grid
    NSString *urlString = [[NSString stringWithFormat:@"%@/trips.html?transport_type=%@&route_short_name=%@&headsign=%@&first_stop=%@&base_time=%@&from_iphone_app=1", ServerURL, self.transportType, self.route_short_name,self.headsign, self.firstStop,
         self.baseTime == nil ? [NSDate date] : [self.baseTime description] ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  //NSLog(@"calling %@", urlString);
  NSURL *url = [[NSURL alloc] initWithString: urlString];
  self.request = [[NSURLRequest alloc] initWithURL: url]; 
  [url release];
  [self showLoadingIndicators];
  [self.webView loadRequest:self.request];    
}

- (void)baseTimeDidChange:(NSNotification *)notification {
    if (notification.userInfo == nil) {
        [self resetBaseTime];
    } else {
        self.baseTime = [notification.userInfo objectForKey:@"NewBaseTime"];
        //self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
        [self addButtons];
    }
    // NSLog(@"set new base time on trips map to %@", self.baseTime);
    self.shouldReloadData = YES;
//    [self viewWillAppear:NO]; // this will be called automatically when the view appears
    
    NSLog(@"reload webview");
  [self loadWebView];
    
}

// public method called by the parent controller to reset base time to current time whenever a
// new route is selected for this view
- (void)resetBaseTime { 
    self.baseTime = nil;
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // show the callout selected_stop_id (the last stop tapped) if not nil
    // NSLog(@"selected stop id: %@", self.selected_stop_id);
    for (id annotation in mapView.annotations) {
        if (self.selected_stop_id != nil && [annotation respondsToSelector:@selector(stop_id)] && [((StopAnnotation *)annotation).stop_id isEqualToString:self.selected_stop_id]) {
            
            [mapView selectAnnotation:annotation animated:YES];
            break;
        }
    }
}

- (void)dealloc {
    [headsignLabel release];
    [routeNameLabel release];
    self.mapView = nil;
    self.stopAnnotations = nil;
    self.imminentStops = nil;
    self.orderedStopIds = nil;
    self.firstStops = nil;    
    self.stops = nil;
    self.regionInfo = nil;
    self.headsign = nil;
    self.route_short_name = nil;
    self.selected_stop_id = nil;
    self.triggerCalloutTimer = nil;
    self.location = nil;
    [locationManager release];
    [operationQueue release];
    [demoCurrentLocation release];
    [super dealloc];
}

-(void)toggleBookmark:(id)sender {
    if ([self isBookmarked]) {
        Preferences *prefs = [Preferences sharedInstance]; 
        NSDictionary *bookmark = [NSDictionary dictionaryWithObjectsAndKeys: headsign, @"headsign", route_short_name, @"routeShortName", transportType, @"transportType", firstStop, @"firstStop", nil];
        [prefs removeBookmark: bookmark];
    } else {
        Preferences *prefs = [Preferences sharedInstance]; 
        NSDictionary *bookmark = [NSDictionary dictionaryWithObjectsAndKeys: headsign, @"headsign", route_short_name, @"routeShortName", transportType, @"transportType", firstStop, @"firstStop", nil];
        [prefs addBookmark: bookmark];
    }
    [self addButtons];
}

- (BOOL)isBookmarked {
    Preferences *prefs = [Preferences sharedInstance]; 
    NSDictionary *bookmark = [NSDictionary dictionaryWithObjectsAndKeys: headsign, @"headsign", route_short_name, @"routeShortName", transportType, @"transportType", nil];
    return ([prefs isBookmarked:bookmark]);
}


- (void)addButtons {

    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    // create a toolbar where we can place some buttons
    UIToolbar* toolbar;
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 139, 45)];

    if ([self isBookmarked]) {
        /*
        self.bookmarkButton = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Bookmarked"
                                             style:UIBarButtonItemStyleDone
                                             target:self 
                                             action:@selector(toggleBookmark:)];

                                             */

        UIImage *button = [UIImage imageNamed:@"favoritesButton_clicked.png"];
        self.bookmarkButton = [[UIBarButtonItem alloc]
            initWithImage:button
                    style:UIBarButtonItemStyleDone
                   target:self
                   action:@selector(toggleBookmark:)];


    } else {
        UIImage *button = [UIImage imageNamed:@"favoritesButton.png"];
        self.bookmarkButton = [[UIBarButtonItem alloc]
            initWithImage:button
                    style:UIBarButtonItemStyleBordered
                   target:self
                   action:@selector(toggleBookmark:)];
    }
    [buttons addObject:bookmarkButton];
     
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
        target:nil
        action:nil];
    [buttons addObject:spacer];
    [spacer release];

         
    self.changeTimeButton = [[UIBarButtonItem alloc]
                                            initWithTitle:@"Shift Time"
                                                    style:(self.baseTime == nil ? UIBarButtonItemStyleBordered : UIBarButtonItemStyleDone)
                                         target:self 
                                         action:@selector(showTimePicker:)];
    [buttons addObject:self.changeTimeButton];


    [toolbar setItems:buttons animated:NO];
    [buttons release];
     
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:toolbar];
    [toolbar release];
}



- (void)addSegmentedControl {
    NSArray *segments = [[NSArray alloc] initWithObjects:@"Map", @"Table", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segments];
    [segments release];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self
                         action:@selector(toggleView:)
               forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;
    [segmentedControl release];
}

- (void)toggleView:(id)sender {
    NSUInteger selectedSegment = ((UISegmentedControl *)sender).selectedSegmentIndex;
    //NSLog(@"segment: %d", selectedSegment);
    if (selectedSegment == 0) { // map
        mapView.hidden = NO;
        self.webView.hidden = YES;
    } else { // table
        mapView.hidden = YES;
        self.webView.hidden = NO;
    }
}



/*
- (void)addBookmarkButton; {
    if (self.navigationItem.titleView != nil)
        return;
    bookmarkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bookmarkButton.frame = CGRectMake(0, 0, 30, 70);
    bookmarkButton.font = [UIFont boldSystemFontOfSize:13];
    if ([self isBookmarked]) {
        [bookmarkButton setTitle:@"Bookmark" forState:UIControlStateNormal];
    } else {
        [bookmarkButton setTitle:@"Bookmarked" forState:UIControlStateNormal];
    }
    [bookmarkButton addTarget:self action:@selector(toggleBookmark:) forControlEvents:UIControlEventTouchUpInside]; 

    bookmarkButton.frame = CGRectMake(0, 0, 300, 100);
    self.navigationItem.titleView = bookmarkButton;

}

- (void)addChangeTimeButton; {
    if (self.navigationItem.rightBarButtonItem != nil)
        return;
    
    UIBarButtonItem *changeTimeButton = [[UIBarButtonItem alloc]
                                            initWithTitle:@"Shift Time"
                                         style:UIBarButtonItemStyleBordered
                                         target:self 
                                         action:@selector(showTimePicker:)];
    self.navigationItem.rightBarButtonItem = changeTimeButton;
}

- (void)removeChangeTimeButton; {
    self.navigationItem.rightBarButtonItem = nil;
}
*/
- (void)showTimePicker:(id)sender {
    TimePickerViewController *modalVC = [[TimePickerViewController alloc] initWithNibName:@"TimePickerViewController" bundle:nil];
    [self presentModalViewController:modalVC animated:YES];
    [modalVC release];
}

// This calls the server
- (void)startLoadingData
{    
    [self showNetworkActivity];
    
    // We need to substitute a different character for the ampersand in the headsign because Rails splits parameters on ampersands,
    // even escaped ones.
    NSString *headsignAmpersandEscaped = [self.headsign stringByReplacingOccurrencesOfString:@"&" withString:@"^"];

        
    NSString *apiUrl = [NSString stringWithFormat:@"%@/trips?version=2&route_short_name=%@&headsign=%@&transport_type=%@&base_time=%@&first_stop=%@",
                        ServerURL, 
                        self.route_short_name, 
                        headsignAmpersandEscaped, 
                        self.transportType, 
                        self.baseTime == nil ? [NSDate date] : [self.baseTime description], self.firstStop];
    //NSLog(@"would call API with URL: %@", apiUrl);
    
    NSString *apiUrlEscaped = [apiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    GetRemoteDataOperation *operation = [[GetRemoteDataOperation alloc] initWithURL:apiUrlEscaped target:self action:@selector(didFinishLoadingData:)];
    [operationQueue addOperation:operation];
    [operation release];
}

- (void)didFinishLoadingData:(NSString *)rawData 
{
    if (rawData == nil)
        return;
    
    //NSLog(@"loaded data: %@", rawData);
    NSDictionary *data = [rawData JSONValue];
    [self checkForMessage:data];
    self.stops = [data objectForKey:@"stops"];
    //NSLog(@"self stops: %@", self.stops);
    self.orderedStopIds = [data objectForKey:@"ordered_stop_ids"]; // will use in the table
    self.imminentStops = [data objectForKey:@"imminent_stop_ids"];
    self.firstStops = [data objectForKey:@"first_stop"]; // an array of stop names
    self.regionInfo = [data objectForKey:@"region"];
    //NSLog(@"num stops loaded: %d", [stops count]);
    //NSLog(@"loaded region: %@", regionInfo);    
    
    if (shouldReloadRegion == YES) {
        [self prepareMap];
        shouldReloadRegion = NO;
    }
    
    [self annotateStops];
}

- (void)prepareMap 
{
    self.selected_stop_id = nil;
    
    if ([self.regionInfo objectForKey:@"center_lat"] == nil) 
        return;
    
    MKCoordinateRegion region;    
    region.center.latitude = [[self.regionInfo objectForKey:@"center_lat"] floatValue];
    region.center.longitude = [[self.regionInfo objectForKey:@"center_lng"] floatValue];
    region.span.latitudeDelta = [[self.regionInfo objectForKey:@"lat_span"] floatValue];
    region.span.longitudeDelta = [[self.regionInfo objectForKey:@"lng_span"] floatValue];
    
    [mapView setRegion:region animated:NO];
    [mapView regionThatFits:region];
    mapView.hidden = NO;
}

- (void)annotateStops {
    NSArray *stop_ids = [self.stops allKeys];
    for (NSString *stop_id in stop_ids) {
        //NSLog(@"stop: %@", stop);
        StopAnnotation *annotation = [[StopAnnotation alloc] init];
        NSDictionary *stopDict = [stops objectForKey:stop_id];
        NSString *stopName =  [stopDict objectForKey:@"name"];
        annotation.subtitle = stopName;
        annotation.title = [self stopAnnotationTitle:((NSArray *)[stopDict objectForKey:@"next_arrivals"])];
        annotation.numNextArrivals = [NSNumber numberWithInt:[[stopDict objectForKey:@"next_arrivals"] count]];
        annotation.stop_id = stop_id;
        if ([self.imminentStops containsObject:stop_id]) {
            annotation.isNextStop = YES;
        }
        if ([self.firstStops containsObject:stopName]) {
            annotation.isFirstStop = YES;
        }
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[stopDict objectForKey:@"lat"] doubleValue];
        coordinate.longitude = [[stopDict objectForKey:@"lng"] doubleValue];
        annotation.coordinate = coordinate;
        [self.stopAnnotations addObject:annotation];
        [annotation release];
    }
    
    [mapView addAnnotations:self.stopAnnotations];    
    [self hideNetworkActivity];
#if USE_DEMO_LOCATION    
    [self annotateDemoLocation]; // used only to generate a demo location in the simulator
#endif 
    [self findNearestStop];
    
    
}

// used only if USE_DEMO_LOCATION = 1
- (void)annotateDemoLocation {
    demoCurrentLocation = [[DemoCurrentLocation alloc] init];    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 42.364248;
    coordinate.longitude = -71.105506;
    demoCurrentLocation.coordinate = coordinate;
    [mapView addAnnotation:demoCurrentLocation];
    
}

- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals {
    
    NSMutableArray *times = [NSMutableArray array];
    for (NSArray *pair in nextArrivals) {
        [times addObject:[pair objectAtIndex:0]];
    }
    // NSLog(@"annotating: %@", times );

    return [nextArrivals count] > 0 ? [times componentsJoinedByString:@" "] : @"No more arrivals today";
}


- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>) annotation {
    if (annotation == mapView.userLocation) {
        return nil;
    }
#if USE_DEMO_LOCATION
    if ([annotation class] == [DemoCurrentLocation class]) { // for demo video purposes only
        MKAnnotationView *demoLocationDot = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];        
        demoLocationDot.image = [UIImage imageNamed:@"TrackingDot.png"];
        return demoLocationDot;
    }
#endif 
    static NSString *pinID = @"mbtaPin";
	MKPinAnnotationView *pinView =  (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    if (pinView == nil) {
        pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID] autorelease];
        //pinView.pinColor = MKPinAnnotationColorRed;
        pinView.canShowCallout = YES;
        //pinView.animatesDrop = YES; // this causes a callout bug where the callout get obscured by some pins
    }
    if ([annotation respondsToSelector:@selector(isFirstStop)] && ((StopAnnotation *)annotation).isFirstStop) {
        pinView.pinColor = MKPinAnnotationColorGreen;
    } else if ([annotation respondsToSelector:@selector(isNextStop)] && ((StopAnnotation *)annotation).isNextStop) {
        pinView.pinColor = MKPinAnnotationColorPurple;
    } else {
        pinView.pinColor = MKPinAnnotationColorRed;   
    }
	return pinView;
}

- (void)findNearestStop {
#if USE_DEMO_LOCATION
    if (location == nil) {
       self.location = [[CLLocation alloc] initWithLatitude:demoCurrentLocation.coordinate.latitude longitude:demoCurrentLocation.coordinate.longitude];
    }
#else
    self.location = mapView.userLocation.location;
#endif
    if (!location || [self.mapView.annotations count] < 2) {
        if (self.triggerCalloutTimer != nil)
            self.triggerCalloutTimer.invalidate;
        
       [NSTimer scheduledTimerWithTimeInterval: 1.4
                                        target: self
                                       selector: @selector(findNearestStop)
                                        userInfo: nil
                                        repeats: NO];
        
     
       return;
    }

    self.nearestStopAnnotation = nil;
    float minDistance = -1;
    for (id annotation in self.stopAnnotations) {
        CLLocation *stopLocation = [[CLLocation alloc] initWithCoordinate:((StopAnnotation *)annotation).coordinate altitude:0 horizontalAccuracy:kCLLocationAccuracyNearestTenMeters verticalAccuracy:kCLLocationAccuracyHundredMeters timestamp:[NSDate date]];
        CLLocationDistance distance = [stopLocation distanceFromLocation:location];
        [stopLocation release];
        if ((minDistance == -1) || (distance < minDistance)) {
            self.nearestStopAnnotation = (StopAnnotation *)annotation;
            minDistance = distance;
        } 
        //NSLog(@"distance: %f", distance);
    }
    //NSLog(@"min distance: %f; closest stop: %@", minDistance, self.nearestStopAnnotation.subtitle);

    // show callout of nearest stop    
    // We delay this to give map time to draw the pins for the stops
    if (self.triggerCalloutTimer != nil)
        self.triggerCalloutTimer.invalidate;
    
    [NSTimer scheduledTimerWithTimeInterval: 2.0
                                     target: self
                                   selector: @selector(triggerCallout:)
                                   userInfo: nil
                                    repeats: NO];
    
}

- (void)triggerCallout:(StopAnnotation *)stopAnnotation {
    //NSLog(@"triggerCallout on %@", self.nearestStopAnnotation.subtitle);
    [mapView selectAnnotation:self.nearestStopAnnotation animated:YES]; // show callout     
    self.nearest_stop_id = self.nearestStopAnnotation.stop_id;
    // int nearestStopRow = [self.orderedStopIds indexOfObject:[NSNumber numberWithInt:[self.nearest_stop_id intValue]]];
}


- (void)stopSelected:(NSString *)stopId {
    self.selected_stop_id = stopId;
}




- (IBAction)infoButtonPressed:(id)sender {
    NSLog(@"info button pressed");
    HelpViewController *vc = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    vc.viewName = self.mapView.hidden == YES ? @"tripsTable" : @"tripsMap";
    vc.transportType = self.transportType;
    [self presentModalViewController:vc animated:YES];
    [vc release];
    
}
  
- (void)showLoadingIndicators {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
  
  - (void)hideLoadingIndicators
{
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
  

// location stuff

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    return; // not active for now
    if (location)
        return;

    NSLog(@"CLLocation location received");
    location = newLocation;
    [locationManager stopUpdatingLocation];
    [self findNearestStop];
}
  
@end
