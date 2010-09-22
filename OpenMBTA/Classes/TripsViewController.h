//
//  TripsViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 9/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface TripsViewController : BaseViewController <CLLocationManagerDelegate> {
    NSString *headsign;
    NSString *route_short_name;
    NSString *transportType;
    NSString *firstStop; // used for Subway
    BOOL shouldReloadData;
    BOOL shouldReloadRegion;
    UIView *contentView;
    NSOperationQueue *operationQueue;
    CLLocationManager *locationManager;
    CLLocation *location;
    UILabel *headsignLabel;
    UILabel *routeNameLabel;    
    NSDictionary *stops;
    NSArray *orderedStopIds;    
    NSArray *imminentStops;  
    NSArray *firstStops;
    NSDictionary *regionInfo;
    NSString *selected_stop_id;
    NSString *nearest_stop_id;    
}
@property (nonatomic, copy) NSString *headsign;
@property (nonatomic, retain) NSString *route_short_name;
@property (nonatomic, retain) NSString *transportType;
@property (nonatomic, retain) NSString *firstStop;
@property (nonatomic, getter=shouldReloadData) BOOL shouldReloadData;
@property (nonatomic, getter=shouldReloadRegion) BOOL shouldReloadRegion;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) IBOutlet UILabel *headsignLabel;
@property (nonatomic, retain) IBOutlet UILabel *routeNameLabel;    
@property (nonatomic, retain) NSDictionary *stops;
@property (nonatomic, retain) NSArray *orderedStopIds;
@property (nonatomic, retain) NSArray *imminentStops;
@property (nonatomic, retain) NSArray *firstStops;
@property (nonatomic, retain) NSDictionary *regionInfo;
@property (nonatomic,copy) NSString *selected_stop_id;
@property (nonatomic,copy) NSString *nearest_stop_id;

- (void)toggleView:(id)sender;
- (void)toggleBookmark:(id)sender;
- (BOOL)isBookmarked;
- (void)startLoadingData;
@end
