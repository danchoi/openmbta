//
//  BaseViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpViewController.h"

@interface BaseViewController : UIViewController {
    HelpViewController *helpViewController;
}

- (void)showNetworkActivity;
- (void)hideNetworkActivity;
- (void)addHelpButton;
- (void)showHelp:(id)sender;
- (void)checkForMessage:(NSDictionary *)someData;
- (void)alertMessageTitle:(NSString *)title message:(NSString *)message;

@end
