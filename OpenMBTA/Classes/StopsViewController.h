//
//  StopsViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TripsViewController;

@interface StopsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *orderedStopNames;    
    UITableView *tableView;
    TripsViewController *tripsViewController;
}
@property (nonatomic, retain) NSMutableArray *orderedStopNames;    
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) TripsViewController *tripsViewController;
- (void)back:(id)sender;
- (void)loadStopNames:(NSMutableArray *)stopNames;
@end
