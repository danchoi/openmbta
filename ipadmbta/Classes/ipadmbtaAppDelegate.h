//
//  ipadmbtaAppDelegate.h
//  ipadmbta
//
//  Created by Daniel Choi on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@class RootViewController;
@class DetailViewController;

@interface ipadmbtaAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    RootViewController *rootViewController;
    DetailViewController *detailViewController;

    Reachability *hostReach;
    UIAlertView *reachabilityAlert; 
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@property (nonatomic, retain) UIAlertView *reachabilityAlert;
- (void) showReachabilityAlert;
- (void) testReachability;
- (void)loadLastTrip;

@end
