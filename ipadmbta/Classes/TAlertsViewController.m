//
//  AboutViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TAlertsViewController.h"

@implementation TAlertsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"T-Alerts";


    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]
            initWithTitle:@"Reload"
                    style:UIBarButtonItemStyleBordered
                   target:self
                   action:@selector(reloadWebView:)];
    self.navigationItem.rightBarButtonItem = reloadButton;
}

- (void)loadWebView {
    NSString *urlString = [NSString stringWithFormat:@"%@/alerts?from_iphone_app=1", ServerURL];
    //NSLog(@"calling %@", urlString);
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    self.request = [[NSURLRequest alloc] initWithURL: url]; 
    [url release];
    [self showLoadingIndicators];
    [self.webView loadRequest:self.request];    
}
- (void)reloadWebView:(id)sender {
    NSLog(@"reload web");
    [self.webView reload];
}

- (void)dealloc {
    [super dealloc];
}


@end
