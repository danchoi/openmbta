//
//  StopsViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopsViewController.h"
#import "TripsViewController.h"

@implementation StopsViewController
@synthesize orderedStopNames, tableView, tripsViewController, selectedStopName;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
    self.tripsViewController = nil;
    self.orderedStopNames = nil;
    [super dealloc];
}

- (void)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)loadStopNames:(NSMutableArray *)stopNames {
    self.orderedStopNames = stopNames;
    [self.tableView reloadData];
}


- (void)selectStopNamed:(NSString *)stopName {
    self.selectedStopName = stopName;
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
    [self dismissModalViewControllerAnimated:YES];
    [self.tripsViewController highlightStopNamed:stopName];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36.0;
}

@end
