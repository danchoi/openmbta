//
//  AlertViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AlertViewController : BaseViewController {
    NSString *alertTitle;
    NSString *pubDate;
    NSString *description;    
    IBOutlet UITextView *titleLabel;
    IBOutlet UILabel *pubDateLabel;
    IBOutlet UITextView *descriptionTextView;
}
@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, copy) NSString *description;
@end
