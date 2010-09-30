//
//  StopsViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopsViewController.h"

@interface StopsViewController ()
- (void)reset:(NSNotification *)notification;
- (void)viewShouldHighlightStop:(NSNotification *)notification;

@end


@implementation StopsViewController
@synthesize orderedStopNames, selectedStopName;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStopNames:)
                                                 name:@"MBTAloadOrderedStopNames" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reset:)
                                                 name:@"loadMBTATrips" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewShouldHighlightStop:)
                                                 name:@"MBTAShouldHighlightStop" object:nil];
    
    self.title = @"Stops";

}

- (void)reset:(NSNotification *)notification {
    self.orderedStopNames = [NSMutableArray array];
    [self.tableView reloadData];
}


- (void)viewShouldHighlightStop:(NSNotification *)notification {
    id sender = [notification object];
    if ([sender isEqual:self]) {
        return;
    }
    NSString *stopName = [[notification userInfo] objectForKey:@"stopName"];
//    NSLog(@"%@: sender %@", self, sender);
    [self selectStopNamed:stopName];
    
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
    self.tableView = nil;    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.selectedStopName) {
        int row = [self.orderedStopNames indexOfObject:self.selectedStopName];    
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.orderedStopNames = nil;
    [super dealloc];
}

- (void)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)loadStopNames:(NSNotification *)notification {
    
    NSMutableArray *stopNames = [NSMutableArray arrayWithArray:[[notification userInfo] objectForKey:@"orderedStopNames"]];
    self.orderedStopNames = stopNames;
    [self.tableView reloadData];
}


- (void)selectStopNamed:(NSString *)stopName {
    self.selectedStopName = stopName;
    int row = [self.orderedStopNames indexOfObject:stopName];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return ([self.orderedStopNames count]);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0]; 


    }
	// Configure the cell.
    cell.textLabel.text = [self.orderedStopNames objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *stopName = [self.orderedStopNames objectAtIndex:indexPath.row];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:stopName forKey:@"stopName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MBTAShouldHighlightStop" object:self userInfo:userInfo];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36.0;
}


#pragma mark -
#pragma mark Rotation support


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


@end
