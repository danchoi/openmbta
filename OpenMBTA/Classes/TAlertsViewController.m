//
//  TAlertsViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TAlertsViewController.h"
#import "ServerUrl.h"
#import "JSON.h"
#import "GetRemoteDataOperation.h"
#import "AlertViewController.h"

@interface TAlertsViewController (Private)
- (void)startLoadingData;
- (void)didFinishLoadingData:(NSString *)rawData;
@end

@implementation TAlertsViewController
@synthesize alerts, data;

- (void)viewDidLoad {
    [super viewDidLoad];
    operationQueue = [[NSOperationQueue alloc] init];
    self.title = @"T Alerts";

}

- (void)viewWillAppear:(BOOL)animated {
    self.data = nil;
    [self.tableView reloadData]; 
    [self startLoadingData];
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.alerts = nil;
    [operationQueue release];
    [super dealloc];
}


// This calls the server
- (void)startLoadingData
{    
    NSString *apiUrl = [NSString stringWithFormat:@"%@/alerts", ServerURL];
    GetRemoteDataOperation *operation = [[GetRemoteDataOperation alloc] initWithURL:apiUrl target:self action:@selector(didFinishLoadingData:)];
    [operationQueue addOperation:operation];
    [operation release];
}

- (void)didFinishLoadingData:(NSString *)rawData 
{
    self.data = [rawData JSONValue];
    NSLog(@"loaded alerts: %d", [self.data count]);  
    [self.tableView reloadData];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    // Set up the cell...
    NSDictionary *alert = [[self.data objectAtIndex:indexPath.row] objectForKey:@"alert"];
    // NSLog(@"alert: %@", alert);
    cell.textLabel.text = [alert objectForKey:@"title"];
    cell.detailTextLabel.text = [alert objectForKey:@"pub_date"];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *alert = [[self.data objectAtIndex:indexPath.row] objectForKey:@"alert"];
    NSLog(@"alert: %@", alert);
    AlertViewController *alertViewController = [[AlertViewController alloc] initWithNibName:@"AlertViewController" bundle: nil];
    
    alertViewController.alertTitle = [alert objectForKey:@"title"];
    alertViewController.pubDate = [alert objectForKey:@"pub_date"];    
    alertViewController.description = [alert objectForKey:@"description"];
    [self.navigationController pushViewController:alertViewController animated:YES];
	[alertViewController release];
}

@end

