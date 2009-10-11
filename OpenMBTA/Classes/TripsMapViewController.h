//
//  TripsMapViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class StopArrivalsViewController;

@interface TripsMapViewController : UIViewController <MKMapViewDelegate> {
    NSDictionary *stops;
    NSArray *imminentStops;  
    NSArray *firstStops;
    IBOutlet MKMapView *mapView;
    NSDictionary *regionInfo;
    NSOperationQueue *operationQueue;    
    
    NSString *headsign;
    NSString *route_short_name;
    NSString *transportType;
    
    StopArrivalsViewController *stopArrivalsViewController;
}
@property (nonatomic, retain) NSDictionary *stops;
@property (nonatomic, retain) NSArray *imminentStops;
@property (nonatomic, retain) NSArray *firstStops;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSDictionary *regionInfo;
@property (nonatomic, copy) NSString *headsign;
@property (nonatomic, retain) NSString *route_short_name;
@property (nonatomic, retain) NSString *transportType;
@end
