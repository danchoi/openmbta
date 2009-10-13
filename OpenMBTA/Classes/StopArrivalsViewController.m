#import "StopArrivalsViewController.h"
#import "ServerUrl.h"
#import "GetRemoteDataOperation.h"
#import "JSON.h"
#import "TripViewController.h"

@interface StopArrivalsViewController (Private)
- (void)startLoadingData;
- (void)didFinishLoadingData:(NSString *)rawData;
@end


@implementation StopArrivalsViewController
@synthesize headsign, stop_id, route_short_name, stop_name, data, transportType;

- (void)viewDidLoad {
    [super viewDidLoad];
    operationQueue = [[NSOperationQueue alloc] init];    
    self.title = @"Remaining Trips";
}

- (void)viewWillAppear:(BOOL)animated
{
    self.data = nil;
    [tableView reloadData]; 
    [self startLoadingData];
    headsignLabel.text = self.headsign;
    stopNameLabel.text = [NSString stringWithFormat:@"From %@", self.stop_name];
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.headsign = nil;
    self.stop_id = nil;
    self.route_short_name = nil;
    self.data = nil;
    self.stop_name = nil;
    [operationQueue release];
    [tripViewController release];
    [super dealloc];
}

// This calls the server
- (void)startLoadingData
{
    [self showNetworkActivity];
    // the API call structure is /stops_arrivals?stop_id={x}&route_short_name={y}&headsign={z}
    
    NSString *headsignAmpersandEscaped = [self.headsign stringByReplacingOccurrencesOfString:@"&" withString:@"^"];

    NSString *apiUrl = [NSString stringWithFormat:@"%@/stop_arrivals?stop_id=%@&route_short_name=%@&headsign=%@&transport_type=%@", 
                            ServerURL, self.stop_id, self.route_short_name, headsignAmpersandEscaped, self.transportType];
    //NSLog(@"would call API with URL: %@", apiUrl);
    NSString *apiUrlEscaped = [apiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    [tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        
    }
    NSDictionary *stopping = [self.data objectAtIndex:indexPath.row];
    
    NSString *arrival_time = [stopping objectForKey:@"arrival_time"];
    NSString *more_stops = [stopping objectForKey:@"more_stops"];
    NSString *last_stop = [stopping objectForKey:@"last_stop"];    
    //NSString *trip_id = [stopping objectForKey:@"stop_id"];
	// Configure the cell.
    cell.textLabel.text = [NSString stringWithFormat:@"%@ to %@", arrival_time, last_stop];
    cell.detailTextLabel.text = more_stops;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{

    NSDictionary *stopping = [self.data objectAtIndex:indexPath.row];
    NSString *position = [stopping objectForKey:@"position"];    
    NSString *trip_id = [stopping objectForKey:@"trip_id"];    
    
    if (tripViewController == nil) {
        tripViewController = [[TripViewController alloc] initWithNibName:@"TripsMapViewController" bundle:nil];
    }
    tripViewController.trip_id = trip_id;
    tripViewController.position = position;
    tripViewController.headsign = self.headsign;
    tripViewController.route_short_name = self.route_short_name;
    tripViewController.stop_name = self.stop_name;
    tripViewController.shouldReloadRegion = YES;
    tripViewController.shouldReloadData = YES;
    [self.navigationController pushViewController:tripViewController animated:YES];
    
}

@end
