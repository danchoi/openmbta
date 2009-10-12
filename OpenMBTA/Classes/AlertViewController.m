//
//  AlertViewController.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AlertViewController.h"


@implementation AlertViewController
@synthesize alertTitle, pubDate, description;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"T Alert";
}

- (void)viewWillAppear:(BOOL)animated {
    titleLabel.text = alertTitle;
    pubDateLabel.text = pubDate;
    descriptionTextView.text = description;
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.alertTitle = nil;
    self.pubDate= nil;
    self.description = nil;    
    [super dealloc];
}


@end
