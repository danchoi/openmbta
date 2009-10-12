//
//  BaseViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"


@implementation BaseViewController

- (void)showNetworkActivity {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;    
}

- (void)hideNetworkActivity {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)dealloc {
    [super dealloc];
}


@end
