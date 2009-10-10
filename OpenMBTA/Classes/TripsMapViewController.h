//
//  TripsMapViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface TripsMapViewController : UIViewController <MKMapViewDelegate> {
    NSDictionary *stops;
    NSArray *imminentStops;    
    IBOutlet MKMapView *mapView;
    NSDictionary *regionInfo;
    NSOperationQueue *operationQueue;    
    
    NSString *headsign;
    NSString *route_shortname;
}
@property (nonatomic, retain) NSDictionary *stops;
@property (nonatomic, retain) NSArray *imminentStops;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSDictionary *regionInfo;
@property (nonatomic, copy) NSString *headsign;
@property (nonatomic, retain) NSString *route_shortname;
@end
