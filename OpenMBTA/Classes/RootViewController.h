//
//  RootViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BaseViewController.h"
#import "TripsMapViewController.h"
@class RoutesViewController;
@class TAlertsViewController;


@interface RootViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    RoutesViewController *routesViewController;
    TAlertsViewController *tAlertsViewController;
    TripsMapViewController *tripsMapViewController;
    NSOperationQueue *operationQueue;
    NSArray *menu;
    NSArray *bookmarks;
}
@property (nonatomic,retain) NSArray *menu;
@property (nonatomic,retain) NSArray *bookmarks;
@property (nonatomic,retain) UITableView *tableView;

@end
