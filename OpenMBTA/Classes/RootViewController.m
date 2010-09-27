#import "RootViewController.h"
#import "JSON.h"
#import "RoutesViewController.h"
#import "TAlertsViewController.h"
#import "GetRemoteDataOperation.h"
#import "TweetsViewController.h"
#import "AboutViewController.h"
#import "Preferences.h"

@interface RootViewController (Private)
- (TripsViewController *)tripsMapViewController;

@end

@implementation RootViewController
@synthesize menu, bookmarks, tableView, tripsViewController;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.menu = [[NSArray alloc] initWithObjects:@"Bus", @"Commuter Rail", @"Subway", @"Boat", @"T Alerts", @"Tweets #mbta", @"About / FAQ", nil];
    self.title = @"Main";

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bookmarks = [[Preferences sharedInstance] orderedBookmarks]; 
    [tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.navigationController pushViewController:[self tripsMapViewController] animated:YES];
    //[self.navigationController pushViewController:[self routesViewController] animated:YES];
}

- (void)dealloc {
    [routesViewController release];
    [tAlertsViewController release];
    self.tripsViewController = nil;
    self.menu = nil;
    self.bookmarks = nil;
    self.tableView = nil;
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return [self.menu count];
    } else {
        return ([self.bookmarks count] > 0 ? [self.bookmarks count] : 1);

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
    if (sectionIndex == 1) {
        return @"Main Menu";
    } else {
        return @"Bookmarks";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell.

        NSString *menuChoice = [self.menu objectAtIndex:indexPath.row];
        cell.textLabel.text = menuChoice;
        return cell;  
        
    } else {
        
        static NSString *CellIdentifier = @"BookmarkCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];

        }
        
        if ([self.bookmarks count] == 0) {
            cell.textLabel.text = @"No bookmarks";
            cell.detailTextLabel.text = @"You can bookmark your regular routes";
            return cell;
        }            
        
        NSDictionary *bookmark = [self.bookmarks objectAtIndex:indexPath.row];
        NSString *transportType = [bookmark objectForKey:@"transportType"];
            
        NSString *headsign  = [bookmark objectForKey:@"headsign"];
        NSString *routeShortName  = [bookmark objectForKey:@"routeShortName"];

        // Configure the cell.

        cell.textLabel.text = headsign;
        if ([transportType isEqualToString:@"Bus"])
            cell.detailTextLabel.text  = [NSString stringWithFormat:@"%@ %@", transportType, routeShortName];
        else
            cell.detailTextLabel.text  = [NSString stringWithFormat:@"%@ : %@", transportType, routeShortName];

        return cell;
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        if (indexPath.row == 4) { 
            if (tAlertsViewController == nil) {
                tAlertsViewController = [[TAlertsViewController alloc] initWithNibName:@"TAlertsViewController" bundle:nil];
            }
            [self.navigationController pushViewController:tAlertsViewController animated:YES];
            return;
        }
        if (indexPath.row == 5) { 
            if (tweetsViewController == nil) {
                tweetsViewController = [[TweetsViewController alloc] initWithNibName:@"TAlertsViewController" bundle:nil];
            }
            [self.navigationController pushViewController:tweetsViewController animated:YES];
            return;
        }
        
        if (indexPath.row == 6) { 
            AboutViewController *vc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
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

    } else {
        NSDictionary *bookmark = [self.bookmarks objectAtIndex: indexPath.row];
        NSString *transportType = [bookmark objectForKey:@"transportType"];
        NSString *headsign  = [bookmark objectForKey:@"headsign"];
        NSString *routeShortName  = [bookmark objectForKey:@"routeShortName"];
        NSString *firstStop  = [bookmark objectForKey:@"firstStop"];

        [self tripsViewController].headsign = headsign;
        [self tripsViewController].route_short_name = routeShortName;
        [self tripsViewController].transportType = transportType;
        [self tripsViewController].firstStop = firstStop;
        [self tripsViewController].shouldReloadRegion = YES;
        [self tripsViewController].shouldReloadData = YES;

        [self.navigationController pushViewController:[self tripsViewController] animated:YES];

     
    }
}

- (TripsViewController *)tripsViewController {
    if (tripsViewController == nil) {
        tripsViewController = [[TripsViewController alloc] initWithNibName:@"TripsViewController" bundle:nil];
    }
    return tripsViewController;
}



@end

