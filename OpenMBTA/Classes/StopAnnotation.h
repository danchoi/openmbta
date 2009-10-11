//
//  StopAnnotation.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface StopAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    NSString *stop_id;
    NSString *next_arrivals;
    BOOL isNextStop;
    BOOL isFirstStop;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *stop_id;
@property (nonatomic, copy) NSString *next_arrivals;

@property(nonatomic, getter=isNextStop) BOOL isNextStop;
@property(nonatomic, getter=isFirstStop) BOOL isFirstStop;

@end
