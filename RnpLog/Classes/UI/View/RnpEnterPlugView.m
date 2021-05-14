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

static RnpEnterPlugView * instance;

@interface RnpEnterPlugView ()

@property (nonatomic, strong) UIPanGestureRecognizer * pan;

@end
@implementation RnpEnterPlugView

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
            CGFloat width = 50;
            CGFloat height = width;
            //1. 创建一个window对象，并用一个对象强持有它
            UIWindow *testWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            testWindow.windowLevel = 9999;
            [testWindow makeKeyAndVisible];
            RnpEnterPlugView * view = [[RnpEnterPlugView alloc] initWithFrame:CGRectMake(20, screen_height - height - kBottomSafeHeight, width, height)];
            [testWindow addSubview:view];
            instance = view;
        });
    });
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        self.rnp
        .backgroundColor( [UIColor greenColor])
        .cornerRadius(frame.size.width/2)
        .addSubView(UILabelNew().rnp
                    .text(@"抓包")
                    .textColor(UIColor.whiteColor)
                    .font([UIFont boldSystemFontOfSize:16])
                    .frame(CGRectMake(0,0,frame.size.width,frame.size.height))
                    .textAlignment(NSTextAlignmentCenter)
                    .view)
        .addGesture(tap)
        .addGesture(self.pan);
    }
    return self;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer{
    CGFloat x_padding = 20.f;
    CGFloat y_padding = 20.f;
    //移动状态
    UIGestureRecognizerState recState =  recognizer.state;
    
    switch (recState) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [recognizer translationInView:self.superview];
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint stopPoint = CGPointMake(0, SCREEN_HEIGHT / 2.0);
            
            if (recognizer.view.center.x < SCREEN_WIDTH / 2.0) {
                if (recognizer.view.center.y <= SCREEN_HEIGHT/2.0) {
                    //左上
                    stopPoint = CGPointMake(self.frame.size.width/2.0, recognizer.view.center.y);
                }else{
                    //左下
                    if (recognizer.view.center.x  >= SCREEN_HEIGHT - recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, SCREEN_HEIGHT - self.frame.size.width/2.0);
                    }else{
                        stopPoint = CGPointMake(self.frame.size.width/2.0 + x_padding, recognizer.view.center.y);
                    }
                }
            }else{
                if (recognizer.view.center.y <= SCREEN_HEIGHT/2.0) {
                    //右上
                    stopPoint = CGPointMake(SCREEN_WIDTH - self.frame.size.width/2.0 - x_padding, recognizer.view.center.y);
                }else{
                    //右下
                    if (SCREEN_WIDTH - recognizer.view.center.x  >= SCREEN_HEIGHT - recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, SCREEN_HEIGHT - self.frame.size.width/2.0);
                    }else{
                        stopPoint = CGPointMake(SCREEN_WIDTH - self.frame.size.width/2.0 - x_padding,recognizer.view.center.y);
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
                recognizer.view.center = stopPoint;
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
    if ([rootViewController isKindOfClass:UINavigationController.class]) {
        [self navControllerPushForController:(UINavigationController *)rootViewController];
    }else if ([rootViewController isKindOfClass:UITabBarController.class]){
        UIViewController * showController = [(UITabBarController *)rootViewController viewControllers][[(UITabBarController *)rootViewController selectedIndex]];
        if ([showController isKindOfClass:UINavigationController.class]) {
            [self navControllerPushForController:(UINavigationController *)showController];
        }else{
            [self presentViewControllerForController:showController];
        }
    }else{
        [self presentViewControllerForController:rootViewController];
    }
}

- (void)navControllerPushForController:(UINavigationController *)navController{
    RnpLogListController * controller = [RnpLogListController new];
    [navController pushViewController:controller animated:YES];
    
}
- (void)presentViewControllerForController:(UIViewController *)controller{
   UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:[RnpLogListController new]];
    [controller presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- Public
+ (RnpEnterPlugView *)instance{
    return instance;
}
+ (void)setInstance:(RnpEnterPlugView *)instance{
    
}
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
