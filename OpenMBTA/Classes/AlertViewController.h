//
//  AlertViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AlertViewController : HelpViewController {
    NSString *alertGUID;
    
}
@property (nonatomic, copy) NSString *alertGUID;
@end
