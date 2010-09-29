//
//  RootViewController.h
//  ipadmbta
//
//  Created by Daniel Choi on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class RoutesViewController;
@class TAlertsViewController;
@class TweetsViewController;
#import "StopsViewController.h"

@class DetailViewController;

@interface RootViewController : UITableViewController {
    DetailViewController *detailViewController;
    RoutesViewController *routesViewController;
    TAlertsViewController *tAlertsViewController;
    TweetsViewController *tweetsViewController;
    NSOperationQueue *operationQueue;
    NSArray *menu;
    NSArray *menu2;    
    NSArray *bookmarks;
    StopsViewController *stopsVC;
    
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic,retain) NSArray *menu;
@property (nonatomic,retain) NSArray *menu2;
@property (nonatomic,retain) NSArray *bookmarks;
@property (nonatomic, retain) StopsViewController *stopsVC;
- (void)loadLastViewedTrip;

@end
