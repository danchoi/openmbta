//
//  RootViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BaseViewController.h"
@class TripsMapViewController;
@class RoutesViewController;
@class TAlertsViewController;


@interface RootViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    RoutesViewController *routesViewController;
    TAlertsViewController *tAlertsViewController;
    NSOperationQueue *operationQueue;
    NSArray *menu;
}
@property (nonatomic,retain) NSArray *menu;
@property (nonatomic,retain) UITableView *tableView;
@end
