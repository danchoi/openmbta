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
    NSString *stop_name;
    NSString *route_short_name;
    NSArray *data;
    NSOperationQueue *operationQueue;
    TripViewController *tripViewController;
    
    IBOutlet UILabel *headsignLabel;
    IBOutlet UILabel *stopNameLabel;
}
@property (nonatomic,copy) NSString *headsign;
@property (nonatomic,copy) NSString *stop_id;
@property (nonatomic,copy) NSString *stop_name;
@property (nonatomic,copy) NSString *route_short_name;
@property (nonatomic,retain) NSArray *data;

@end
