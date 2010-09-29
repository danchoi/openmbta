//
//  HelpViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"


@interface HelpViewController (Private)

@end

@implementation HelpViewController
@synthesize viewName, transportType, webView, request, progressView;

- (void)viewDidLoad {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProgressView" owner:self options:nil];
    
    NSEnumerator *enumerator = [nib objectEnumerator];
    id object;
    
    while ((object = [enumerator nextObject])) {
        if ([object isMemberOfClass:[UIView class]]) {
            self.progressView =  (UIView *)object;
        }
    }    
    
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    [self loadWebView];
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.viewName = nil;
    self.transportType = nil;
    self.webView = nil;
    self.request = nil;
    self.progressView = nil;
    [super dealloc];
}

- (void)loadWebView {
    NSString *urlString = [NSString stringWithFormat:@"%@/help/%@/%@?version=3", ServerURL, self.viewName, self.transportType];
    NSString *urlStringEscaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    
    NSURL *url = [[NSURL alloc] initWithString: urlStringEscaped];
    self.request = [[NSURLRequest alloc] initWithURL: url]; 
    [url release];
    [self showLoadingIndicators];
    [self.webView loadRequest:self.request];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [aRequest URL];
    NSString *absoluteURL = [url absoluteString];
    if ([absoluteURL rangeOfString:ServerURL].location == NSNotFound) {   
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

// loading indicator


- (void)showLoadingIndicators {
    self.progressView.center = CGPointMake(160, 182);
    [self.view addSubview:progressView];
}

- (void)hideLoadingIndicators
{
    [self.progressView removeFromSuperview];    
}


#pragma mark -
#pragma mark Rotation support


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
