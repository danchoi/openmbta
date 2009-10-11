//
//  TripViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TripViewController.h"
#import "ServerUrl.h"
#import "GetRemoteDataOperation.h"
#import "JSON.h"

@interface TripViewController (Private)
- (void)startLoadingData;
- (void)didFinishLoadingData:(NSString *)rawData;
@end 

@implementation TripViewController
@synthesize trip_id, position, data;

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
    self.trip_id = nil;
    self.position = nil;
    self.data = nil;
    [tableView release];
    [operationQueue release];
    
    [super dealloc];
}


// This calls the server
- (void)startLoadingData
{
    NSString *apiUrl = [NSString stringWithFormat:@"%@/trips/%@?from_position=%@", ServerURL, self.trip_id, self.position];
    NSLog(@"would call API with URL: %@", apiUrl);
    NSString *apiUrlEscaped = [apiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    GetRemoteDataOperation *operation = [[GetRemoteDataOperation alloc] initWithURL:apiUrlEscaped target:self action:@selector(didFinishLoadingData:)];
    [operationQueue addOperation:operation];
    [operation release];
}

- (void)didFinishLoadingData:(NSString *)rawData 
{
    self.data = [rawData JSONValue];
    NSLog(@"loaded %d stoppings", [self.data count]);  
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *stopping = [self.data objectAtIndex:indexPath.row];
    
    NSString *arrival_time = [stopping objectForKey:@"arrival_time"];
    NSString *stop_name = [stopping objectForKey:@"stop_name"];

	// Configure the cell.
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ more stops", arrival_time, stop_name];
    return cell;
}


@end
