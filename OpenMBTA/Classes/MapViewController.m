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

@implementation MapViewController
@synthesize tripsViewController, mapView, stopAnnotations, nearestStopAnnotation;

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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self.stopAnnotations removeAllObjects];
    self.stopAnnotations = nil; 
    
}


- (void)dealloc {
    self.tripsViewController = nil;
    [super dealloc];
}

- (void)prepareMap:(NSDictionary *)regionInfo {
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
- (void)annotateStops:(NSDictionary *)stops imminentStops:(NSArray *)imminentStops firstStops:(NSArray *)firstStops {
    NSArray *stop_ids = [stops allKeys];
    for (NSString *stop_id in stop_ids) {
        StopAnnotation *annotation = [[StopAnnotation alloc] init];
        NSDictionary *stopDict = [stops objectForKey:stop_id];
        NSString *stopName =  [stopDict objectForKey:@"name"];
        annotation.subtitle = stopName;
        annotation.title = [self stopAnnotationTitle:((NSArray *)[stopDict objectForKey:@"next_arrivals"])];
        annotation.numNextArrivals = [NSNumber numberWithInt:[[stopDict objectForKey:@"next_arrivals"] count]];
        annotation.stop_id = stop_id;
        if ([imminentStops containsObject:stop_id]) annotation.isNextStop = YES;
        if ([firstStops containsObject:stopName]) annotation.isFirstStop = YES;
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[stopDict objectForKey:@"lat"] doubleValue];
        coordinate.longitude = [[stopDict objectForKey:@"lng"] doubleValue];
        annotation.coordinate = coordinate;
        [self.stopAnnotations addObject:annotation];
        [annotation release];
    }
    
    NSLog(@"stop annotations: %@", self.stopAnnotations);
    [mapView addAnnotations:self.stopAnnotations];    
    //[self findNearestStop];
    
    
}

- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals {
    NSMutableArray *times = [NSMutableArray array];
    for (NSArray *pair in nextArrivals) {
        [times addObject:[pair objectAtIndex:0]];
    }
    return [nextArrivals count] > 0 ? [times componentsJoinedByString:@" "] : @"No more arrivals today";
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
