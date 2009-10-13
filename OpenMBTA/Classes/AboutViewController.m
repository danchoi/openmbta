//
//  AboutViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "ServerUrl.h"

@implementation AboutViewController

- (void)loadWebView {
    NSString *urlString = [NSString stringWithFormat:@"%@/about", ServerURL];
    NSLog(@"calling %@", urlString);
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    self.request = [[NSURLRequest alloc] initWithURL: url]; 
    [self showLoadingIndicators];
    [self.webView loadRequest:self.request];    
}

- (void)dealloc {
    [super dealloc];
}


@end
