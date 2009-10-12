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
    [self addHelpButton];
    [super viewDidLoad];
}

- (void)addHelpButton {
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] 
        initWithTitle:@"Help"
                style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(showHelp:)];
   self.navigationItem.rightBarButtonItem = helpButton;
}

- (void)showHelp:(id)sender {
    // send back the controller name so we can show the right view
    // NSLog(@"show help class: %@", [[self class] description]);
    if (helpViewController == nil) {
        helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    }
    helpViewController.targetControllerName = [[self class] description];
    [self presentModalViewController:helpViewController animated:YES];
}

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
