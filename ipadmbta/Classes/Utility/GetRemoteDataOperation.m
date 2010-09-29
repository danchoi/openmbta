#import "GetRemoteDataOperation.h"
#import "JSON.h"

@implementation GetRemoteDataOperation
@synthesize urlString;

- (id)initWithURL:(NSString *)aUrlString target:(id)theTarget action:(SEL)theAction 
{
    self = [super init];
    if (self) {
        self.urlString = aUrlString;
        target = theTarget;
        action = theAction;
    }
    return self;
}

- (void)dealloc
{
    self.urlString = nil;
    [super dealloc];
}

- (void)main
{
    if (self.isCancelled) return;
    if (urlString == nil) return;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *jsonString = [NSString stringWithContentsOfURL:url];
    
    if (!self.isCancelled) {
        [target performSelectorOnMainThread:action withObject:jsonString waitUntilDone:NO];
    }
    
    [pool release];
}

@end
