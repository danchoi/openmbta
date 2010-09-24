//
//  GridCell.h
//  OpenMBTA
//
//  Created by Daniel Choi on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GridCell : UITableViewCell {
    IBOutlet UILabel *textLabel;
}
@property (nonatomic, retain) UILabel *textLabel;

@end
