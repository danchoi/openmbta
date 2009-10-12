#import "TripsMapViewController.h"


@interface TripsMapViewController (Private)
@end


@implementation TripsMapViewController
@synthesize imminentStops, firstStops;
@synthesize stops;
@synthesize mapView;
@synthesize regionInfo, shouldReloadRegion;
@synthesize headsign;
@synthesize route_short_name, transportType;
@synthesize selected_stop_id;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    operationQueue = [[NSOperationQueue alloc] init];    
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    mapView.showsUserLocation = YES;
    mapView.mapType = MKMapTypeStandard;
    self.title = @"Map";
    shouldReloadRegion = YES;
}

- (void)viewWillAppear:(BOOL)animated
{

    [mapView removeAnnotations: mapView.annotations];    
    [self startLoadingData];
    [super viewWillAppear:animated];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // show the callout selected_stop_id (the last stop tapped) if not nil
    NSLog(@"selected stop id: %@", self.selected_stop_id);
    for (id annotation in mapView.annotations) {
        if (self.selected_stop_id != nil && [annotation respondsToSelector:@selector(stop_id)] && [((StopAnnotation *)annotation).stop_id isEqualToString:self.selected_stop_id]) {
            
            [mapView selectAnnotation:annotation animated:YES];
            break;
        }
    }
    
}


- (void)dealloc {
    self.mapView = nil;
    self.imminentStops = nil;
    self.firstStops = nil;    
    self.stops = nil;
    self.regionInfo = nil;
    self.headsign = nil;
    self.route_short_name = nil;
    [selected_stop_id release];
    [operationQueue release];
    [stopArrivalsViewController release];

    [super dealloc];
}

// This calls the server
- (void)startLoadingData
{    
    [self showNetworkActivity];
    
    // We need to substitute a different character for the ampersand in the headsign because Rails splits parameters on ampersands,
    // even escaped ones.
    NSString *headsignAmpersandEscaped = [self.headsign stringByReplacingOccurrencesOfString:@"&" withString:@"^"];

    NSString *apiUrl = [NSString stringWithFormat:@"%@/trips?&route_short_name=%@&headsign=%@&transport_type=%@", ServerURL, self.route_short_name, headsignAmpersandEscaped, self.transportType];
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
    
    MKCoordinateRegion region;    
    region.center.latitude = [[self.regionInfo objectForKey:@"center_lat"] floatValue];
    region.center.longitude = [[self.regionInfo objectForKey:@"center_lng"] floatValue];
    region.span.latitudeDelta = [[self.regionInfo objectForKey:@"lat_span"] floatValue];
    region.span.longitudeDelta = [[self.regionInfo objectForKey:@"lng_span"] floatValue];
    
    [mapView setRegion:region animated:NO];
    [mapView regionThatFits:region];
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
        //NSLog(@"IMMINENT STOPs: %@", self.imminentStops);        
        //NSLog(@"class: %@", [[self.imminentStops objectAtIndex:0] class]);
        //NSLog(@"this STOP: %@", stop_id);                
        if ([self.imminentStops containsObject:stop_id]) {
            //NSLog(@"THIS IS IMMINENT STOP: %@", stop_id);
            annotation.isNextStop = YES;
        }
        if ([self.firstStops containsObject:stopName]) {
            annotation.isFirstStop = YES;
        }
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[stopDict objectForKey:@"lat"] doubleValue];
        coordinate.longitude = [[stopDict objectForKey:@"lng"] doubleValue];
        annotation.coordinate = coordinate;
        [mapView addAnnotation:annotation];
    }
    [self hideNetworkActivity];

}



- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals {
    //NSLog(@"annotating: %@", nextArrivals );
    return [nextArrivals count] > 0 ? [nextArrivals componentsJoinedByString:@" "] : @"No more arrivals today";
}


- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>) annotation {
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
    
    if ([annotation respondsToSelector:@selector(numNextArrivals)] && [((StopAnnotation *)annotation).numNextArrivals intValue] > 1) {
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];        
        pinView.rightCalloutAccessoryView = detailButton;          
    } else {
        pinView.rightCalloutAccessoryView = nil;             
    }
	return pinView;
}

- (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"pin tapped for %@ : stop_id: %@", ((StopAnnotation *)view.annotation).title, ((StopAnnotation *)view.annotation).stop_id);
    
    if ([view.annotation respondsToSelector:@selector(numNextArrivals)] && 
        [((StopAnnotation *)view.annotation).numNextArrivals intValue] < 2) {
        return;
    } 
        
    if (stopArrivalsViewController == nil) {
        stopArrivalsViewController = [[StopArrivalsViewController alloc] initWithNibName:@"StopArrivalsViewController" bundle:nil];
    }
    stopArrivalsViewController.headsign = self.headsign;
    stopArrivalsViewController.stop_id = ((StopAnnotation *)view.annotation).stop_id;
    self.selected_stop_id = ((StopAnnotation *)view.annotation).stop_id;
    stopArrivalsViewController.stop_name = ((StopAnnotation *)view.annotation).subtitle;
    stopArrivalsViewController.route_short_name = self.route_short_name;
    stopArrivalsViewController.transportType = self.transportType;
    [self.navigationController pushViewController:stopArrivalsViewController animated:YES];
}



@end
