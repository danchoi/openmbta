//
//  TripViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripsMapViewController.h"

@interface TripViewController : TripsMapViewController {
    NSString *trip_id;
    NSString *position;

}
@property (nonatomic, copy) NSString *trip_id;
@property (nonatomic, copy) NSString *position;
@end
