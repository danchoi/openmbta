//
//  CoveringScrollView.m
//  OpenMBTA
//
//  Created by Daniel Choi on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "CoveringScrollView.h"


@implementation CoveringScrollView


- (void)dealloc {
    [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { 
    UITouch *touch = [touches anyObject]; 
    CGPoint location = [touch locationInView:self];
    float y = location.y; 
    float x = location.x;
    if(touch.tapCount == 1) { 
        [self.delegate scrollView:self didTouchX:x y:y];
    } 
    if(touch.tapCount == 2) { 
    
    } 
    [super touchesEnded:touches withEvent:event];
} 

@end
