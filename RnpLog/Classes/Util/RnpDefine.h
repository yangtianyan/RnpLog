
#define SCREEN_WIDTH MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

#define SCREEN_HEIGHT MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define rgba(r,g,b,a) RGBA(r,g,b,a)
#define RandomColorA(a) [UIColor colorWithRed:arc4random() % 255 / 255.f green:arc4random() % 255 / 255.f blue:arc4random() % 255 / 255.f alpha:a]
#define RandomColor RandomColorA(1.f)

#define StatusHieght RnpStatusFrame()
#define kBottomSafeHeight (RnpBottomSafeHeight())

#define kAddRequestNotification @"kAddRequestNotification"
#import <RnpKit/RnpKitView.h>
#import <RnpKit/RnpBaseViewChain+Layout.h>
#import <Masonry/Masonry.h>

static double RnpStatusFrame(){
    if (@available(iOS 13.0, *)) {
        return UIApplication.sharedApplication.delegate.window.windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

static UIWindow * currentWindow(){
    if([[[UIApplication sharedApplication] delegate] window]) {
        return[[[UIApplication sharedApplication] delegate] window];
    }else{
        if(@available(iOS 13.0, *)) {
            NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene * windowScene = (UIWindowScene*)array[0];
            //如果是普通App开发，可以使用
            //SceneDelegate * delegate = (SceneDelegate *)windowScene.delegate;
            //UIWindow * mainWindow = delegate.window;
            //由于在sdk开发中，引入不了SceneDelegate的头文件，所以需要用kvc获取宿主app的window.
            UIWindow* mainWindow = [windowScene valueForKeyPath:@"delegate.window"];
            if(mainWindow) {
                return mainWindow;
            }else{
                return [UIApplication sharedApplication].windows.lastObject;
            }
        }else{
            // Fallback on earlier versions
            return [UIApplication sharedApplication].keyWindow;
        }
    }
}

static double RnpBottomSafeHeight(){
    if (@available(iOS 11.0, *)) {
        return currentWindow().safeAreaInsets.bottom;
    }else{
        return (RnpStatusFrame() >= 44 ? 34 : 0);
    }
}


