//
//  TimePickerViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TimePickerViewController.h"

@implementation TimePickerViewController
@synthesize timePicker;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    timePicker.date = [NSDate date];
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [timePicker release];
    [super dealloc];
}

- (IBAction)doneButtonPressed:(id)sender {
    NSDate *selected = [timePicker date];
    NSTimeInterval intervalFromNow = fabs([selected timeIntervalSinceDate:[NSDate date]]);
    
    // If the done button is pressed and the user didn't change the time, don't shift the time
    if (intervalFromNow > (2 * 60)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BaseTimeChanged"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:selected forKey:@"NewBaseTime"]];
    }
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)resetButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BaseTimeChanged"
                                                        object:self
                                                      userInfo:nil];    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}


@end
