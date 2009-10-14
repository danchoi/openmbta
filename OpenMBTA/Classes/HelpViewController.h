//
//  HelpViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController <UIWebViewDelegate> {
    NSString *viewName;
    IBOutlet UIWebView *webView;
    NSURLRequest *request;    
    NSString *transportType;
    
    UIActivityIndicatorView *spinner;
    UILabel *loadingLabel;
    
    
    
}
@property (nonatomic, copy) NSString *viewName;
@property (nonatomic, copy) NSString *transportType;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSURLRequest *request;
- (IBAction)doneButtonPressed:(id)sender;
- (void)showLoadingIndicators;
- (void)hideLoadingIndicators;
- (void)loadWebView;
@end
