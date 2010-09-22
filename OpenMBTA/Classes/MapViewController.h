//
//  MapViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class TripsViewController;
@class StopAnnotation;

@interface MapViewController : UIViewController <MKMapViewDelegate> {
    TripsViewController *tripsViewController;
    IBOutlet MKMapView *mapView;
    NSMutableArray *stopAnnotations;
    StopAnnotation *nearestStopAnnotation;
    NSTimer *triggerCalloutTimer;
    CLLocation *location;
}
@property (nonatomic, assign) TripsViewController *tripsViewController;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *stopAnnotations;
@property (nonatomic, retain) StopAnnotation *nearestStopAnnotation;
@property (nonatomic, retain) NSTimer *triggerCalloutTimer;
@property (nonatomic, retain) CLLocation *location;
- (void)prepareMap:(NSDictionary *)regionInfo;
- (void)annotateStops:(NSDictionary *)stops imminentStops:(NSArray *)imminentStops firstStops:(NSArray *)firstStops;
- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals; 
- (void)findNearestStop;
@end
