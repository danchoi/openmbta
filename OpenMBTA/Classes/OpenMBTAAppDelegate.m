//
//  OpenMBTAAppDelegate.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "OpenMBTAAppDelegate.h"
#import "RootViewController.h"


@implementation OpenMBTAAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    [navigationController pushViewController:rootViewController animated:YES];
    [rootViewController release];
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

