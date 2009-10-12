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
@synthesize tableView, data, transportType;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.tableView.sectionIndexMinimumDisplayRowCount = 100;
    operationQueue = [[NSOperationQueue alloc] init];
    self.title = @"Routes";
}

- (void)viewWillAppear:(BOOL)animated {
    [self startLoadingData];    
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
    self.transportType = nil;
    [operationQueue release];
    [super dealloc];
}


// This calls the server
- (void)startLoadingData
{
    // Here is the structure of the API call:
    // curl "http://localhost:3000/routes?transport_type=bus
    // change this route later so it is page cacheable

    NSString *apiUrl = [NSString stringWithFormat:@"%@/routes?transport_type=%@", ServerURL, self.transportType];
    NSString *apiUrlEscaped = [apiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"would call API with URL: %@", apiUrlEscaped);
    
    GetRemoteDataOperation *operation = [[GetRemoteDataOperation alloc] initWithURL:apiUrlEscaped target:self action:@selector(didFinishLoadingData:)];
    
    [operationQueue addOperation:operation];
    [operation release];
}

- (void)didFinishLoadingData:(NSString *)rawData 
{
    self.data = [rawData JSONValue];
    //NSLog(@"loaded routes: %@", self.data);  
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
    
	// Configure the cell.

    NSDictionary *routeGroup = [self.data objectAtIndex:indexPath.section];
    NSArray *headsigns = [routeGroup objectForKey:@"headsigns"];
    NSArray *headsignArray = [headsigns objectAtIndex:indexPath.row];
    NSString *headsign = [headsignArray objectAtIndex:0];
    NSNumber *trips_remaining = [headsignArray objectAtIndex:1];
    cell.textLabel.text = headsign;
    NSString *pluralized = [trips_remaining intValue] > 1 ? @"trips" : @"trip";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ remaining", trips_remaining, pluralized];
    return cell;
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    NSDictionary *routeGroup = [self.data objectAtIndex:indexPath.section];
    NSString *routeShortName = [routeGroup objectForKey:@"route_short_name"];
    NSArray *headsigns = [routeGroup objectForKey:@"headsigns"];
    NSArray *headsignArray = [headsigns objectAtIndex:indexPath.row];
    NSString *headsign = [headsignArray objectAtIndex:0];
    
    [self tripsMapViewController].headsign = headsign;
    [self tripsMapViewController].route_short_name = routeShortName;
    [self tripsMapViewController].transportType = self.transportType;
    [self.navigationController pushViewController:[self tripsMapViewController] animated:YES];
    
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
