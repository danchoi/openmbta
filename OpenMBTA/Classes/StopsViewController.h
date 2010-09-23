//
//  StopsViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StopsViewController : UIViewController {
    NSArray *orderedStopNames;    

}
@property (nonatomic, retain) NSArray *orderedStopNames;    

- (void)back:(id)sender;
@end
