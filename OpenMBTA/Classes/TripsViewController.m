//
//  TripsViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 9/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TripsViewController.h"
#import "GetRemoteDataOperation.h"
#import "Preferences.h"
#import "ServerUrl.h"
#import <CoreLocation/CoreLocation.h>
#import "JSON.h"
#import "MapViewController.h"
#import "ScheduleViewController.h"
#import "StopsViewController.h"
#import "Preferences.h"


@implementation TripsViewController
@synthesize contentView;
@synthesize headsign, route_short_name, transportType, firstStop, shouldReloadData, shouldReloadRegion, stops, orderedStopIds, imminentStops, firstStops, regionInfo, headsignLabel, routeNameLabel, selectedStopId, bookmarkButton ;
@synthesize location;
@synthesize mapViewController, scheduleViewController;
@synthesize segmentedControl;
@synthesize currentContentView;
@synthesize stopsViewController;
@synthesize orderedStopNames;

- (void)viewDidLoad {
    [super viewDidLoad];
    operationQueue = [[NSOperationQueue alloc] init];    
    self.location = nil;
    shouldReloadRegion = YES;
    shouldReloadData = YES;    
    mapViewController.tripsViewController = self;
    scheduleViewController.tripsViewController = self;
    stopsViewController.tripsViewController = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self addBookmarkButton];
    if (self.shouldReloadData) {
        
        self.stops = [NSArray array];
        self.mapViewController.selectedStopAnnotation = nil;
        [self startLoadingData];
        
        self.shouldReloadData = NO;        
        headsignLabel.text = self.headsign;
        if ([self.transportType isEqualToString: @"Bus"]) {
            routeNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.transportType, self.route_short_name];

        } else if (self.transportType == @"Subway") {
            routeNameLabel.text = [NSString stringWithFormat:@"%@ (times are only approximate)", self.route_short_name];        

        } else if ([self.transportType isEqualToString: @"Commuter Rail"]) {
            routeNameLabel.text = [NSString stringWithFormat:@"%@ Line", self.route_short_name];     

        } else {
            routeNameLabel.text = self.route_short_name;            
        }
    }

    [super viewWillAppear:animated];
    [self toggleView:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationItem.rightBarButtonItem = nil;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    mapViewController.tripsViewController = nil;
    scheduleViewController.tripsViewController = nil;
    stopsViewController.tripsViewController = nil;
    
}

- (void)dealloc {
    self.imminentStops = nil;
    self.orderedStopIds = nil;
    self.orderedStopNames = nil;
    self.firstStops = nil;    
    self.stops = nil;
    self.regionInfo = nil;
    self.headsign = nil;
    self.route_short_name = nil;
    self.selectedStopId = nil;
    self.location = nil;
    [locationManager release];
    [operationQueue release];
    self.mapViewController = nil;
    self.scheduleViewController = nil;

    [super dealloc];
}

- (BOOL)isBookmarked {
    Preferences *prefs = [Preferences sharedInstance]; 
    NSDictionary *bookmark = [NSDictionary dictionaryWithObjectsAndKeys: headsign, @"headsign", route_short_name, @"routeShortName", transportType, @"transportType", nil];
    return ([prefs isBookmarked:bookmark]);
}

- (void)addBookmarkButton; {
    if (self.navigationItem.rightBarButtonItem != nil)
        return;
    
    if ([self isBookmarked]) {
        self.bookmarkButton = [[UIBarButtonItem alloc]
                               initWithTitle:@"Bookmarked"
                               style:UIBarButtonItemStyleDone
                               target:self 
                               action:@selector(toggleBookmark:)];
        
        
    } else {
        self.bookmarkButton = [[UIBarButtonItem alloc]
                               initWithTitle:@"Bookmark"
                               style:UIBarButtonItemStylePlain
                               target:self 
                               action:@selector(toggleBookmark:)];
    }

    self.navigationItem.rightBarButtonItem = self.bookmarkButton;
}


-(void)toggleBookmark:(id)sender {
    if ([self isBookmarked]) {
        Preferences *prefs = [Preferences sharedInstance]; 
        NSDictionary *bookmark = [NSDictionary dictionaryWithObjectsAndKeys: headsign, @"headsign", route_short_name, @"routeShortName", transportType, @"transportType", firstStop, @"firstStop", nil];
        [prefs removeBookmark: bookmark];
    } else {
        Preferences *prefs = [Preferences sharedInstance]; 
        NSDictionary *bookmark = [NSDictionary dictionaryWithObjectsAndKeys: headsign, @"headsign", route_short_name, @"routeShortName", transportType, @"transportType", firstStop, @"firstStop", nil];
        [prefs addBookmark: bookmark];
    }
    self.navigationItem.rightBarButtonItem = nil;
    [self addBookmarkButton];
}


- (void)reloadData:(id)sender {    
    self.stops = [NSArray array];    
    [self startLoadingData];
}

// This calls the server
- (void)startLoadingData {    
    [self showNetworkActivity];
    gridCreated = NO;
    [self.scheduleViewController clearGrid];

    // We need to substitute a different character for the ampersand in the
    // headsign because Rails splits parameters on ampersands, even escaped
    // ones.
    NSString *headsignAmpersandEscaped = [self.headsign stringByReplacingOccurrencesOfString:@"&" withString:@"^"];
    NSString *apiUrl = [NSString stringWithFormat:@"%@/trips?version=3&route_short_name=%@&headsign=%@&transport_type=%@&base_time=%@&first_stop=%@",
                        ServerURL, 
                        self.route_short_name, 
                        headsignAmpersandEscaped, 
                        self.transportType, 
                        [NSDate date],
                        self.firstStop];
    //NSLog(@"would call API with URL: %@", apiUrl);
    NSString *apiUrlEscaped = [apiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    GetRemoteDataOperation *operation = [[GetRemoteDataOperation alloc] initWithURL:apiUrlEscaped target:self action:@selector(didFinishLoadingData:)];
    [operationQueue addOperation:operation];
    [operation release];
}

- (void)didFinishLoadingData:(NSString *)rawData {
    if (rawData == nil) return;
    NSDictionary *data = [rawData JSONValue];
    scheduleViewController.stops = [data objectForKey:@"grid"];
    [scheduleViewController createFloatingGrid];
    
    BOOL isRealTime = NO;
    if ([data objectForKey:@"realtime"]) {
        isRealTime = YES;
        // do something in view to indicate
    }
    [self checkForMessage:data];
    self.stops = [data objectForKey:@"stops"];

    // construct GRID

    
    //NSLog(@"self stops: %@", self.stops);
    self.orderedStopIds = [data objectForKey:@"ordered_stop_ids"]; // will use in the table
    self.imminentStops = [data objectForKey:@"imminent_stop_ids"];
    self.firstStops = [data objectForKey:@"first_stop"]; // an array of stop names
    self.regionInfo = [data objectForKey:@"region"];

    if (shouldReloadRegion == YES) {
        [mapViewController prepareMap:regionInfo];
        shouldReloadRegion = NO;
    }
    [mapViewController annotateStops:self.stops imminentStops:self.imminentStops firstStops:self.firstStops isRealTime:isRealTime];
    
    self.orderedStopNames = [NSMutableArray arrayWithCapacity:[self.orderedStopIds count]];
    for (id stopId in self.orderedStopIds) {
        NSDictionary *stop = [self.stops objectForKey:[stopId stringValue] ];
        [self.orderedStopNames addObject:[stop objectForKey:@"name"]];
    }
    [self.stopsViewController loadStopNames:self.orderedStopNames];
    self.scheduleViewController.orderedStopNames = self.orderedStopNames;
    [self hideNetworkActivity];

}


- (void)toggleView:(id)sender {

    NSUInteger selectedSegment = self.segmentedControl.selectedSegmentIndex;

    [currentContentView removeFromSuperview];
    if (selectedSegment == 0) { 
        mapViewController.view.frame = CGRectMake(0, 0, 320, 372); 
        self.currentContentView = mapViewController.view;
        [contentView addSubview:mapViewController.view];

    } else { 
        scheduleViewController.view.frame = CGRectMake(0, 0, 320, 300); 
        self.currentContentView = scheduleViewController.view;
        [contentView addSubview:scheduleViewController.view];
        if (!gridCreated) {
            [scheduleViewController createFloatingGrid];        
            [scheduleViewController highlightStopNamed:self.mapViewController.selectedStopName];
            gridCreated = YES;
        }
        [self.scheduleViewController scrollViewDidScroll:self.scheduleViewController.scrollView]; // to align table with grid
    }
}


- (void)showStopsController:(id)sender {
    [self presentModalViewController:self.stopsViewController animated:YES];
}

- (void)highlightStopNamed:(NSString *)stopName {
    [self.mapViewController highlightStopNamed:stopName];
    [self.scheduleViewController highlightStopNamed:stopName];
}


- (void)highlightStopPosition:(int)pos {
    NSString *stopName = [self.orderedStopNames objectAtIndex:pos];
    [self.mapViewController highlightStopNamed:stopName];
    [self.scheduleViewController highlightRow:pos];
}


@end
