//
//  DetailViewController.h
//  ipadmbta
//
//  Created by Daniel Choi on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>


@class MapViewController;
@class ScheduleViewController;
@class StopsViewController;

@interface DetailViewController : BaseViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    id detailItem;
    UILabel *detailDescriptionLabel;
    
    NSString *headsign;
    NSString *routeShortName;
    NSString *transportType;
    NSString *firstStop; // used for Subway

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
    NSString *selectedStopId;
    NSMutableArray *orderedStopNames;
    BOOL shouldReloadRegion;

    MapViewController *mapViewController;
    UISegmentedControl *segmentedControl;
    NSInteger startOnSegmentIndex;
    
    ScheduleViewController *scheduleViewController;
    UIView *currentContentView;
    StopsViewController *stopsViewController;
    BOOL gridCreated;
    UIBarButtonItem *bookmarkButton; 
    UIView *findingProgressView;

    
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;

@property (nonatomic, copy) NSString *headsign;
@property (nonatomic, retain) NSString *routeShortName;
@property (nonatomic, retain) NSString *transportType;
@property (nonatomic, retain) NSString *firstStop;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) IBOutlet UILabel *headsignLabel;
@property (nonatomic, retain) IBOutlet UILabel *routeNameLabel;    
@property (nonatomic, retain) NSDictionary *stops;
@property (nonatomic, retain) NSArray *orderedStopIds;
@property (nonatomic, retain) NSArray *imminentStops;
@property (nonatomic, retain) NSArray *firstStops;
@property (nonatomic, retain) NSDictionary *regionInfo;
@property (nonatomic,copy) NSString *selectedStopId;

@property (nonatomic, retain) IBOutlet MapViewController *mapViewController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet ScheduleViewController *scheduleViewController;
@property (nonatomic, retain) UIView *currentContentView;
@property (nonatomic, retain) IBOutlet StopsViewController *stopsViewController;
@property (nonatomic, retain) NSMutableArray *orderedStopNames;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *bookmarkButton; 
@property  NSInteger startOnSegmentIndex;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *findStopButton;
@property (nonatomic, retain)   UIView *findingProgressView;


- (void)loadTrips:(NSNotification *)notification;
- (void)styleBookmarkButton;
- (void)toggleView:(id)sender;
- (void)highlightStopNamed:(NSString *)stopName;
- (void)highlightStopPosition:(int)pos;
- (void)startLoadingData;
- (void)showStopsController:(id)sender;
- (void)reloadData:(id)sender;
- (void)toggleBookmark:(id)sender;
- (BOOL)isBookmarked;
- (void)toggleBookmark:(id)sender;
- (IBAction)infoButtonPressed:(id)sender;

- (void)showFindingIndicators;
- (void)hideFindingIndicators;


@end
