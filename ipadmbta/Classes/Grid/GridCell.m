//
//  GridCell.m
//  OpenMBTA
//
//  Created by Daniel Choi on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GridCell.h"


@implementation GridCell
@synthesize textLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {

    }
    return self;
}

- (void)dealloc {
    self.textLabel = nil;
    [super dealloc];
}


@end
