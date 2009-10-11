//
//  TripViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TripViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    NSString *trip_id;
    NSString *position;
    NSArray *data;
    NSOperationQueue *operationQueue;

}
@property (nonatomic, copy) NSString *trip_id;
@property (nonatomic, copy) NSString *position;
@property (nonatomic,retain) NSArray *data;
@end
