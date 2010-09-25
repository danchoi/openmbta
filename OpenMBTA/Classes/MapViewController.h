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
    MKMapView *mapView;
    NSMutableArray *stopAnnotations;
    StopAnnotation *selectedStopAnnotation;
    NSString *selectedStopName;
    NSTimer *triggerCalloutTimer;
    CLLocation *location;
    MKCoordinateRegion initialRegion;
    BOOL zoomInOnSelect;

}
@property (nonatomic, retain) TripsViewController *tripsViewController;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *stopAnnotations;
@property (nonatomic, retain) StopAnnotation *selectedStopAnnotation;
@property (nonatomic, retain) NSTimer *triggerCalloutTimer;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, copy) NSString *selectedStopName;
@property MKCoordinateRegion initialRegion;

- (void)prepareMap:(NSDictionary *)regionInfo;
- (void)annotateStops:(NSDictionary *)stops imminentStops:(NSArray *)imminentStops firstStops:(NSArray *)firstStops isRealTime:(BOOL)isRealTime;
- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals isRealTime:(BOOL)isRealTime; 
- (void)findNearestStop;
- (void)highlightStopNamed:(NSString *)stopName;
- (void)triggerCallout:(NSDictionary *)info;
@end
