//
//  HelpViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"
#import "ServerUrl.h"

@interface HelpViewController (Private)
- (void)showLoadingIndicators;
- (void)hideLoadingIndicators;

@end

@implementation HelpViewController
@synthesize targetControllerName, webView, request;

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {

    NSString *urlString = [NSString stringWithFormat:@"%@/help/%@", ServerURL, self.targetControllerName];
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    self.request = [[NSURLRequest alloc] initWithURL: url]; 
    [self showLoadingIndicators];
    [self.webView loadRequest:self.request];


    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.targetControllerName = nil;
    self.webView = nil;
    self.request = nil;
    [spinner release];
    [loadingLabel release];
    [super dealloc];
}


- (IBAction)doneButtonPressed:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [aRequest URL];
    NSString *absoluteURL = [url absoluteString];
    if ([absoluteURL rangeOfString:@"http://mbta.com"].location != NSNotFound) {   
        if (![[UIApplication sharedApplication] openURL:url])
            NSLog(@"%@%@",@"Failed to open url:",[url description]);
        return NO;
    }
    return YES;
}


- (IBAction)launchSafari:(id)sender {
    NSURL *launchURL = [self.webView.request URL];
    if (![[UIApplication sharedApplication] openURL:launchURL])
        NSLog(@"%@%@",@"Failed to open url:",[launchURL description]);
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideLoadingIndicators];


}

- (void)showLoadingIndicators {
    if (!spinner) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loadingLabel.font = [UIFont systemFontOfSize:18];
        loadingLabel.textColor = [UIColor grayColor];
        loadingLabel.text = @"Loading...";
        [loadingLabel sizeToFit];
        
        static CGFloat bufferWidth = 8.0;
        
        CGFloat totalWidth = spinner.frame.size.width + bufferWidth + loadingLabel.frame.size.width;
        
        CGRect spinnerFrame = spinner.frame;
        spinnerFrame.origin.x = (self.view.bounds.size.width - totalWidth) / 2.0;
        spinnerFrame.origin.y = ((self.view.bounds.size.height - spinnerFrame.size.height) / 2.0) - 20;
        spinner.frame = spinnerFrame;
        [self.view addSubview:spinner];
        
        CGRect labelFrame = loadingLabel.frame;
        labelFrame.origin.x = (self.view.bounds.size.width - totalWidth) / 2.0 + spinnerFrame.size.width + bufferWidth;
        labelFrame.origin.y = ((self.view.bounds.size.height - labelFrame.size.height) / 2.0) - 20;
        loadingLabel.frame = labelFrame;
        [self.view addSubview:loadingLabel];
    }
}

- (void)hideLoadingIndicators
{
    if (spinner) {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        [spinner release];
        spinner = nil;
        
        [loadingLabel removeFromSuperview];
        [loadingLabel release];
        loadingLabel = nil;
    }
}


@end
