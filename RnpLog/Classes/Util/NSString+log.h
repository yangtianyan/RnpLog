//
//  NSString+log.h
//  RnpLog
//
//  Created by user on 2021/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (log)
- (NSAttributedString *)toLogAttributedString;
- (id)toJson;
- (CGSize)stringSizeWithFont:(UIFont *)font constrainedSize:(CGSize)constrainedSize;
@end

NS_ASSUME_NONNULL_END
