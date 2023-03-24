//
//  NSString+log.m
//  RnpLog
//
//  Created by user on 2021/5/21.
//

#import "NSString+log.h"
#import <RnpKit/RnpKitAttributedString.h>

@implementation NSString (log)

- (NSAttributedString *)toLogAttributedString{
    NSMutableAttributedString * attribute = [[NSMutableAttributedString alloc] initWithString:self];
    NSString * pattern0 = @"((.*?)\\s=)|(\"(.*?)\"\\s:)";
    NSRange contentRange0 = NSMakeRange(0, self.length);
    NSRegularExpression * express0 = [[NSRegularExpression alloc] initWithPattern:pattern0 options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> * expressResults0 = [express0 matchesInString:self options:NSMatchingReportProgress range:contentRange0];

    for (NSTextCheckingResult *check in expressResults0) {
        NSRange range = NSMakeRange(check.range.location, check.range.length > 1 ? check.range.length - 1 : check.range.length);
        UIColor * keycolor = [UIColor colorWithRed:58/255.f green:181/255.f blue:75/255.f alpha:1];
        attribute.rnp.addAttributes_range(@{NSForegroundColorAttributeName : keycolor}, range);
    }
    
    NSString * pattern = @"((https|http|ftp|rtsp|mms)?:\\/\\/)(.*?)(\"|\\s)";
    NSRegularExpression * express = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> * expressResults = [express matchesInString:self options:NSMatchingReportProgress range:contentRange0];
    for (NSTextCheckingResult *check in expressResults) {
        NSRange range = NSMakeRange(check.range.location, check.range.length > 1 ? check.range.length - 1 : check.range.length);
        UIColor * httpcolor = [UIColor colorWithRed:97/255.f green:210/255.f blue:214/255.f alpha:1];
        attribute.rnp.addAttributes_range(@{NSForegroundColorAttributeName : httpcolor}, range);
    }
    return attribute;;
}
- (id)toJson;{
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    return json ?: self;
}
- (CGSize)stringSizeWithFont:(UIFont *)font constrainedSize:(CGSize)constrainedSize{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName: paragraph};
    CGSize size = [self boundingRectWithSize:constrainedSize
       options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
    attributes:attributes context:nil].size;;
    return size;
}

@end
