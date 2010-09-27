//
//  OpenMBTAAppDelegate.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "OpenMBTAAppDelegate.h"
#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreFoundation/CoreFoundation.h>

@implementation OpenMBTAAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize reachabilityAlert;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    [navigationController pushViewController:rootViewController animated:YES];
    [rootViewController release];
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
    [self testReachability];
    /*
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    //locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    */
    

    NSDictionary *lastViewedTrip = [[NSUserDefaults standardUserDefaults]
                       objectForKey:@"lastViewedTrip"];
    if (lastViewedTrip) {
        NSLog(@" last viewed %@", lastViewedTrip);
        rootViewController.tripsViewController.headsign = [lastViewedTrip objectForKey:@"headsign"];
        rootViewController.tripsViewController.route_short_name = [lastViewedTrip objectForKey:@"routeShortName"];
        rootViewController.tripsViewController.transportType = [lastViewedTrip objectForKey:@"transportType"];;
        rootViewController.tripsViewController.firstStop = [lastViewedTrip objectForKey:@";firstStop"];
        rootViewController.tripsViewController.shouldReloadRegion = YES;
        rootViewController.tripsViewController.shouldReloadData = YES;
        
        [navigationController pushViewController:rootViewController.tripsViewController animated:YES];
        
        
    }
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

- (void) testReachability {

    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];

	hostReach = [[Reachability reachabilityWithHostName: @"mbta.com"] retain];
	[hostReach startNotifer];
	
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    //NSLog(@"reachability changed: %@", curReach);

    if(curReach == hostReach) {
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        // BOOL connectionRequired= [curReach connectionRequired];
        if (netStatus == NotReachable) {
            // NSLog(@"network not reachable!!!");
            [self showReachabilityAlert];
        }
    }
}

- (void) showReachabilityAlert {
    if (self.reachabilityAlert == nil) {
        self.reachabilityAlert = [[UIAlertView alloc] 
            initWithTitle:@"Network not reachable" 
                  message:@"This application needs access to the Internet to fetch data. Please turn WiFi or cellular reception on before proceeding."
                 delegate:nil 
        cancelButtonTitle:@"OK" 
        otherButtonTitles:nil]; 
        [reachabilityAlert show]; 
        self.reachabilityAlert = nil;
    }
}

@end

