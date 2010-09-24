//
//  ScheduleViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ServerUrl.h"
#import "GridCell.h"

const int kRowHeight = 50;

@implementation ScheduleViewController
@synthesize stops, nearestStopId;
@synthesize tableView, scrollView, gridTimes, gridID;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gridTimes = [NSMutableArray array];
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
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}



- (void)highlightNearestStop:(NSString *)stopId {
    self.nearestStopId = stopId;
}


// FLOATING GRID

- (void)createFloatingGrid {
    NSLog(@"starting to creating grid");
    //self.scrollView = nil; // destroy old scrollView

    gridCreated = YES;

    NSDictionary *firstRow = [self.stops objectAtIndex:0];
    NSArray *timesForFirstRow = [firstRow objectForKey:@"times"];
    NSInteger numColumns = [timesForFirstRow count];

    int gridWidth = (numColumns * 50) + 10;
    int gridHeight = ([self.stops count] * kRowHeight) + 50;
    [scrollView setContentSize:CGSizeMake(gridWidth, gridHeight)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    //[scrollView setBackgroundColor:[UIColor redColor]];
    [scrollView setCanCancelContentTouches:NO];
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
    scrollView.scrollEnabled = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];


    [self performSelectorInBackground:@selector(addLabels) withObject:nil];
}

- (void)addLabels { // do in background thread

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    stopAddingLabels = NO; // set to yes when viewWillDisappear

    [self releaseLabels];

    NSDictionary *firstRow = [self.stops objectAtIndex:0];
    NSArray *timesForFirstRow = [firstRow objectForKey:@"times"];
    NSInteger numColumns = [timesForFirstRow count];

    for (int row = 0; row < [self.stops count]; row++) {
        if (stopAddingLabels) {
            NSLog(@"break from adding labels");
            break;
        }

        for (int i = 1; i <= numColumns; i++) {
            if (stopAddingLabels) {
                NSLog(@"break from adding labels");
                break;
            }

            int width = 50;
            int height = kRowHeight;
            int x = (i * width) - 40;
            int y = (row * kRowHeight) + 1;
            CGRect rect = CGRectMake(x, y, width, height);
            UILabel *label = [[UILabel alloc] initWithFrame: rect ];

            id stringOrNull = [[[self.stops objectAtIndex:row] objectForKey:@"times"] objectAtIndex:(i - 1)];
            if (stringOrNull == [NSNull null]) {
                label.text = @" ";
            } else {
                NSString *time = (NSString *)stringOrNull;
                label.text = time;
            }

            if (i % 2 == 0)
                label.textColor = [UIColor grayColor];
            else
                label.textColor = [UIColor blackColor];

            label.font = [UIFont systemFontOfSize: 11];
            label.backgroundColor = [UIColor clearColor];
            
            [self.scrollView addSubview:label];

            [label release];
        }
    }
    NSLog(@"done creating new labels");

    [self scrollViewDidScroll:(id)self.scrollView];
    [self.scrollView setNeedsDisplay];

    [pool release];
}

- (void)releaseLabels { 
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (UIView *label in [self.scrollView subviews]) {
        //NSLog(@"removing label %@", [label class]);
        [label removeFromSuperview];
    }

    [pool release];
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    tableView.contentOffset = CGPointMake(0, aScrollView.contentOffset.y);
}

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

        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.accessoryType =  UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
        
    }
    NSDictionary *stopDict = [[self.stops objectAtIndex:indexPath.row] objectForKey:@"stop"];;
    NSString *stopName =  [stopDict objectForKey:@"name"];
    
    cell.textLabel.text = stopName;
    cell.textLabel.textColor = [UIColor blackColor];        
    cell.detailTextLabel.text =  @" ";
    return cell;
}


@end
