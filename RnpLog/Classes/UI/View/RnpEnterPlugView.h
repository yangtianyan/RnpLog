//
//  RnpEnterPlugView.h
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpEnterPlugView : UIView

@property (nonatomic, strong, class) RnpEnterPlugView * instance;

+ (void)show;

+ (void)hidden;

@end

NS_ASSUME_NONNULL_END
