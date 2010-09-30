//
//  CoveringScrollView.h
//  OpenMBTA
//
//  Created by Daniel Choi on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CoveringScrollViewDelegate;
@interface CoveringScrollView : UIScrollView {
}


@end

@protocol CoveringScrollViewDelegate <NSObject>
- (void)scrollView:(CoveringScrollView *)scrollView didTouchX:(float)x y:(float)y;

@end
