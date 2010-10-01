//
//  AboutViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TweetsViewController.h"

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tweets #mbta";

    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]
            initWithTitle:@"Refresh"
                    style:UIBarButtonItemStyleBordered
                   target:self
                   action:@selector(reloadWebView:)];
    self.navigationItem.rightBarButtonItem = reloadButton;
}

- (void)loadWebView {
    NSString *urlString = [NSString stringWithFormat:@"%@/tweets?from_iphone_app=1", ServerURL];
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
