#import <UIKit/UIKit.h>

@interface GetRemoteDataOperation : NSOperation {
    NSString *urlString;
    id target;
    SEL action;
}

@property (nonatomic, copy) NSString *urlString;
- (id)initWithURL:(NSString *)aTitleId target:(id)theTarget action:(SEL)theAction;

@end
