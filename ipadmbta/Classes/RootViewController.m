//
//  RootViewController.m
//  ipadmbta
//
//  Created by Daniel Choi on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "RootViewController.h"
#import "JSON.h"
#import "RoutesViewController.h"
#import "TAlertsViewController.h"
#import "GetRemoteDataOperation.h"
#import "TweetsViewController.h"
#import "AboutViewController.h"
#import "Preferences.h"

@implementation RootViewController

@synthesize detailViewController, stopsVC;
@synthesize menu,  menu2, bookmarks;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    
    self.menu = [[NSArray alloc] initWithObjects:@"Bus", @"Commuter Rail", @"Subway", @"Boat", nil];
    self.menu2 = [[NSArray alloc] initWithObjects:@"T Alerts", @"Tweets #mbta", nil];
    
    self.title = @"Main Menu";
    
    self.stopsVC = [[StopsViewController alloc] initWithNibName:@"StopsViewController" bundle:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.bookmarks = [[Preferences sharedInstance] orderedBookmarks]; 
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/



// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
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



- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 || indexPath.section == 2) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
        
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
        NSString *firstStop =  [bookmark objectForKey:@"firstStop"];
        // Configure the cell.
        
        cell.textLabel.text = headsign;
        if ([transportType isEqualToString:@"Bus"])
            cell.detailTextLabel.text  = [NSString stringWithFormat:@"%@ %@", transportType, routeShortName];

        else if (firstStop)
            cell.detailTextLabel.text  = [NSString stringWithFormat:@"%@ : %@", routeShortName, firstStop];

        else
            cell.detailTextLabel.text  = [NSString stringWithFormat:@"%@ : %@", transportType, routeShortName];
        
        return cell;
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

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
        
        
    } else {
        if (indexPath.row < [self.bookmarks count]) {
            NSDictionary *bookmark = [self.bookmarks objectAtIndex: indexPath.row];
            NSString *transportType = [bookmark objectForKey:@"transportType"];
            NSString *headsign  = [bookmark objectForKey:@"headsign"];
            NSString *routeShortName  = [bookmark objectForKey:@"routeShortName"];
            NSString *firstStop  = [bookmark objectForKey:@"firstStop"];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"shouldReloadMapRegion", transportType, @"transportType", routeShortName, @"routeShortName", headsign, @"headsign", firstStop, @"firstStop", nil];
            NSNotification *notification = [NSNotification notificationWithName:@"loadMBTATrips"  object:nil userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            [self.navigationController pushViewController:self.stopsVC animated:YES];
        }
    }
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [detailViewController release];
    [routesViewController release];
    [tAlertsViewController release];
    self.menu = nil;
    self.menu2 = nil;
    self.bookmarks = nil;
    self.tableView = nil;   
    self.stopsVC = nil;
    [super dealloc];
}

# pragma mark -
# pragma Restore Application State

- (void)loadLastViewedTrip {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *lastViewedTrip = [userDefaults objectForKey:@"lastViewedTrip"];
    if (![lastViewedTrip isEqual:[NSNull null]] ) {
        NSString *headsign = [lastViewedTrip objectForKey:@"headsign"];
        NSString *routeShortName = [lastViewedTrip objectForKey:@"routeShortName"];
        NSString *transportType = [lastViewedTrip objectForKey:@"transportType"];;
        NSString *firstStop = [lastViewedTrip objectForKey:@"firstStop"];
        NSNumber *startOnSegmentIndex = [lastViewedTrip objectForKey:@"selectedSegmentIndex"];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"shouldReloadMapRegion", transportType, @"transportType", routeShortName, @"routeShortName", headsign, @"headsign", startOnSegmentIndex, @"startOnSegmentIndex", firstStop, @"firstStop", nil];
        NSNotification *notification = [NSNotification notificationWithName:@"loadMBTATrips"  object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController pushViewController:self.stopsVC animated:YES];
    }   
}





@end

