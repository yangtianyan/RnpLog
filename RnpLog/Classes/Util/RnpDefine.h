
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
#define kClearRequestNotification @"kClearRequestNotification"

#import <RnpKit/RnpKitView.h>
#import <RnpKit/RnpBaseViewChain+Layout.h>
#import <Masonry/Masonry.h>
#import <objc/runtime.h>

static double RnpStatusFrame(){
    if (@available(iOS 13.0, *)) {
        return UIApplication.sharedApplication.delegate.window.windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

static UIWindow * currentWindow(){
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    if([appDelegate respondsToSelector: @selector(window)] && [appDelegate window]) {
        return[[[UIApplication sharedApplication] delegate] window];
    }else{
        if(@available(iOS 13.0, *)) {
            NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene * windowScene = (UIWindowScene*)(array.firstObject);
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

static void RnpMethodSwizzle(Class c,SEL origSEL,SEL overrideSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method overrideMethod= class_getInstanceMethod(c, overrideSEL);
    
    //运行时函数class_addMethod 如果发现方法已经存在，会失败返回，也可以用来做检查用:
    if(class_addMethod(c, origSEL, method_getImplementation(overrideMethod),method_getTypeEncoding(overrideMethod)))
    {
        //如果添加成功(在父类中重写的方法)，再把目标类中的方法替换为旧有的实现:
        class_replaceMethod(c,overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        //addMethod会让目标类的方法指向新的实现，使用replaceMethod再将新的方法指向原先的实现，这样就完成了交换操作。
        method_exchangeImplementations(origMethod,overrideMethod);
    }
}
