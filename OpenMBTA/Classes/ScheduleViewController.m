//
//  ScheduleViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScheduleViewController.h"
#import "TripsViewController.h"
#import "ServerUrl.h"
#import "GridCell.h"
#import "GetRemoteDataOperation.h"
#import "JSON.h"

const int kRowHeight = 50;
const int kCellWidth = 44;

@interface ScheduleViewController (Private)
- (void)alignGrid;
@end


@implementation ScheduleViewController

@synthesize stops, nearestStopId, selectedStopName, orderedStopNames;
@synthesize tableView, scrollView, gridTimes, gridID, tripsViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.stops = [NSArray array];
        self.orderedStopNames = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gridTimes = [NSMutableArray array];
    self.scrollView.tileWidth  = kCellWidth;
    self.scrollView.tileHeight = kRowHeight;
    self.view.clipsToBounds = YES;

}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    self.nearestStopId = nil;
    self.orderedStopNames = nil;
    self.tripsViewController = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
//   [self.tableView reloadData];
//    [self.view bringSubviewToFront:self.scrollView];
    self.scrollView.scrollEnabled = YES;
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
    self.stops = [NSArray array];
    self.tableView.hidden = YES;    
    self.scrollView.hidden = YES;
}

- (void)createFloatingGrid {

    self.tableView.hidden = NO;
    [self.tableView reloadData];

    self.scrollView.stops = [NSArray array];
    self.scrollView.hidden = YES;

    if ([self.stops count] == 0) 
        return;
    NSDictionary *firstRow = [self.stops objectAtIndex:0];
    NSArray *timesForFirstRow = [firstRow objectForKey:@"times"];
    NSInteger numColumns = [timesForFirstRow count];

    int gridWidth = (numColumns * kCellWidth) - 10;
    int gridHeight = ([self.stops count] * kRowHeight);
    [scrollView setContentSize:CGSizeMake(gridWidth, gridHeight)];
    [self adjustScrollViewFrame];
    scrollView.stops = self.stops;
    [self.view bringSubviewToFront:scrollView];
    
//    [self.view addSubview:scrollView];
    
    [scrollView reloadData];
}

- (void)adjustScrollViewFrame {
    scrollView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height + 10); 
}

- (UIView *)gridScrollView:(GridScrollView *)scrollView tileForRow:(int)row column:(int)column {
    if ((row >= [self.stops count])  || (column >= [[[self.stops objectAtIndex:row] objectForKey:@"times"] count])) {
        return nil;
    }
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:11.0];
    id arrayOrNull = [[[self.stops objectAtIndex:row] objectForKey:@"times"] objectAtIndex:column];
    label.backgroundColor = [UIColor clearColor];
    if (arrayOrNull == [NSNull null]) {
        label.text = @" ";
    } else {
        
        NSString *time = [(NSArray *)arrayOrNull objectAtIndex:0];
        int period = [(NSNumber *)[(NSArray *)arrayOrNull objectAtIndex:1] intValue];   
        label.text = time;
            
        if (period == -1) {
            label.textColor = [UIColor colorWithRed: (214/255.0) green: (191/255.0) blue: (191/255.0) alpha: 1.0];   
        } else {
            if (column % 2 == 0) {
                label.textColor = [UIColor grayColor];
            } else {
                label.textColor = [UIColor colorWithRed: (122/255.0) green: (122/255.0) blue: (251/255.0) alpha: 1.0];
            }
        }
        
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCellWidth, kRowHeight)];
    label.frame = CGRectMake(10, 15, kCellWidth, kRowHeight - 15);
    [view addSubview:label];
    [label release];
    return (UIView *)view; 
}

#pragma mark Scroll View delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    tableView.contentOffset = CGPointMake(0, aScrollView.contentOffset.y);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self alignGrid];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate)
        [self alignGrid];
}

#pragma mark align grid after decelerating or drag

- (void)alignGrid {
    float x = self.scrollView.contentOffset.x;
    float y = self.scrollView.contentOffset.y;
    float maxY = self.scrollView.contentSize.height - self.scrollView.frame.size.height - (kRowHeight / 2);

    // when at bottom, align toward bottom
    
    float newY;
    if (  y > maxY ) {
        NSLog(@"close to bottom");
        newY = self.scrollView.contentSize.height - self.scrollView.frame.size.height + 10;
    } else {
        newY = round(y/kRowHeight) * kRowHeight;
    }
    CGPoint contentOffset = CGPointMake( (round(x/kCellWidth) * kCellWidth), newY);

    [self.scrollView setContentOffset:contentOffset animated:YES];        
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
    
    static NSString *CellIdentifier = @"GridCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {

        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GridCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];

        cell.accessoryType =  UITableViewCellAccessoryNone; 
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    NSDictionary *stopDict = [[self.stops objectAtIndex:indexPath.row] objectForKey:@"stop"];;
    NSString *stopName =  [stopDict objectForKey:@"name"];
    
    if (indexPath.row == selectedRow)  {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];

        cell.textLabel.textColor = [UIColor blackColor];        
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];

        cell.textLabel.textColor = [UIColor blackColor];        
    }
    
     
    cell.textLabel.text = stopName;
    cell.detailTextLabel.text =  @" ";
    return cell;
}

- (void)highlightRow:(int)row {
    if ([self.stops count] == 0) return;

    selectedRow = row;
    
    // move to most relevant column
    NSArray *times = [[self.stops objectAtIndex:row] objectForKey:@"times"];

    int col = 0;
    for (id time in times) {
        if (![time isEqual:[NSNull null]]) {
            int period = [(NSNumber *)[(NSArray *)time objectAtIndex:1] intValue];
            if (period == 1) {
                break;
            }
         }
        col++;
    }
    float maxX = self.scrollView.contentSize.width - 300;
    float newX = kCellWidth * col;

    float maxY = self.scrollView.contentSize.height - ((ScheduleViewController *)self.tripsViewController.scheduleViewController).view.frame.size.height;
    float newY = row *kRowHeight;

    float y = self.scrollView.contentOffset.y;
    if (self.scrollView.contentSize.height >= self.view.frame.size.height) {
        y = MIN(newY, maxY);
    }
    float x = MIN(newX, maxX);

    if (self.scrollView.contentSize.width < self.view.frame.size.width) {
        x = 0;
    }    
    CGPoint contentOffset = CGPointMake(x , y);
    [self.scrollView setContentOffset:contentOffset animated:YES];        
    
    [tableView reloadData];
    
}

- (void)highlightStopNamed:(NSString *)stopName {
    if (stopName == nil)
        return;
    int row = [self.orderedStopNames indexOfObject:stopName];
    if (row == NSNotFound)
        return;
    [self highlightRow:row];
}

@end
