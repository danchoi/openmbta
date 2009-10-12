#import "RootViewController.h"
#import "JSON.h"
#import "RoutesViewController.h"
#import "TAlertsViewController.h"
#import "GetRemoteDataOperation.h"
#import "ServerUrl.h"

@interface RootViewController (Private)

@end

@implementation RootViewController
@synthesize menu;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menu = [[NSArray alloc] initWithObjects:@"Bus", @"Commuter Rail", @"Subway", @"Boat", @"T Alerts", nil];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.navigationController pushViewController:[self tripsMapViewController] animated:YES];
    //[self.navigationController pushViewController:[self routesViewController] animated:YES];
}

- (void)dealloc {
    [routesViewController release];
    [tAlertsViewController release];
    self.menu = nil;
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menu count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.

    NSString *menuChoice = [self.menu objectAtIndex:indexPath.row];
    cell.textLabel.text = menuChoice;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 4) { 
        if (tAlertsViewController == nil) {
            tAlertsViewController = [[TAlertsViewController alloc] initWithStyle:UITableViewStylePlain];
        }
        [self.navigationController pushViewController:tAlertsViewController animated:YES];
        return;
    }
    
    if (routesViewController == nil) {
        routesViewController = [[RoutesViewController alloc] initWithNibName:@"RoutesViewController" bundle:nil];
    }
    
    NSString *menuChoice = [self.menu objectAtIndex:indexPath.row];
    routesViewController.transportType = menuChoice;
    routesViewController.shouldReloadData = YES;
    [routesViewController reset];
  	[self.navigationController pushViewController:routesViewController animated:YES];
}



@end

