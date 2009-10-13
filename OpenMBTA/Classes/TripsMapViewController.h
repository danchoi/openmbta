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
    NSDictionary *regionInfo;
    BOOL shouldReloadRegion;
    NSOperationQueue *operationQueue;
    IBOutlet UITableView *tableView;
    
    NSString *headsign;
    NSString *route_short_name;
    NSString *transportType;
    
    NSString *selected_stop_id;
    BOOL shouldReloadData;
    IBOutlet UILabel *headsignLabel;
    IBOutlet UILabel *routeNameLabel;
    
}
@property (nonatomic, retain) NSDictionary *stops;
@property (nonatomic, retain) NSArray *orderedStopIds;
@property (nonatomic, retain) NSArray *imminentStops;
@property (nonatomic, retain) NSArray *firstStops;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSDictionary *regionInfo;
@property (nonatomic, copy) NSString *headsign;
@property (nonatomic, retain) NSString *route_short_name;
@property (nonatomic, retain) NSString *transportType;
@property (nonatomic, getter=shouldReloadRegion) BOOL shouldReloadRegion;
@property (nonatomic,copy) NSString *selected_stop_id;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, getter=shouldReloadData) BOOL shouldReloadData;
- (void)startLoadingData;
- (void)prepareMap;
- (void)annotateStops;
- (void)didFinishLoadingData:(NSString *)rawData;
- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals;
- (void)addSegmentedControl;
- (void)toggleView:(id)sender;
@end
