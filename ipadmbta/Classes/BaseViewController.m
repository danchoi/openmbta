//
//  BaseViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController (Private)
- (void)showLoadingIndicators;
- (void)hideLoadingIndicators;

@end

@implementation BaseViewController
@synthesize progressView;

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

- (void)showNetworkActivity {
    [self showLoadingIndicators];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;    
}

- (void)hideNetworkActivity {
    [self hideLoadingIndicators];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)checkForMessage:(NSDictionary *)someData {
    if ([someData objectForKey:@"message"] != nil) {
        NSDictionary *message = [someData objectForKey:@"message"];
        NSString *title = [message objectForKey:@"title"];
        NSString *body = [message objectForKey:@"body"];        
        [self alertMessageTitle:title message:body];
    } 
}

- (void)alertMessageTitle:(NSString *)title message:(NSString *)message {
        UIAlertView *alert = [[UIAlertView alloc] 
            initWithTitle:title
                  message:message
                 delegate:nil 
        cancelButtonTitle:@"OK" 
        otherButtonTitles:nil]; 
        [alert show]; 
        [alert release];
}

- (void)dealloc {
    [super dealloc];
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
