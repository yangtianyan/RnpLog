//
//  RnpSessionConfiguration.h
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpSessionConfiguration : NSURLSessionConfiguration
@property (nonatomic, assign) BOOL isSwizzle;
+ (RnpSessionConfiguration *)defaultConfiguration;
- (void)load;
- (void)unload;
@end

NS_ASSUME_NONNULL_END
