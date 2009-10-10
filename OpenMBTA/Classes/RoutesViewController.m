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
@synthesize data;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    operationQueue = [[NSOperationQueue alloc] init];
    [self startLoadingData];
}

- (void)dealloc {
    self.data = nil;
    [operationQueue release];
    [super dealloc];
}


// This calls the server
- (void)startLoadingData
{
    // Here is the structure of the API call:
    // curl "http://localhost:3000/routes?transport_type=bus
    // change this route later so it is page cacheable

    NSString *apiUrl = [NSString stringWithFormat:@"%@/routes?transport_type=bus", ServerURL];
    NSLog(@"would call API with URL: %@", apiUrl);
    
    GetRemoteDataOperation *operation = [[GetRemoteDataOperation alloc] initWithURL:apiUrl target:self action:@selector(didFinishLoadingData:)];
    
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
    }
    
	// Configure the cell.
    NSUInteger sectionIndex = indexPath.section;
    NSUInteger rowIndex = indexPath.row;
    NSDictionary *routeGroup = [self.data objectAtIndex:sectionIndex];
    NSArray *headsigns = [routeGroup objectForKey:@"headsigns"];
    NSString *headsign = [headsigns objectAtIndex:rowIndex];
    cell.textLabel.text = headsign;
    return cell;
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    NSDictionary *routeGroup = [self.data objectAtIndex:indexPath.section];
    NSString *routeShortName = [routeGroup objectForKey:@"route_short_name"];
    NSArray *headsigns = [routeGroup objectForKey:@"headsigns"];
    NSString *headsign = [headsigns objectAtIndex:indexPath.row];
    
    [self tripsMapViewController].headsign = headsign;
    [self tripsMapViewController].route_short_name = routeShortName;
    [self.navigationController pushViewController:[self tripsMapViewController] animated:YES];
    
 // Navigation logic may go here -- for example, create and push another view controller.
 // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
 // [self.navigationController pushViewController:anotherViewController animated:YES];
 // [anotherViewController release];
}

- (TripsMapViewController *)tripsMapViewController {
    if (tripsMapViewController == nil) {
        tripsMapViewController = [[TripsMapViewController alloc] initWithNibName:@"TripMapsViewController" bundle:nil];
    }
    return tripsMapViewController;
}

@end
