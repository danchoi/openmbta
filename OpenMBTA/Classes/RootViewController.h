//
//  RootViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@class TripsMapViewController;
@class RoutesViewController;

@interface RootViewController : UITableViewController {
    RoutesViewController *routesViewController;
    NSOperationQueue *operationQueue;
    NSArray *menu;
}
@property (nonatomic,retain) NSArray *menu;
@end
