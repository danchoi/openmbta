//
//  TAlertsViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface TAlertsViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    NSOperationQueue *operationQueue;
    NSArray *alerts;
    NSArray *data;
}
@property (nonatomic, retain) NSArray *alerts;
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) UITableView *tableView;
@end
