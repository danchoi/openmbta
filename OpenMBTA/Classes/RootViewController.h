//
//  RootViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BaseViewController.h"
#import "TripsViewController.h"
@class RoutesViewController;
@class TAlertsViewController;
@class TweetsViewController;


@interface RootViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    RoutesViewController *routesViewController;
    TAlertsViewController *tAlertsViewController;
    TweetsViewController *tweetsViewController;
    TripsViewController *tripsViewController;
    NSOperationQueue *operationQueue;
    NSArray *menu;
    NSArray *menu2;    
    NSArray *bookmarks;
}

@property (nonatomic, retain) TripsViewController *tripsViewController;
@property (nonatomic,retain) NSArray *menu;
@property (nonatomic,retain) NSArray *menu2;
@property (nonatomic,retain) NSArray *bookmarks;
@property (nonatomic,retain) UITableView *tableView;

@end
