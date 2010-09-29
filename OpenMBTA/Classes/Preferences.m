//
//  Bookmarks.m
//  OpenMBTA
//
//  Created by Daniel Choi on 4/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"


@implementation Preferences

- (id)init {
    self = [super init];
    if (nil != self) { }
    return self;
}

+ (id)sharedInstance {
    static Preferences *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[[self class] alloc] init];
    }
    return sharedInstance;
}

- (NSMutableDictionary *)preferences {
    NSMutableDictionary *prefs;
    if ([[NSFileManager defaultManager] fileExistsAtPath: [self prefsFilePath]]) { 
        prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: [self prefsFilePath]]; 
    } else {
        prefs = [[NSMutableDictionary alloc] initWithCapacity: 3];
        [prefs setObject:[NSMutableArray array] forKey:@"bookmarks"];
    }
    [prefs autorelease];
    return prefs;
};

NSInteger bookmarkSort(NSDictionary *bookmark1, NSDictionary *bookmark2, void *context) {
    NSComparisonResult result1 = [[bookmark1 objectForKey:@"transportType"] compare:[bookmark2 objectForKey:@"transportType"]];
    NSComparisonResult result2 = [[bookmark1 objectForKey:@"routeShortName"] compare:[bookmark2 objectForKey:@"routeShortName"]];
    NSComparisonResult result3 = [[bookmark1 objectForKey:@"headsign"] compare:[bookmark2 objectForKey:@"headsign"]];
    NSComparisonResult result4 = [[bookmark1 objectForKey:@"firstStop"] compare:[bookmark2 objectForKey:@"firstStop"]];

    if (result1 != NSOrderedSame) {
        if ([[bookmark1 objectForKey:@"transportType"] isEqualToString:@"Boat"])
            return NSOrderedDescending;
        else if ([[bookmark2 objectForKey:@"transportType"]  isEqualToString:@"Boat"]) 
            return NSOrderedAscending; 
        else
            return result1;
    }
    if (result2 != NSOrderedSame) {
        if ([[bookmark1 objectForKey:@"transportType"]  isEqualToString:@"Bus"]) {
            // order numerically for Bus Routes
            int x = [[bookmark1 objectForKey:@"routeShortName"] integerValue];
            int y = [[bookmark2 objectForKey:@"routeShortName"] integerValue];
            if (x > y)
                return NSOrderedDescending;
            else if (x < y)
                return NSOrderedAscending;
            // skip to next if
        } else {
            return result3;
        }
    }

    if (result3 != NSOrderedSame) 
        return result3;
    return result4;
}

- (NSArray *)orderedBookmarks {
    NSArray *unorderedBookmarks = [[self preferences] objectForKey:@"bookmarks"];
    return [unorderedBookmarks sortedArrayUsingFunction:bookmarkSort context:NULL];
}


- (NSString *) prefsFilePath { 
    NSString *cacheDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]; 
    NSString *prefsFilePath = [cacheDirectory stringByAppendingPathComponent: @"OpenMBTAPrefs.plist"]; 
    return prefsFilePath;
} 


- (void)addBookmark:(NSDictionary *)bookmark {

    NSMutableDictionary *prefs = [self preferences];
    NSMutableArray *bookmarks = [prefs objectForKey:@"bookmarks"];
    [bookmarks addObject:bookmark];

    if (![prefs writeToFile:[self prefsFilePath] atomically:YES]) {
         NSLog(@"VRM failed to save preferences to file!");
    }
    //NSLog(@"added bookmark. new prefs: %@", [self preferences]);
}

- (void)removeBookmark:(NSDictionary *)bookmark {
    NSMutableDictionary *prefs = [self preferences];
    NSMutableArray *bookmarks = [prefs objectForKey:@"bookmarks"];
    for (NSDictionary *saved in bookmarks) {
        if ([[saved objectForKey:@"headsign"] isEqualToString: [bookmark objectForKey:@"headsign"]] &&
            [[saved objectForKey:@"routeShortName"] isEqualToString: [bookmark objectForKey:@"routeShortName"]] &&
            [[saved objectForKey:@"transportType"] isEqualToString: [bookmark objectForKey:@"transportType"]])  {
             [bookmarks removeObject:saved];
            if (![prefs writeToFile:[self prefsFilePath] atomically:YES]) {
                 NSLog(@"VRM failed to save preferences to file!");
            }

    //        NSLog(@"removed bookmark. new prefs: %@", [self preferences]);
            return;
        }
    }
}

- (BOOL)isBookmarked:(NSDictionary *)bookmark {

    NSMutableDictionary *prefs = [self preferences];
    NSArray *bookmarks = [prefs objectForKey:@"bookmarks"];
    
    for (NSDictionary *saved in bookmarks) {
        if ([[saved allKeys] count] == 4) {
            if ([[saved objectForKey:@"headsign"] isEqualToString: [bookmark objectForKey:@"headsign"]] &&
                [[saved objectForKey:@"routeShortName"] isEqualToString: [bookmark objectForKey:@"routeShortName"]] &&
                [[saved objectForKey:@"transportType"] isEqualToString: [bookmark objectForKey:@"transportType"]] &&
                [[saved objectForKey:@"firstStop"] isEqualToString: [bookmark objectForKey:@"firstStop"]])  {
                return true;
                }
        } else if ([[saved allKeys] count] == 3) {
            if ([[saved objectForKey:@"headsign"] isEqualToString: [bookmark objectForKey:@"headsign"]] &&
                [[saved objectForKey:@"routeShortName"] isEqualToString: [bookmark objectForKey:@"routeShortName"]] &&
                [[saved objectForKey:@"transportType"] isEqualToString: [bookmark objectForKey:@"transportType"]]) {
                    return true;
                }            
        }
        
        
    }

    return false;
}

@end
