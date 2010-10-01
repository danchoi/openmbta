//
//  ipadmbtaAppDelegate.m
//  ipadmbta
//
//  Created by Daniel Choi on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ipadmbtaAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"



@implementation ipadmbtaAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController;
@synthesize reachabilityAlert;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch.
    
    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];
    [self performSelector:@selector(loadLastTrip) withObject:nil afterDelay:1.0];

    [self testReachability];

    return YES;
}

- (void)loadLastTrip {
    [rootViewController loadLastViewedTrip];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
    [splitViewController release];
    [window release];
    self.reachabilityAlert = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Reachability Alert

- (void) testReachability {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	hostReach = [[Reachability reachabilityWithHostName: @"iphonembta.org"] retain];
	[hostReach startNotifer];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);

    if(curReach == hostReach) {
        NetworkStatus netStatus = [curReach currentReachabilityStatus];

        if (netStatus == NotReachable) {
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

