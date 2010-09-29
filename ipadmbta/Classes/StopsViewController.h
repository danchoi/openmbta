//
//  StopsViewController.h
//  OpenMBTA
//  Created by Daniel Choi on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopsViewController : UITableViewController {
    NSMutableArray *orderedStopNames;    
    NSString *selectedStopName;
}
@property (nonatomic, retain) NSMutableArray *orderedStopNames;    
@property (nonatomic, retain) NSString *selectedStopName;
- (void)loadStopNames:(NSNotification *)userInfo;
- (void)selectStopNamed:(NSString *)stopName;
@end
