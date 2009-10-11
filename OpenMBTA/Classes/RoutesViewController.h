//
//  RoutesViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripsMapViewController.h"

@interface RoutesViewController : UITableViewController {
    TripsMapViewController *tripsMapViewController;
    NSOperationQueue *operationQueue;
    NSArray *data;
    NSString *transportType;
}

@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSString *transportType;
@end
