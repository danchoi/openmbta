//
//  TAlertsViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TAlertsViewController : UITableViewController {
    NSOperationQueue *operationQueue;
    NSArray *alerts;
    NSArray *data;
}
@property (nonatomic, retain) NSArray *alerts;
@property (nonatomic, retain) NSArray *data;
@end
