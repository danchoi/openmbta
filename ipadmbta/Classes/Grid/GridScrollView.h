//
//  GridScrollView.h
//  OpenMBTA
//
//  Created by Daniel Choi on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GridScrollViewDataSource;


@interface GridScrollView : UIScrollView {
    id <GridScrollViewDataSource>  dataSource;
    
    NSMutableSet *reusableTiles;    
    
    float tileHeight;
    float tileWidth;

    // we use the following ivars to keep track of which rows and columns are visible
    int firstVisibleRow, firstVisibleColumn, lastVisibleRow, lastVisibleColumn;

    NSArray *stops;
}
@property (nonatomic, assign) id <GridScrollViewDataSource> dataSource;
@property (nonatomic, retain) NSArray *stops;
@property float tileHeight;
@property float tileWidth;

- (UIView *)dequeueReusableTile;  // Used by the delegate to acquire an already allocated tile, in lieu of allocating a new one.

- (void)reloadData;


@end

@protocol GridScrollViewDataSource <NSObject>
- (UIView *)gridScrollView:(GridScrollView *)scrollView tileForRow:(int)row column:(int)column;

@end
