#import "RootViewController.h"
#import "JSON.h"
#import "TripsMapViewController.h"
#import "RoutesViewController.h"
#import "GetRemoteDataOperation.h"
#import "ServerUrl.h"

@interface RootViewController (Private)
- (TripsMapViewController *)tripsMapViewController;
- (RoutesViewController *)routesViewController;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.navigationController pushViewController:[self tripsMapViewController] animated:YES];
    [self.navigationController pushViewController:[self routesViewController] animated:YES];
}


- (TripsMapViewController *)tripsMapViewController {
    if (tripsMapViewController == nil) {
        tripsMapViewController = [[TripsMapViewController alloc] initWithNibName:@"TripMapsViewController" bundle:nil];
    }
    return tripsMapViewController;
}

- (RoutesViewController *)routesViewController 
{
    if (routesViewController == nil) {
        routesViewController = [[RoutesViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    return routesViewController;
    
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.

    return cell;
}



/*
// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

