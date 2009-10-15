//
//  AlertViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AlertViewController.h"


@implementation AlertViewController
@synthesize alertGUID;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"T Alert";
}

- (void)dealloc {
    self.alertGUID = nil;
    [super dealloc];
}

- (void)loadWebView {
    NSString *urlString = [NSString stringWithFormat:@"%@/alerts/%@", ServerURL, self.alertGUID];
    // NSLog(@"calling %@", urlString);
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    self.request = [[NSURLRequest alloc] initWithURL: url]; 
    [url release];
    [self showLoadingIndicators];
    [self.webView loadRequest:self.request];    
}


@end
