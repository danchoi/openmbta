//
//  ScheduleViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridScrollView.h"

@protocol GridScrollViewDataSource;
@class MyScrollView;

@interface ScheduleViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, GridScrollViewDataSource> {
	GridScrollView *scrollView;	// holds floating grid
    UITableView *tableView;
    NSMutableArray *gridTimes;
    BOOL stopAddingLabels;
    NSNumber *gridID;

    NSString *nearestStopId;
    NSArray *stops;

    NSString *selectedStopName;
}
@property (nonatomic, copy) NSString *nearestStopId;
@property (nonatomic, retain) IBOutlet GridScrollView *scrollView;	// holds floating grid
@property (nonatomic, retain) NSMutableArray *gridTimes;
@property (nonatomic, copy) NSNumber *gridID;
@property (nonatomic, retain) NSArray *stops;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *selectedStopName;

- (void)highlightNearestStop:(NSString *)stopId;
- (void)createFloatingGrid;
- (void)clearGrid;
- (void)highlightRow:(int)row;

@end
