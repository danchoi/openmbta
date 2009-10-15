//
//  TripsMapViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JSON.h"
#import "StopAnnotation.h"
#import "ServerUrl.h"
#import "GetRemoteDataOperation.h"
#import "BaseViewController.h"


@interface TripsMapViewController : BaseViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSDictionary *stops;
    NSArray *orderedStopIds;    
    NSArray *imminentStops;  
    NSArray *firstStops;
    IBOutlet MKMapView *mapView;
    NSMutableArray *stopAnnotations;
    NSDictionary *regionInfo;
    BOOL shouldReloadRegion;
    NSOperationQueue *operationQueue;
    IBOutlet UITableView *tableView;
    
    NSString *headsign;
    NSString *route_short_name;
    NSString *transportType;
    
    NSString *selected_stop_id;
    NSString *nearest_stop_id;    
    StopAnnotation *nearestStopAnnotation;
    BOOL shouldReloadData;
    IBOutlet UILabel *headsignLabel;
    IBOutlet UILabel *routeNameLabel;
    NSDate *baseTime; // used when user picks a different base time for getting stop arrival times
    NSTimer *triggerCalloutTimer;
}
@property (nonatomic, retain) NSDictionary *stops;
@property (nonatomic, retain) NSArray *orderedStopIds;
@property (nonatomic, retain) NSArray *imminentStops;
@property (nonatomic, retain) NSArray *firstStops;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *stopAnnotations;
@property (nonatomic, retain) NSDictionary *regionInfo;
@property (nonatomic, copy) NSString *headsign;
@property (nonatomic, retain) NSString *route_short_name;
@property (nonatomic, retain) NSString *transportType;
@property (nonatomic, getter=shouldReloadRegion) BOOL shouldReloadRegion;
@property (nonatomic,copy) NSString *selected_stop_id;
@property (nonatomic,copy) NSString *nearest_stop_id;
@property (nonatomic, retain) StopAnnotation *nearestStopAnnotation;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, getter=shouldReloadData) BOOL shouldReloadData;
@property (nonatomic, retain) NSDate *baseTime;
@property (nonatomic, retain) NSTimer *triggerCalloutTimer;
- (void)startLoadingData;
- (void)prepareMap;
- (void)annotateStops;
- (void)didFinishLoadingData:(NSString *)rawData;
- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals;
- (void)addSegmentedControl;
- (void)toggleView:(id)sender;
- (void)resetBaseTime;
- (IBAction)infoButtonPressed:(id)sender;
- (void)findNearestStop;
@end
