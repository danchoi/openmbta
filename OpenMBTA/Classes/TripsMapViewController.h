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
#import "DemoCurrentLocation.h"

@interface TripsMapViewController : BaseViewController <MKMapViewDelegate, CLLocationManagerDelegate,UIWebViewDelegate> {
    NSDictionary *stops;
    NSArray *orderedStopIds;    
    NSArray *imminentStops;  
    NSArray *firstStops;
    IBOutlet MKMapView *mapView;
    NSMutableArray *stopAnnotations;
    NSDictionary *regionInfo;
    BOOL shouldReloadRegion;
    NSOperationQueue *operationQueue;

    UIBarButtonItem *bookmarkButton; 
    UIBarButtonItem *changeTimeButton;
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
    
    // used only for video and screenshot demo purposes
    DemoCurrentLocation *demoCurrentLocation;

    CLLocationManager *locationManager;
    CLLocation *location;
  
  IBOutlet UIWebView *webView;
  NSURLRequest *request;
    NSString *firstStop; // used for Subway
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
@property (nonatomic, getter=shouldReloadData) BOOL shouldReloadData;
@property (nonatomic, retain) NSDate *baseTime;
@property (nonatomic, retain) NSTimer *triggerCalloutTimer;

@property (nonatomic, retain) UIBarButtonItem *bookmarkButton;
@property (nonatomic, retain) UIBarButtonItem *changeTimeButton;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSString *firstStop;
@property (nonatomic, retain) CLLocation *location;
- (void)startLoadingData;
- (void)prepareMap;
- (void)annotateStops;
- (IBAction)toggleBookmark:(id)sender;
- (void)didFinishLoadingData:(NSString *)rawData;
- (NSString *)stopAnnotationTitle:(NSArray *)nextArrivals;
- (void)addSegmentedControl;
- (void)toggleView:(id)sender;
- (void)resetBaseTime;
- (IBAction)infoButtonPressed:(id)sender;
- (void)findNearestStop;
@end
