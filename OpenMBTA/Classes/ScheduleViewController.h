//
//  ScheduleViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScheduleViewController : UIViewController <UIWebViewDelegate> {

    UIWebView *webView;
    NSURLRequest *request;    
    NSString *nearestStopId;
    
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, copy) NSString *nearestStopId;

- (void)loadWebViewWithTransportType:(NSString *)transportType routeShortName:(NSString *)routeShortName headsign:(NSString *)headsign firstStop:(NSString *)firstStop;
- (void)highlightNearestStop:(NSString *)stopId;
@end
