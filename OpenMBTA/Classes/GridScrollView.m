//
//  GridScrollView.m
//  OpenMBTA
//
//  Created by Daniel Choi on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GridScrollView.h"


@implementation GridScrollView



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { 
    UITouch *touch = [touches anyObject]; 
    CGPoint location = [touch locationInView:self];
    NSString *coord = NSStringFromCGPoint(location); 
    if(touch.tapCount == 1) { 
        NSLog(@"1 tap: %@", coord);
    } 
    if(touch.tapCount == 2) { 
        NSLog(@"2 taps: %@", coord);
    } 
    [super touchesEnded:touches withEvent:event];
} 


@end
