//
//  StopArrivalsViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TripViewController;

@interface StopArrivalsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    NSString *headsign;
    NSString *stop_id;
    NSString *route_short_name;
    NSArray *data;
    NSOperationQueue *operationQueue;
    TripViewController *tripViewController;
}
@property (nonatomic,copy) NSString *headsign;
@property (nonatomic,copy) NSString *stop_id;
@property (nonatomic,copy) NSString *route_short_name;
@property (nonatomic,retain) NSArray *data;

@end
