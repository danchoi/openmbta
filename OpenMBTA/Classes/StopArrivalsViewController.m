#import "StopArrivalsViewController.h"
#import "ServerUrl.h"
#import "GetRemoteDataOperation.h"
#import "JSON.h"

@interface StopArrivalsViewController (Private)
- (void)startLoadingData;
- (void)didFinishLoadingData:(NSString *)rawData;
@end


@implementation StopArrivalsViewController
@synthesize headsign, stop_id, route_short_name, data;

- (void)viewDidLoad {
    [super viewDidLoad];
    operationQueue = [[NSOperationQueue alloc] init];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startLoadingData];
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.headsign = nil;
    self.stop_id = nil;
    self.route_short_name = nil;
    [operationQueue release];
    [super dealloc];
}

// This calls the server
- (void)startLoadingData
{
    // the API call structure is /stops_arrivals?stop_id={x}&route_short_name={y}&headsign={z}

    NSString *headsignAmpersandEscaped = [self.headsign stringByReplacingOccurrencesOfString:@"&" withString:@"^"];

    NSString *apiUrl = [NSString stringWithFormat:@"%@/stop_arrivals?stop_id=%@&route_short_name=%@&headsign=%@", 
                            ServerURL, self.stop_id, self.route_short_name, headsignAmpersandEscaped];
    NSLog(@"would call API with URL: %@", apiUrl);
    NSString *apiUrlEscaped = [apiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    GetRemoteDataOperation *operation = [[GetRemoteDataOperation alloc] initWithURL:apiUrlEscaped target:self action:@selector(didFinishLoadingData:)];
    
    [operationQueue addOperation:operation];
    [operation release];
}

- (void)didFinishLoadingData:(NSString *)rawData 
{
    self.data = [rawData JSONValue];
    NSLog(@"loaded routes: %@", self.data);  
    [tableView reloadData];
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
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
    
    return cell;
}



@end
