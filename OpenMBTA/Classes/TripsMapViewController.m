#import "TripsMapViewController.h"
#import "JSON.h"
#import "StopAnnotation.h"
#import "ServerUrl.h"
#import "GetRemoteDataOperation.h"
#import "StopArrivalsViewController.h"

@interface TripsMapViewController (Private)
- (void)startLoadingData;
- (void)prepareMap;
- (void)annotateStops;
- (void)didFinishLoadingData:(NSString *)rawData;
@end


@implementation TripsMapViewController
@synthesize imminentStops, firstStops;
@synthesize stops;
@synthesize mapView;
@synthesize regionInfo;
@synthesize headsign;
@synthesize route_short_name;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    operationQueue = [[NSOperationQueue alloc] init];    
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    mapView.showsUserLocation = YES;
    mapView.mapType = MKMapTypeStandard;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [mapView removeAnnotations: mapView.annotations];
    [self startLoadingData];
    [super viewWillAppear:animated];
}

- (void)prepareMap 
{

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

        NSString *nextArrivals = [[stopDict objectForKey:@"next_arrivals"] componentsJoinedByString:@" "];
        //NSLog(@"annotating: %@", nextArrivals );
        annotation.title = nextArrivals;
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
}

- (void)dealloc {
    self.mapView = nil;
    self.imminentStops = nil;
    self.firstStops = nil;    
    self.stops = nil;
    self.regionInfo = nil;
    self.headsign = nil;
    self.route_short_name = nil;
    [operationQueue release];
    [stopArrivalsViewController release];

    [super dealloc];
}

// This calls the server
- (void)startLoadingData
{    
    // We need to substitute a different character for the ampersand in the headsign because Rails splits parameters on ampersands,
    // even escaped ones.
    NSString *headsignAmpersandEscaped = [self.headsign stringByReplacingOccurrencesOfString:@"&" withString:@"^"];

    NSString *apiUrl = [NSString stringWithFormat:@"%@/trips?&route_short_name=%@&headsign=%@", ServerURL, self.route_short_name, headsignAmpersandEscaped];
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
    self.stops = [data objectForKey:@"stops"];
    self.imminentStops = [data objectForKey:@"imminent_stop_ids"];
    self.firstStops = [data objectForKey:@"first_stop"]; // an array of stop names
    self.regionInfo = [data objectForKey:@"region"];
    //NSLog(@"num stops loaded: %d", [stops count]);
    //NSLog(@"loaded region: %@", regionInfo);    
    [self prepareMap];
    [self annotateStops];
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>) annotation {
    static NSString *pinID = @"mbtaPin";
	MKPinAnnotationView *pinView =  (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    if (pinView == nil) {
        pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID] autorelease];
        //pinView.pinColor = MKPinAnnotationColorRed;
        pinView.canShowCallout = YES;
        //pinView.animatesDrop = YES; // this causes a callout bug where the callout get obscured by some pins
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = detailButton;        
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

- (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"pin tapped for %@ : stop_id: %@", ((StopAnnotation *)view.annotation).title, ((StopAnnotation *)view.annotation).stop_id);
    if (stopArrivalsViewController == nil) {
        stopArrivalsViewController = [[StopArrivalsViewController alloc] initWithNibName:@"StopArrivalsViewController" bundle:nil];
    }
    stopArrivalsViewController.headsign = self.headsign;
    stopArrivalsViewController.stop_id = ((StopAnnotation *)view.annotation).stop_id;
    stopArrivalsViewController.stop_name = ((StopAnnotation *)view.annotation).subtitle;
    stopArrivalsViewController.route_short_name = self.route_short_name;
    [self.navigationController pushViewController:stopArrivalsViewController animated:YES];
}



@end
