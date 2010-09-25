//
//  RoutesViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripsViewController.h"
#import "BaseViewController.h"

@interface RoutesViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    TripsViewController *tripsViewController;
    NSOperationQueue *operationQueue;
    NSArray *data;
    NSString *transportType;
    NSString *lineName; // only used when used as a second level CR menu
    NSString *lineHeadsign; // only used when used as a second level CR menu
    BOOL shouldReloadData;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSString *transportType;
@property (nonatomic, retain) NSString *lineName;
@property (nonatomic, retain) NSString *lineHeadsign;
@property (nonatomic, getter=shouldReloadData) BOOL shouldReloadData;
- (void)reset;
@end
