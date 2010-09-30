//
//  ScheduleViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScheduleViewController.h"
#import "DetailViewController.h"
#import "ServerUrl.h"
#import "GridCell.h"
#import "GetRemoteDataOperation.h"
#import "JSON.h"

const int kRowHeight = 36.0;
const int kCellWidth = 45;

@interface ScheduleViewController (Private)
- (void)scheduleViewShouldHighlightStop:(NSNotification *)notification;
@end


@implementation ScheduleViewController

@synthesize stops, nearestStopId, selectedStopName, orderedStopNames;
@synthesize tableView, scrollView, gridTimes, gridID, detailViewController, selectedColumn, selectedRow;
@synthesize coveringScrollView, coloredBand;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

        NSLog(@"init sched");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stops = [NSArray array];
    self.orderedStopNames = [NSArray array];    
    self.gridTimes = [NSMutableArray array];
    self.scrollView.tileWidth  = kCellWidth;
    self.scrollView.tileHeight = kRowHeight;
    self.view.clipsToBounds = YES;
    self.tableView.scrollEnabled = YES;
    
    selectedColumn = -1;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scheduleViewShouldHighlightStop:)
                                                 name:@"MBTAShouldHighlightStop" object:nil];    
}

- (void)scheduleViewShouldHighlightStop:(NSNotification *)notification {
    id sender = [notification object];
    if ([sender isEqual:self])
        return;
    NSString *stopName = [[notification userInfo] objectForKey:@"stopName"];
    [self highlightStopNamed:stopName showCurrentColumn:YES];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.coveringScrollView = nil;
    [coloredBand removeFromSuperview];
    self.coloredBand = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    self.nearestStopId = nil;
    self.orderedStopNames = nil;
    self.detailViewController = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
//   [self.tableView reloadData];
    [self.view bringSubviewToFront:self.scrollView];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.directionalLockEnabled = YES;
    [self adjustScrollViewFrame];
    [super viewWillAppear:animated];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self performSelectorInBackground:@selector(releaseLabels) withObject:nil];
    stopAddingLabels = YES;
    //[self releaseLabels];

    [super viewWillDisappear:animated];
}


- (void)highlightNearestStop:(NSString *)stopId {
    self.nearestStopId = stopId;
}

// FLOATING GRID

- (void)clearGrid {
    [coloredBand removeFromSuperview];
    self.stops = [NSArray array];
    self.selectedStopName = nil;
    self.selectedColumn = -1;
    self.tableView.hidden = YES;    
    self.scrollView.hidden = YES;
}

- (void)createFloatingGrid {

    self.tableView.hidden = NO;
    [self.tableView reloadData];

    self.scrollView.stops = [NSArray array];
    self.scrollView.hidden = NO;

    if ([self.stops count] == 0) 
        return;
    NSDictionary *firstRow = [self.stops objectAtIndex:0];
    NSArray *timesForFirstRow = [firstRow objectForKey:@"times"];
    NSInteger numColumns = [timesForFirstRow count];

    int gridWidth = (numColumns * kCellWidth) + 12;
    int gridHeight = ([self.stops count] * kRowHeight);
    [scrollView setContentSize:CGSizeMake(gridWidth, gridHeight)];
    [coveringScrollView setContentSize:CGSizeMake(gridWidth + 320, gridHeight)];
    
    [self adjustScrollViewFrame];
    scrollView.stops = self.stops;
    [self.view bringSubviewToFront:scrollView];
    [scrollView reloadData];
}

- (void)adjustScrollViewFrame {
    scrollView.frame = CGRectMake(320, 0, self.view.frame.size.width - 320, self.view.frame.size.height); 
    coveringScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height); 
    tableView.frame = CGRectMake(0, 0, 319, self.view.frame.size.height); 
    
    [self.view bringSubviewToFront:self.coveringScrollView];
    
}

#pragma mark CoveringScrollViewDelegate

- (void)scrollView:(CoveringScrollView *)scrollView didTouchX:(float)x y:(float)y {
    int row = y / kRowHeight;
    if (row < [self.orderedStopNames count]) {
        NSString *stopName = [self.orderedStopNames objectAtIndex:row];
         NSDictionary *userInfo = [NSDictionary dictionaryWithObject:stopName forKey:@"stopName"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MBTAShouldHighlightStop" object:self userInfo:userInfo];
     
    }
}



#pragma mark color grid cell

- (UIView *)gridScrollView:(GridScrollView *)scrollView tileForRow:(int)row column:(int)column {
    if ((row >= [self.stops count])  || (column >= [[[self.stops objectAtIndex:row] objectForKey:@"times"] count])) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCellWidth, kRowHeight)];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment =   UITextAlignmentCenter;
    label.font = row == self.selectedRow ? [UIFont boldSystemFontOfSize:11.0] :  [UIFont systemFontOfSize:11.0];
    id arrayOrNull = [[[self.stops objectAtIndex:row] objectForKey:@"times"] objectAtIndex:column];
    
    if (arrayOrNull == [NSNull null]) {
        label.text = @" ";
        view.backgroundColor = [UIColor clearColor];
    } else {
        
        NSString *time = [(NSArray *)arrayOrNull objectAtIndex:0];
        label.text = time;
        int period = [(NSNumber *)[(NSArray *)arrayOrNull objectAtIndex:1] intValue];   

        if (period == -1) {
            //view.backgroundColor = [UIColor colorWithRed: (25/255.0 ) green: (255.0/255.0) blue: (76/255.0) alpha:0.2];
            label.textColor = [UIColor grayColor];
        }        
        
    }
        
        
    label.backgroundColor = [UIColor clearColor];
    
    if (column % 2 == 0) {
        view.backgroundColor = [UIColor clearColor];
    } else {
        view.backgroundColor = [UIColor colorWithRed: (214/255.0) green: (214/255.0) blue: (255/255.0) alpha: 0.3];
    }
    
    if (selectedColumn == column) {
    } 

    label.frame = CGRectMake(0, 7, kCellWidth, kRowHeight - 15);
    [view addSubview:label];
    [label release];

    
    return (UIView *)view; 
}

#pragma mark Scroll View delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {

    if ([aScrollView isEqual:coveringScrollView]) {
        scrollView.contentOffset = CGPointMake(coveringScrollView.contentOffset.x, coveringScrollView.contentOffset.y);
        tableView.contentOffset = CGPointMake(0, coveringScrollView.contentOffset.y);
        self.coveringScrollView.directionalLockEnabled = YES; // I don't know why this keeps getting set to NO otherwise
        
    } 
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sScrollView {
    [self alignGridAnimated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)sScrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate)
        [self alignGridAnimated:YES];

}

#pragma mark align grid after decelerating or drag

- (void)alignGridAnimated:(BOOL)animated {
    
    if (self.coveringScrollView.dragging || self.coveringScrollView.decelerating || self.scrollView.dragging || self.scrollView.decelerating || self.tableView.dragging || self.tableView.decelerating) {
        return;
    }
    float x = self.scrollView.contentOffset.x;
    float y = self.scrollView.contentOffset.y;
    CGPoint contentOffset = CGPointMake( (round(x/kCellWidth) * kCellWidth), y);

    [self.scrollView setContentOffset:contentOffset animated:animated];        
    [self.coveringScrollView setContentOffset:contentOffset animated:animated];        
}


#pragma mark Table View stuff

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.stops count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {

        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];         
        cell.accessoryType =  UITableViewCellAccessoryNone; 
        cell.textLabel.textColor = [UIColor blackColor];     
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.textAlignment = UITextAlignmentRight;
    
    }
    
    if (indexPath.row >= [self.stops count]) {
        cell.textLabel.text = @"missing";
        return cell;
        
    }
                          
    NSDictionary *stopRow = [self.stops objectAtIndex:indexPath.row];
    NSDictionary *stopDict = [stopRow objectForKey:@"stop"];
    NSString *stopName =  [stopDict objectForKey:@"name"];
    cell.textLabel.text = stopName;    
     
    return cell;
}




# pragma mark - highlightRow

- (void)highlightRow:(int)row showCurrentColumn:(BOOL)showCurrentColumn {
    
   // NSLog(@"hightlight row %d showCurrentColumn %d", row, showCurrentColumn);    
    if ([self.stops count] == 0) return;
    if (row >= [self.stops count]) return;

    self.selectedRow = row;
    
    float newX;
    if (showCurrentColumn) {
        // move to most relevant column
        NSArray *times = [[self.stops objectAtIndex:row] objectForKey:@"times"];

        int col = 0;
        for (id time in times) {
            if (![time isEqual:[NSNull null]]) {
                int period = [(NSNumber *)[(NSArray *)time objectAtIndex:1] intValue];
                if (period == 1) {
                    break;
                }
            } else {
                NSLog(@"time is null");
            }
            col++;
        }
        newX = kCellWidth * col;        
        self.selectedColumn = col;
    } else {
        newX = self.scrollView.contentOffset.x; // keep the old value
    }
    float maxX = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
    float maxY = self.scrollView.contentSize.height - ((ScheduleViewController *)self.detailViewController.scheduleViewController).view.frame.size.height;

    float newY = row *kRowHeight;
    float y = self.scrollView.contentOffset.y;
    if (self.scrollView.contentSize.height >= self.view.frame.size.height) {
        y = MIN(newY, maxY);
    }
    float x = MIN(newX, maxX);
    if (self.scrollView.contentSize.width < self.scrollView.frame.size.width) {
        x = 0;
    }    

    if (coloredBand) 
        [coloredBand removeFromSuperview];
    
    // put a colored banded in coveringScrollView
    CGRect bandFrame = CGRectMake(0, newY, coveringScrollView.contentSize.width, kRowHeight);
    self.coloredBand = [[[UIView alloc] initWithFrame:bandFrame] autorelease];
    coloredBand.backgroundColor = [UIColor colorWithRed: (25/255.0 ) green: (255.0/255.0) blue: (76/255.0) alpha:0.11];

    [coveringScrollView addSubview:coloredBand];

    CGPoint contentOffset = CGPointMake(x, y);
    [self.coveringScrollView setContentOffset:contentOffset animated:YES];   

    [scrollView reloadData];
    [tableView reloadData];
    
}

- (void)highlightStopNamed:(NSString *)stopName showCurrentColumn:(BOOL)showCurrentColumn {
    if (stopName == nil)
        return;
    int row = [self.orderedStopNames indexOfObject:stopName];
    if (row == NSNotFound)
        return;
    [self highlightRow:row showCurrentColumn:showCurrentColumn];
}

- (void)highlightColumn:(int)col {
    selectedColumn = col;
    [scrollView reloadData];
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
