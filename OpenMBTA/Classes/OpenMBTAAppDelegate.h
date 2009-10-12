//
//  OpenMBTAAppDelegate.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import "Reachability.h"

@interface OpenMBTAAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    Reachability* hostReach;
    UIAlertView *reachabilityAlert; 
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) UIAlertView *reachabilityAlert;
- (void) showReachabilityAlert;
- (void) testReachability;

@end

