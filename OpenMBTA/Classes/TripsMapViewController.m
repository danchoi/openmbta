#import "TripsMapViewController.h"
#import "TimePickerViewController.h"
#import "HelpViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface TripsMapViewController (Private)
- (void)stopSelected:(NSString *)stopId;
- (void)addChangeTimeButton;
- (void)removeChangeTimeButton;
- (void)showTimePicker:(id)sender;

@end


@implementation TripsMapViewController
@synthesize imminentStops, firstStops, orderedStopIds, stopAnnotations, nearestStopAnnotation;
@synthesize stops;
@synthesize mapView;
@synthesize regionInfo, shouldReloadRegion, shouldReloadData;
@synthesize headsign;
@synthesize route_short_name, transportType;
@synthesize selected_stop_id, nearest_stop_id, baseTime;
@synthesize tableView;

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

    shouldReloadRegion = YES;
    self.tableView.hidden = YES;
    [self addSegmentedControl];
    shouldReloadData = YES;    
    [self addChangeTimeButton];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(baseTimeDidChange:)
                                                name:@"BaseTimeChanged"
                                               object: nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.shouldReloadData) {
        self.stops = [NSArray array];
        [self.tableView reloadData];
        [mapView removeAnnotations:self.stopAnnotations];
        [self.stopAnnotations removeAllObjects];
        [self startLoadingData];
        self.shouldReloadData = NO;        
        headsignLabel.text = self.headsign;
        if (self.transportType == @"Bus") {
            routeNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.transportType, self.route_short_name];
        } else if (self.transportType == @"Subway") {
            routeNameLabel.text = [NSString stringWithFormat:@"%@ (times are only approximate)", self.route_short_name];        
        } else if (self.transportType == @"Commuter Rail") {
            routeNameLabel.text = [NSString stringWithFormat:@"%@ Line", self.route_short_name];     
            [self removeChangeTimeButton];            
        } else {
            routeNameLabel.text = self.route_short_name;            
        }
        if (self.transportType != @"Commuter Rail") {
            [self addChangeTimeButton];
        }

    }
    
    [super viewWillAppear:animated];

}

- (void)baseTimeDidChange:(NSNotification *)notification {
    if (notification.userInfo == nil) {
        [self resetBaseTime];
    } else {
        self.baseTime = [notification.userInfo objectForKey:@"NewBaseTime"];
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    }
    // NSLog(@"set new base time on trips map to %@", self.baseTime);
    self.shouldReloadData = YES;
//    [self viewWillAppear:NO]; // this will be called automatically when the view appears
    
    
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
    self.tableView = nil;
    self.selected_stop_id = nil;
    [operationQueue release];
    [super dealloc];
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
        self.tableView.hidden = YES;        
    } else { // table
        mapView.hidden = YES;        
        self.tableView.hidden = NO;        
        [self.tableView reloadData];
    }
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

        
    NSString *apiUrl = [NSString stringWithFormat:@"%@/trips?&route_short_name=%@&headsign=%@&transport_type=%@&base_time=%@",
                        ServerURL, 
                        self.route_short_name, 
                        headsignAmpersandEscaped, 
                        self.transportType, 
                        self.baseTime == nil ? [NSDate date] : [self.baseTime description]];
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
    [self.tableView reloadData];
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

- (void)annotateStops 
{
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
    }
    
    [mapView addAnnotations:self.stopAnnotations];    
    [self hideNetworkActivity];
    [self findNearestStop];
    
}

- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals {
    //NSLog(@"annotating: %@", nextArrivals );
    return [nextArrivals count] > 0 ? [nextArrivals componentsJoinedByString:@" "] : @"No more arrivals today";
}


- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>) annotation {
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
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
    
    if (([self.mapView.annotations count] < 2) || (mapView.userLocationVisible == NO))  {
    	[NSTimer scheduledTimerWithTimeInterval: 1.4
                                        target: self
                                       selector: @selector(findNearestStop)
                                        userInfo: nil
                                        repeats: NO];
        
        return;
    }
    self.nearestStopAnnotation = nil;
    
    CLLocation *userLocation;
    userLocation = mapView.userLocation.location;
    float minDistance = -1;
    for (id annotation in self.stopAnnotations) {
        CLLocation *stopLocation = [[CLLocation alloc] initWithCoordinate:((StopAnnotation *)annotation).coordinate altitude:0 horizontalAccuracy:kCLLocationAccuracyNearestTenMeters verticalAccuracy:kCLLocationAccuracyHundredMeters timestamp:[NSDate date]];
        CLLocationDistance distance = [stopLocation getDistanceFrom:userLocation];
        if ((minDistance == -1) || (distance < minDistance)) {
            self.nearestStopAnnotation = (StopAnnotation *)annotation;
            minDistance = distance;
        } 
        //NSLog(@"distance: %f", distance);
    }
    //NSLog(@"min distance: %f; closest stop: %@", minDistance, closestAnnotation.subtitle);

    // show callout of nearest stop    
    // We delay this to give map time to draw the pins for the stops
    [NSTimer scheduledTimerWithTimeInterval: 0.7
                                     target: self
                                   selector: @selector(triggerCallout:)
                                   userInfo: nil
                                    repeats: NO];
    
}

- (void)triggerCallout:(StopAnnotation *)stopAnnotation {
    [mapView selectAnnotation:self.nearestStopAnnotation animated:YES]; // show callout     
    self.nearest_stop_id = self.nearestStopAnnotation.stop_id;
    int nearestStopRow = [self.orderedStopIds indexOfObject:[NSNumber numberWithInt:[self.nearest_stop_id intValue]]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nearestStopRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self.tableView reloadData];
    
}



- (void)stopSelected:(NSString *)stopId {
    self.selected_stop_id = stopId;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.stops count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        
    }
    NSNumber *stop_id = [self.orderedStopIds objectAtIndex:indexPath.row];
    NSDictionary *stopDict = [self.stops objectForKey:[stop_id stringValue]];
    NSString *stopName =  [stopDict objectForKey:@"name"];
    
    if ((self.nearest_stop_id != nil) && [[stop_id stringValue] isEqualToString:self.nearest_stop_id]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : nearest stop", stopName];        
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.text = stopName;
        cell.textLabel.textColor = [UIColor blackColor];        
    }
    // highlight nearest stop
    

    cell.detailTextLabel.text =  [self stopAnnotationTitle:((NSArray *)[stopDict objectForKey:@"next_arrivals"])];
    if ([[stopDict objectForKey:@"next_arrivals"] count] > 1) {
        cell.accessoryType =  UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
    } else {
        cell.accessoryType =  UITableViewCellAccessoryNone;        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([self.firstStops containsObject:stopName]) {    
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.20 green:0.67 blue:0.094 alpha:1.0];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@ : starting point", cell.detailTextLabel.text];
    } else if ([self.imminentStops containsObject:[stop_id stringValue]]) {
        cell.detailTextLabel.textColor = [UIColor purpleColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@ : arriving soon", cell.detailTextLabel.text];        
    } else {
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];        
    }
    
    return cell;
}

- (IBAction)infoButtonPressed:(id)sender {
    NSLog(@"info button pressed");
    HelpViewController *vc = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    vc.viewName = self.mapView.hidden == YES ? @"tripsTable" : @"tripsMap";
    vc.transportType = self.transportType;
    [self presentModalViewController:vc animated:YES];
    [vc release];
    
}
@end
