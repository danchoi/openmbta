//
//  BaseViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"


@implementation BaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)showNetworkActivity {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;    
}

- (void)hideNetworkActivity {
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


@end
