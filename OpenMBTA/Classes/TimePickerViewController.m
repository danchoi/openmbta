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
    //NSLog(@"selected time: %@", selected);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BaseTimeChanged"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:selected forKey:@"NewBaseTime"]];
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

@end
