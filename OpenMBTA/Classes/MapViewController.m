//
//  MapViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "TripsViewController.h"
#import "StopAnnotation.h"
#import "ScheduleViewController.h"

@implementation MapViewController
@synthesize tripsViewController, mapView, stopAnnotations, nearestStopAnnotation, triggerCalloutTimer, location;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    self.stopAnnotations = [NSMutableArray array];
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewDidUnload {
    [super viewDidUnload];
    [self.stopAnnotations removeAllObjects];
    self.tripsViewController = nil;
    self.stopAnnotations = nil; 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.triggerCalloutTimer = nil;
    [super dealloc];
}

- (void)prepareMap:(NSDictionary *)regionInfo {
    [mapView removeAnnotations:self.stopAnnotations];
    [self.stopAnnotations removeAllObjects];

    tripsViewController.selected_stop_id = nil;
    
    if ([regionInfo objectForKey:@"center_lat"] == nil) 
        return;
    
    MKCoordinateRegion region;    
    region.center.latitude = [[regionInfo objectForKey:@"center_lat"] floatValue];
    region.center.longitude = [[regionInfo objectForKey:@"center_lng"] floatValue];
    region.span.latitudeDelta = [[regionInfo objectForKey:@"lat_span"] floatValue];
    region.span.longitudeDelta = [[regionInfo objectForKey:@"lng_span"] floatValue];
    
    [mapView setRegion:region animated:NO];
    [mapView regionThatFits:region];
    mapView.hidden = NO;
}
- (void)annotateStops:(NSDictionary *)stops imminentStops:(NSArray *)imminentStops firstStops:(NSArray *)firstStops isRealTime:(BOOL)isRealTime {
    NSArray *stop_ids = [stops allKeys];
    for (NSString *stop_id in stop_ids) {
        StopAnnotation *annotation = [[StopAnnotation alloc] init];
        NSDictionary *stopDict = [stops objectForKey:stop_id];
        NSString *stopName =  [stopDict objectForKey:@"name"];
        annotation.subtitle = stopName;
        annotation.title = [self stopAnnotationTitle:((NSArray *)[stopDict objectForKey:@"next_arrivals"]) isRealTime:isRealTime];
        annotation.numNextArrivals = [NSNumber numberWithInt:[[stopDict objectForKey:@"next_arrivals"] count]];
        annotation.stop_id = stop_id;
        if ([imminentStops containsObject:stop_id]) {
            annotation.isNextStop = YES;
        }
        if ([firstStops containsObject:stopName]) annotation.isFirstStop = YES;
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[stopDict objectForKey:@"lat"] doubleValue];
        coordinate.longitude = [[stopDict objectForKey:@"lng"] doubleValue];
        annotation.coordinate = coordinate;
        [self.stopAnnotations addObject:annotation];
        [annotation release];
    }
    [mapView addAnnotations:self.stopAnnotations];    
    [self findNearestStop];
    
    
}

- (void)findNearestStop {
    self.location = mapView.userLocation.location;
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


    // Show callout of nearest stop.  We delay this to give the map time to
    // draw the pins for the stops
    if (self.triggerCalloutTimer != nil)
        self.triggerCalloutTimer.invalidate;
    [NSTimer scheduledTimerWithTimeInterval: 2.0
                                     target: self
                                   selector: @selector(triggerCallout:)
                                   userInfo: nil
                                    repeats: NO];
    
}

- (void)triggerCallout:(StopAnnotation *)stopAnnotation {
    [mapView selectAnnotation:self.nearestStopAnnotation animated:YES]; 
}


- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals isRealTime:(BOOL)isRealTime {
    NSMutableArray *times = [NSMutableArray array];
    int count = 0;
    for (NSArray *pair in nextArrivals) {
        [times addObject:[pair objectAtIndex:0]];
        count = count + 1;
        if (count == 3) break;
    }
    NSString *title;
    if ( [nextArrivals count] > 0 ) {
        title = [NSString stringWithFormat:@"%@ %@", [times componentsJoinedByString:@" "],
                 (isRealTime ? @"(real-time)" : @"")];
    } else {
        title = @"No more arrivals today";
    }
    return title;
}


- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>) annotation {
    if (annotation == mapView.userLocation) return nil;
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



@end
