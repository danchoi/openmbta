//
//  ScheduleViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridScrollView.h"

@class MyScrollView;

@interface ScheduleViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate> {
	GridScrollView *scrollView;	// holds floating grid
    UITableView *tableView;
    NSMutableArray *gridTimes;
    BOOL stopAddingLabels;
    BOOL gridCreated;
    NSNumber *gridID;

    NSString *nearestStopId;
    NSArray *stops;
    
}
@property (nonatomic, copy) NSString *nearestStopId;
@property (nonatomic, retain) IBOutlet GridScrollView *scrollView;	// holds floating grid
@property (nonatomic, retain) NSMutableArray *gridTimes;
@property (nonatomic, copy) NSNumber *gridID;
@property (nonatomic, retain) NSArray *stops;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)highlightNearestStop:(NSString *)stopId;
- (void)createFloatingGrid;
- (void)addLabels;
- (void)releaseLabels;
@end
