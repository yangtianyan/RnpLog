//
//  RnpEnterPlugView.m
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import "RnpEnterPlugView.h"
/* -- Controller -- */
#import "RnpLogListController.h"
/* -- Util -- */
#import "RnpDefine.h"
#import "NSObject+top.h"
#import "RnpSessionConfiguration.h"
#import "RnpMarkerURLProtocol.h"
#import "RnpCaptureDataManager.h"

static RnpEnterPlugView * instance;
static UIWindow * tempWindow;

@interface _RnpWindow : UIWindow

@end
@implementation _RnpWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView * view = [super hitTest:point withEvent:event];
    if([view isEqual:self]) return nil;
    return view;
}

@end

@interface RnpEnterPlugView ()

@property (nonatomic, strong) UIPanGestureRecognizer * pan;

@end
@implementation RnpEnterPlugView

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#ifndef LogForceShow
            if(![[NSUserDefaults standardUserDefaults] objectForKey:@"rnplog_show"]){
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"rnplog_show"];
            }
            BOOL isShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"rnplog_show"];
            if (!isShow) {
                return;
            }
#endif
            CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
            CGFloat width = 50;
            CGFloat height = width;
            //1. 创建一个window对象，并用一个对象强持有它
            
            UIWindow *window = [[_RnpWindow alloc] initWithFrame:CGRectMake(20, screen_height - height - kBottomSafeHeight - 200, width, height)];
            
            if (@available(iOS 13.0, *)) {
                NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
                UIWindowScene * windowScene = (UIWindowScene*)(array.lastObject);
                window.windowScene = windowScene;
            } else {
                // Fallback on earlier versions
            };
            window.windowLevel = UIWindowLevelStatusBar + 99;
//            [window makeKeyAndVisible];
            RnpEnterPlugView * view = [[RnpEnterPlugView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            [window addSubview:view];
            window.hidden = NO;
            window.alpha = 1;
            tempWindow = window;
            instance = view;
        });
    });
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick)];
        doubleTap.numberOfTapsRequired = 2;
        [tap requireGestureRecognizerToFail:doubleTap];

        self.rnp
        // 00bbff
        .backgroundColor(rgba(0, 187, 255, 1))
        .cornerRadius(frame.size.width/2)
        .addSubView(UILabelNew().rnp
                    .text(@"抓包")
                    .textColor(UIColor.whiteColor)
                    .font([UIFont boldSystemFontOfSize:16])
                    .frame(CGRectMake(0,0,frame.size.width,frame.size.height))
                    .textAlignment(NSTextAlignmentCenter)
                    .setTag(1000)
                    .numberOfLines(2)
                    .view)
        .addGesture(tap)
        .addGesture(doubleTap)
        .addGesture(self.pan);
        NSInteger num = 3;
        UITapGestureRecognizer * lastTap = doubleTap;
        for (NSInteger i = 0; i < 4; i ++) {
            num ++;
            lastTap = [self clearTapGestureRecognizer:lastTap numberOfTapsRequired:num];
        }
        
    }
    return self;
}

- (UITapGestureRecognizer *)clearTapGestureRecognizer:(UITapGestureRecognizer *)lastTap numberOfTapsRequired:(NSInteger)numberOfTapsRequired{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tripleClick)];
    tap.numberOfTapsRequired = numberOfTapsRequired;
    [lastTap requireGestureRecognizerToFail:tap];
    self.rnp.addGesture(tap);
    return tap;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer{
    CGFloat x_padding = 20.f;
    CGFloat y_padding = 20.f;
    //移动状态
    UIGestureRecognizerState recState =  recognizer.state;
    UIView * superView = recognizer.view.superview;
    
    switch (recState) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [recognizer translationInView:self.superview];
            superView.center = CGPointMake(superView.center.x + translation.x, superView.center.y + translation.y);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint stopPoint = CGPointMake(0, SCREEN_HEIGHT / 2.0);
            
            if (superView.center.x < SCREEN_WIDTH / 2.0) {
                if (superView.center.y <= SCREEN_HEIGHT/2.0) {
                    //左上
                    stopPoint = CGPointMake(self.frame.size.width/2.0, superView.center.y);
                }else{
                    //左下
                    if (superView.center.x  >= SCREEN_HEIGHT - superView.center.y) {
                        stopPoint = CGPointMake(superView.center.x, SCREEN_HEIGHT - self.frame.size.width/2.0);
                    }else{
                        stopPoint = CGPointMake(self.frame.size.width/2.0 + x_padding, superView.center.y);
                    }
                }
            }else{
                if (superView.center.y <= SCREEN_HEIGHT/2.0) {
                    //右上
                    stopPoint = CGPointMake(SCREEN_WIDTH - self.frame.size.width/2.0 - x_padding, superView.center.y);
                }else{
                    //右下
                    if (SCREEN_WIDTH - superView.center.x  >= SCREEN_HEIGHT - superView.center.y) {
                        stopPoint = CGPointMake(superView.center.x, SCREEN_HEIGHT - self.frame.size.width/2.0);
                    }else{
                        stopPoint = CGPointMake(SCREEN_WIDTH - self.frame.size.width/2.0 - x_padding,superView.center.y);
                    }
                }
            }
            //如果按钮超出屏幕边缘
            if (stopPoint.y + self.frame.size.width + y_padding + kBottomSafeHeight >= SCREEN_HEIGHT) {
                stopPoint = CGPointMake(stopPoint.x, SCREEN_HEIGHT - self.frame.size.width/2.0 - y_padding - kBottomSafeHeight);
            }
            if (stopPoint.x - self.frame.size.width/2.0 <= 0) {
                stopPoint = CGPointMake(self.frame.size.width/2.0 + x_padding, stopPoint.y);
            }
            if (stopPoint.x + self.frame.size.width/2.0 >= SCREEN_WIDTH) {
                stopPoint = CGPointMake(SCREEN_WIDTH - self.frame.size.width/2.0 - x_padding, stopPoint.y);
            }
            CGFloat maxTopPadding = (self.frame.size.width/2.0 + y_padding + (kBottomSafeHeight == 0 ? 22 : 44));
            if (stopPoint.y - maxTopPadding <= 0) {
                stopPoint = CGPointMake(stopPoint.x, maxTopPadding);
            }
            [UIView animateWithDuration:0.3 animations:^{
                superView.center = stopPoint;
            }];
        }
            break;
            
        default:
            break;
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
}

- (void)tapClick{
    UIViewController * rootViewController = currentWindow().rootViewController;
    [self presentViewControllerForController:rootViewController];
}
- (void)doubleClick{
    UILabel * label = [self viewWithTag:1000];
    if (RnpMarkerURLProtocol.isMonitor) {
        [RnpMarkerURLProtocol stopMonitor];
        label.rnp
        .text(@"暂停抓包")
        .font([UIFont boldSystemFontOfSize:12]);
        self.backgroundColor = rgba(180, 180, 180, 1);
    }else{
        [RnpMarkerURLProtocol startMonitor];
        label.rnp
        .text(@"抓包")
        .font([UIFont boldSystemFontOfSize:16]);
        self.backgroundColor = rgba(0, 187, 255, 1);
    }
}
- (void)tripleClick{
    UILabel * label = [self viewWithTag:1000];
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.toValue =@(M_PI * 6); // 旋转多少角度
    animation.duration = 1; // 持续多长时间
    animation.repeatCount = 1; // 重复次数
//    animation.delegate = self;
    [self.layer addAnimation:animation forKey:nil];
    NSString * text = label.text;
    label.text = @"清空";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        label.text = text;
    });
    [RnpCaptureDataManager.instance clear];
}

- (void)presentViewControllerForController:(UIViewController *)controller{
   UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:[RnpLogListController new]];
    [[self topViewControllerWithRootViewController:controller] presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- Public
+ (RnpEnterPlugView *)instance{
    return instance;
}
+ (void)setInstance:(RnpEnterPlugView *)instance{}

+ (void)show{
    [UIView animateWithDuration:0.5 animations:^{
        instance.alpha = 1;
    }];
}

+ (void)hidden{
    [UIView animateWithDuration:0.5 animations:^{
        instance.alpha = 0;
    }];
}

@end
