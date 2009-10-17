//
//  DemoCurrentLocation.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DemoCurrentLocation.h"


@implementation DemoCurrentLocation

@synthesize coordinate, title, subtitle;

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

-(void)dealloc
{
    [title release];
    [subtitle release];
    [super dealloc];
}
@end

