//
//  GridScrollView.m
//  OpenMBTA
//
//  Created by Daniel Choi on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "GridScrollView.h"
#import "ScheduleViewController.h"
#import "TripsViewController.h"
@interface GridScrollView ()

@end

@implementation GridScrollView
@synthesize dataSource;
@synthesize stops, tileHeight, tileWidth;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // we will recycle tiles by removing them from the view and storing them here
        reusableTiles = [[NSMutableSet alloc] init];
        
        
        
        // we need a tile container view to hold all the tiles. This is the view that is returned
        // in the -viewForZoomingInScrollView: delegate method, and it also detects taps.
        
        
        // no rows or columns are visible at first; note this by making the firsts very high and the lasts very low
        
        firstVisibleRow = firstVisibleColumn = NSIntegerMax;
        lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setCanCancelContentTouches:NO];
        self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
        self.scrollEnabled = YES;
        self.directionalLockEnabled = YES;
        //self.pagingEnabled = YES;
        
    }
    return self;
}

- (void)dealloc {
    [reusableTiles release];
    self.stops = nil;
    [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { 
    UITouch *touch = [touches anyObject]; 
    CGPoint location = [touch locationInView:self];
    float y = location.y; 
    if(touch.tapCount == 1) { 

        int row = (int)(y / self.tileHeight);
        // yeah this is terrible encapsulation, but ...
        ScheduleViewController *scheduleViewController = (ScheduleViewController *)self.dataSource;
        NSString *stopName = [scheduleViewController.orderedStopNames objectAtIndex:row];
        TripsViewController *tripViewController = scheduleViewController.tripsViewController;
        [tripViewController highlightStopNamed:stopName];
        
    } 
    if(touch.tapCount == 2) { 
        //NSLog(@"2 taps: %@", coord);
    } 
    [super touchesEnded:touches withEvent:event];
} 

- (UIView *)dequeueReusableTile {
    UIView *tile = [reusableTiles anyObject];
    if (tile) {
        // the only object retaining the tile is our reusableTiles set, so we have to retain/autorelease it
        // before returning it so that it's not immediately deallocated when we remove it from the set
        [[tile retain] autorelease];
        [reusableTiles removeObject:tile];
    }
    return tile;
}


- (void)reloadData {
    // recycle all tiles so that every tile will be replaced in the next layoutSubviews
    for (UIView *view in [self subviews]) {
        [reusableTiles addObject:view];
        [view removeFromSuperview];
    }
    
    // no rows or columns are now visible; note this by making the firsts very high and the lasts very low
    firstVisibleRow = firstVisibleColumn = NSIntegerMax;
    lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
    
    [self setNeedsLayout];
    self.hidden = NO;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect visibleBounds = [self bounds];
    for (UIView *tile in [self subviews]) {
        
        // We want to see if the tiles intersect our (i.e. the scrollView's) bounds, so we need to convert their
        // frames to our own coordinate system
        CGRect tileFrame = [self convertRect:[tile frame] toView:self];

        // If the tile doesn't intersect, it's not visible, so we can recycle it
        if (! CGRectIntersectsRect(tileFrame, visibleBounds)) {
            [reusableTiles addObject:tile];
            [tile removeFromSuperview];
        }
    }
    
    // calculate which rows and columns are visible by doing a bunch of math.
    int firstNeededRow = MAX(0, floorf(visibleBounds.origin.y / tileHeight));
    int firstNeededCol = MAX(0, floorf(visibleBounds.origin.x / tileWidth));
    int lastNeededRow  = floorf((visibleBounds.origin.y + visibleBounds.size.height) / tileHeight);
    int lastNeededCol  = floorf((visibleBounds.origin.x + visibleBounds.size.width) / tileWidth);
         

    // iterate through needed rows and columns, adding any tiles that are missing
    for (int row = firstNeededRow; row <= lastNeededRow; row++) {
        for (int col = firstNeededCol; col <= lastNeededCol; col++) {

            BOOL tileIsMissing = (firstVisibleRow > row || firstVisibleColumn > col || 
                                  lastVisibleRow  < row || lastVisibleColumn  < col);
            
            if (tileIsMissing) {
                UIView *tile = [[dataSource gridScrollView:self tileForRow:row column:col] autorelease];
                if (tile) {
                                    
                    // set the tile's frame so we insert it at the correct position
                    CGRect frame = CGRectMake((tileWidth * col), (tileHeight * row), tileWidth, tileHeight);
                    [tile setFrame:frame];
                    [self addSubview:tile];
                }
            }
        }
    }
    
    // update our record of which rows/cols are visible
    firstVisibleRow = firstNeededRow; firstVisibleColumn = firstNeededCol;
    lastVisibleRow  = lastNeededRow;  lastVisibleColumn  = lastNeededCol;            
   
 
}

@end
