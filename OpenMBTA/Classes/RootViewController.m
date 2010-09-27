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
@synthesize menu,  menu2, bookmarks, tableView, tripsViewController;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.menu = [[NSArray alloc] initWithObjects:@"Bus", @"Commuter Rail", @"Subway", @"Boat", nil];
    self.menu2 = [[NSArray alloc] initWithObjects:@"T Alerts", @"Tweets #mbta", @"About / FAQ", nil];

    self.title = @"Main Menu";

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
    self.menu2 = nil;
    self.bookmarks = nil;
    self.tableView = nil;
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return [self.menu count];
    } else if (section == 2) {
        return [self.menu2 count];
    } else {
        return ([self.bookmarks count] > 0 ? [self.bookmarks count] : 1);        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
    if (sectionIndex == 1) {
        return @"Modes of Transport";
    } else if (sectionIndex == 2) {
        return @"Extras";
    } else {
        return @"Bookmarks";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 || indexPath.section == 2) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell.

        NSString *menuChoice;
        if (indexPath.section == 1) 
            menuChoice = [self.menu objectAtIndex:indexPath.row];
        else
            menuChoice = [self.menu2 objectAtIndex:indexPath.row];
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
        
        if (routesViewController == nil) {
            routesViewController = [[RoutesViewController alloc] initWithNibName:@"RoutesViewController" bundle:nil];
        }
        
        NSString *menuChoice = [self.menu objectAtIndex:indexPath.row];
        routesViewController.transportType = menuChoice;
        routesViewController.shouldReloadData = YES;
        [routesViewController reset];
        [self.navigationController pushViewController:routesViewController animated:YES];

    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) { 
            if (tAlertsViewController == nil) {
                tAlertsViewController = [[TAlertsViewController alloc] initWithNibName:@"TAlertsViewController" bundle:nil];
            }
            [self.navigationController pushViewController:tAlertsViewController animated:YES];
            return;
        }
        if (indexPath.row == 1) { 
            if (tweetsViewController == nil) {
                tweetsViewController = [[TweetsViewController alloc] initWithNibName:@"TAlertsViewController" bundle:nil];
            }
            [self.navigationController pushViewController:tweetsViewController animated:YES];
            return;
        }
        
        if (indexPath.row == 2) { 
            AboutViewController *vc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            return;
        }
        
        
        
        
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

- (void)loadLastViewedTrip {
    NSDictionary *lastViewedTrip = [[NSUserDefaults standardUserDefaults]
                                    objectForKey:@"lastViewedTrip"];
    if (lastViewedTrip) {
        self.tripsViewController.headsign = [lastViewedTrip objectForKey:@"headsign"];
        self.tripsViewController.route_short_name = [lastViewedTrip objectForKey:@"routeShortName"];
        self.tripsViewController.transportType = [lastViewedTrip objectForKey:@"transportType"];;
        self.tripsViewController.firstStop = [lastViewedTrip objectForKey:@";firstStop"];
        self.tripsViewController.startOnSegementIndex = [[lastViewedTrip objectForKey:@"selectedSegmentIndex"] intValue];        
        self.tripsViewController.shouldReloadRegion = YES;
        self.tripsViewController.shouldReloadData = YES;

        [self.navigationController pushViewController:self.tripsViewController animated:YES];
    }   
}


@end

