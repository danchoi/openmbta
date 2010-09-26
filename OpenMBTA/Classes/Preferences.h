//
//  Preferences.h
//  OpenMBTA
//
//  Created by Daniel Choi on 4/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Preferences : NSObject {
 
}
+ (id)sharedInstance;
- (NSMutableDictionary *)preferences;
- (NSString *)prefsFilePath;
- (void)removeBookmark:(NSDictionary *)bookmark;
- (void)addBookmark:(NSDictionary *)bookmark;
- (BOOL)isBookmarked:(NSDictionary *)bookmark;
- (NSArray *)orderedBookmarks;
@end
