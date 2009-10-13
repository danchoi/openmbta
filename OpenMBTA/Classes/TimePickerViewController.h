//
//  TimePickerViewController.h
//  OpenMBTA
//
//  Created by Daniel Choi on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimePickerViewController : UIViewController {
    IBOutlet UIDatePicker *timePicker;
}
@property (nonatomic, retain) UIDatePicker *timePicker;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
@end
