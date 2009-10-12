//
//  TripViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TripViewController.h"

@implementation TripViewController
@synthesize trip_id, position;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // show the callouts for first stop    
    for (id annotation in mapView.annotations) {
        if (((StopAnnotation *)annotation).isFirstStop) {
            
            [mapView selectAnnotation:annotation animated:YES];
            break;
        }
    }
}

- (void)dealloc {
    self.trip_id = nil;
    self.position = nil;
    [super dealloc];
}


// This calls the server
- (void)startLoadingData
{
    [self showNetworkActivity];
    NSString *apiUrl = [NSString stringWithFormat:@"%@/trips/%@?from_position=%@", ServerURL, self.trip_id, self.position];
    NSLog(@"would call API with URL: %@", apiUrl);
    NSString *apiUrlEscaped = [apiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    GetRemoteDataOperation *operation = [[GetRemoteDataOperation alloc] initWithURL:apiUrlEscaped target:self action:@selector(didFinishLoadingData:)];
    [operationQueue addOperation:operation];
    [operation release];
}

// the rest of the methods are implemented by the superclass

@end
