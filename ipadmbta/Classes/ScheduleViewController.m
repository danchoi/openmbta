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

@end


@implementation ScheduleViewController

@synthesize stops, nearestStopId, selectedStopName, orderedStopNames;
@synthesize tableView, scrollView, gridTimes, gridID, detailViewController, selectedColumn;
@synthesize coveringScrollView;

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
    self.tableView.scrollEnabled = YES;
    
    selectedColumn = -1;
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
    self.coveringScrollView = nil;
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
    
    [self.view bringSubviewToFront:self.coveringScrollView];
    
}

#pragma mark color grid cell

- (UIView *)gridScrollView:(GridScrollView *)scrollView tileForRow:(int)row column:(int)column {
    if ((row >= [self.stops count])  || (column >= [[[self.stops objectAtIndex:row] objectForKey:@"times"] count])) {
        return nil;
    }
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:11.0];
    id arrayOrNull = [[[self.stops objectAtIndex:row] objectForKey:@"times"] objectAtIndex:column];
    
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
    label.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCellWidth, kRowHeight)];
    
    if (selectedColumn == column) {
        view.backgroundColor = [UIColor colorWithRed: (25/255.0 ) green: (255.0/255.0) blue: (76/255.0) alpha:0.2];
    } else {
        view.backgroundColor = [UIColor clearColor];
    }

    label.frame = CGRectMake(7, 7, kCellWidth, kRowHeight - 15);
    [view addSubview:label];
    [label release];

    
    return (UIView *)view; 
}

#pragma mark Scroll View delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {

    if ([aScrollView isEqual:coveringScrollView]) {
        scrollView.contentOffset = CGPointMake(coveringScrollView.contentOffset.x, coveringScrollView.contentOffset.y);
        tableView.contentOffset = CGPointMake(0, coveringScrollView.contentOffset.y);
    } 
    self.coveringScrollView.directionalLockEnabled = YES; // I don't know why this keeps getting set to NO otherwise
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
    
    if (self.coveringScrollView.dragging || self.coveringScrollView.tracking || self.coveringScrollView.decelerating) {
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
    
    static NSString *CellIdentifier = @"GridCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {

        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];         
        cell.accessoryType =  UITableViewCellAccessoryNone; 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    if (indexPath.row >= [self.stops count]) {
        cell.textLabel.text = @"missing";
        return cell;
        
    }
                          
    NSDictionary *stopRow = [self.stops objectAtIndex:indexPath.row];
    NSDictionary *stopDict = [stopRow objectForKey:@"stop"];
    NSString *stopName =  [stopDict objectForKey:@"name"];
    
    if (indexPath.row == selectedRow)  {
        cell.textLabel.textColor = [UIColor blackColor];        
    } else {
        cell.textLabel.textColor = [UIColor blackColor];        
    }
    
     
    cell.textLabel.text = stopName;
    cell.detailTextLabel.text =  @" ";
    return cell;
}




# pragma mark - highlightRow

- (void)highlightRow:(int)row showCurrentColumn:(BOOL)showCurrentColumn {
    
   // NSLog(@"hightlight row %d showCurrentColumn %d", row, showCurrentColumn);    
    if ([self.stops count] == 0) return;
    if (row >= [self.stops count]) return;

    selectedRow = row;
    
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
             }
            col++;
        }
        newX = kCellWidth * col;        
        self.selectedColumn = col;
    } else {
        newX = self.scrollView.contentOffset.x; // keep the old value
    }
    float maxX = self.scrollView.contentSize.width - 320;
    float maxY = self.scrollView.contentSize.height - ((ScheduleViewController *)self.detailViewController.scheduleViewController).view.frame.size.height;
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
