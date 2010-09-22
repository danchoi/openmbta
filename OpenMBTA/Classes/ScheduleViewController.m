//
//  ScheduleViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ServerUrl.h"

@implementation ScheduleViewController
@synthesize webView, request;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    self.webView = nil;
    self.request = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)loadWebViewWithTransportType:(NSString *)transportType routeShortName:(NSString *)routeShortName headsign:(NSString *)headsign firstStop:(NSString *)firstStop {
    // http://openmbta.org/trips.html?transport_type=bus&route_short_name=1&headsign=Dudley%20Station%20via%20Mass.%20Ave.&first_stop=
    // HTML grid
    NSString *urlString = [[NSString stringWithFormat:@"%@/trips.html?transport_type=%@&route_short_name=%@&headsign=%@&first_stop=%@&base_time=%@&from_iphone_app=1&version=3", ServerURL, 
                            transportType, routeShortName,headsign, firstStop,
                            [NSDate date]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // NSLog(@"calling %@", urlString);
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    self.request = [[NSURLRequest alloc] initWithURL: url]; 
    [url release];
    NSLog(@" loading webview: %@", webView);
    [webView loadRequest:self.request];        
}


@end
