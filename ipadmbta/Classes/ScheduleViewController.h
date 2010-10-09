//
//  ScheduleViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridScrollView.h"
#import "CoveringScrollView.h"

@protocol GridScrollViewDataSource;
@class DetailViewController;

@interface ScheduleViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, GridScrollViewDataSource, CoveringScrollViewDelegate> {
	GridScrollView *scrollView;	// holds floating grid
    UITableView *tableView;
    
    CoveringScrollView *coveringScrollView;
    UIScrollView *underScrollView;
    
    NSMutableArray *gridTimes;
    BOOL stopAddingLabels;
    NSNumber *gridID;

    NSString *nearestStopId;
    NSArray *stops;

    NSString *selectedStopName;
    int selectedRow;
    int selectedColumn;
    NSArray *orderedStopNames;
    DetailViewController *detailViewController;
    UIView *coloredBand;
}
@property (nonatomic, copy) NSString *nearestStopId;
@property (nonatomic, retain) IBOutlet GridScrollView *scrollView;	// holds floating grid
@property (nonatomic, retain) IBOutlet CoveringScrollView *coveringScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *underScrollView;
@property (nonatomic, retain) NSMutableArray *gridTimes;
@property (nonatomic, copy) NSNumber *gridID;
@property (nonatomic, retain) NSArray *stops;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *selectedStopName;
@property (nonatomic, retain) NSArray *orderedStopNames;
@property (nonatomic, retain) DetailViewController *detailViewController;
@property int selectedColumn;
@property int selectedRow;
@property (nonatomic, retain) IBOutlet UIView *coloredBand;
- (void)highlightNearestStop:(NSString *)stopId;
- (void)createFloatingGrid;
- (void)clearGrid;
- (void)highlightRow:(int)row showCurrentColumn:(BOOL)s;
- (void)highlightStopNamed:(NSString *)stopName showCurrentColumn:(BOOL)s;
- (void)highlightColumn:(int)col;
- (void)adjustScrollViewFrame;
- (void)alignGridAnimated:(BOOL)animated;
- (void)doubleTouchedColumn:(int)col;

@end
