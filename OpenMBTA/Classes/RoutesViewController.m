#import "RoutesViewController.h"
#import "JSON.h"
#import "GetRemoteDataOperation.h"
#import "ServerUrl.h"

@interface RoutesViewController (Private)
- (TripsMapViewController *)tripsMapViewController;
- (void)startLoadingData;
- (void)didFinishLoadingData:(NSString *)rawData;
@end

@implementation RoutesViewController
@synthesize tableView, data, transportType, lineName, lineHeadsign, shouldReloadData;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.tableView.sectionIndexMinimumDisplayRowCount = 100;
    operationQueue = [[NSOperationQueue alloc] init];

    shouldReloadData = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.shouldReloadData) {
        self.data = nil;
        [self.tableView reloadData];
        [self startLoadingData];    
        self.shouldReloadData = NO;
    }
    if (self.lineName) {
        self.title = @"CR Trains";
    } else {
        self.title = ([self.transportType isEqualToString:@"Commuter Rail"] ? @"CR Lines" : [NSString stringWithFormat:@"%@ Routes", self.transportType]);
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)reset {
    self.data = nil;
    [self.tableView reloadData];
}

- (void)dealloc {
    self.tableView = nil;
    self.data = nil;
    self.lineName = nil;
    self.lineHeadsign = nil;    
    self.transportType = nil;
    [operationQueue release];
    [super dealloc];
}


// This calls the server
- (void)startLoadingData
{
    [self showNetworkActivity];
    NSString *apiUrl;
    if (self.lineName == nil && self.lineHeadsign == nil) { // normal case
        apiUrl = [NSString stringWithFormat:@"%@/routes/%@", ServerURL, self.transportType];
    } else {
        apiUrl = [NSString stringWithFormat:@"%@/trains?line_name=%@&line_headsign=%@", ServerURL, self.lineName, self.lineHeadsign];        
    }
        
    NSString *apiUrlEscaped = [apiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    //NSLog(@"would call API with URL: %@", apiUrlEscaped);
    
    GetRemoteDataOperation *operation = [[GetRemoteDataOperation alloc] initWithURL:apiUrlEscaped target:self action:@selector(didFinishLoadingData:)];
    
    [operationQueue addOperation:operation];
    [operation release];
}

- (void)didFinishLoadingData:(NSString *)rawData 
{
    [self hideNetworkActivity];
    NSDictionary *rawDict = [rawData JSONValue];
    self.data = [rawDict objectForKey:@"data"];
    [self checkForMessage:rawDict];
    [self.tableView reloadData];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.data count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    for (NSDictionary *section in self.data) {
        [sectionTitles addObject:[section objectForKey:@"route_short_name"]];
    }
    return sectionTitles;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    NSDictionary *section = [self.data objectAtIndex:sectionIndex];
    NSArray *headsigns = [section objectForKey:@"headsigns"];
    return [headsigns count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex
{
    NSDictionary *section = [self.data objectAtIndex:sectionIndex];
    NSString *routeShortName = [section objectForKey:@"route_short_name"];
    return routeShortName;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];

    }
    if ([self.transportType isEqualToString:@"Bus"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;       // because there's an index bar 
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
    }
	// Configure the cell.

    NSDictionary *routeGroup = [self.data objectAtIndex:indexPath.section];
    NSArray *headsigns = [routeGroup objectForKey:@"headsigns"];
    NSArray *headsignArray = [headsigns objectAtIndex:indexPath.row];
    NSString *headsign = [headsignArray objectAtIndex:0];

    cell.textLabel.text = headsign;
    if (self.lineName && self.lineHeadsign) {
        cell.detailTextLabel.text = [headsignArray objectAtIndex:1];
    } else {
        NSNumber *trips_remaining = [headsignArray objectAtIndex:1];
        NSString *pluralized = [trips_remaining intValue] > 1 ? @"trips" : @"trip";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ more %@ today", trips_remaining, pluralized];
    }
    return cell;
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    NSDictionary *routeGroup = [self.data objectAtIndex:indexPath.section];
    NSString *routeShortName = [routeGroup objectForKey:@"route_short_name"];
    NSArray *headsigns = [routeGroup objectForKey:@"headsigns"];
    NSArray *headsignArray = [headsigns objectAtIndex:indexPath.row];
    NSString *headsign = [headsignArray objectAtIndex:0];
    
    if ([self.transportType isEqualToString:@"Commuter Rail"] && self.lineName == nil) {
        RoutesViewController *routesViewController = [[RoutesViewController alloc] initWithNibName:@"RoutesViewController" bundle:nil];
        
        routesViewController.transportType = @"Commuter Rail";
        routesViewController.lineName = routeShortName;
        routesViewController.lineHeadsign = headsign;
        routesViewController.shouldReloadData = YES;
        [routesViewController reset];
        
        [self.navigationController pushViewController:routesViewController animated:YES];        
        [routesViewController release];
    } else { 
        [self tripsMapViewController].headsign = headsign;
        [self tripsMapViewController].route_short_name = routeShortName;
        [self tripsMapViewController].transportType = self.transportType;
        [self tripsMapViewController].shouldReloadRegion = YES;
        [self tripsMapViewController].shouldReloadData = YES;
        [[self tripsMapViewController] resetBaseTime];
        [self.navigationController pushViewController:[self tripsMapViewController] animated:YES];
    }
    
 // Navigation logic may go here -- for example, create and push another view controller.
 // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
 // [self.navigationController pushViewController:anotherViewController animated:YES];
 // [anotherViewController release];
}

- (TripsMapViewController *)tripsMapViewController {
    if (tripsMapViewController == nil) {
        tripsMapViewController = [[TripsMapViewController alloc] initWithNibName:@"TripsMapViewController" bundle:nil];
    }
    return tripsMapViewController;
}

@end
