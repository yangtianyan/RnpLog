//
//  RNPViewController.m
//  RnpLog
//
//  Created by 905935769@qq.com on 05/14/2021.
//  Copyright (c) 2021 905935769@qq.com. All rights reserved.
//

#import "RNPViewController.h"
//#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/SDWebImage.h>
#import <AFNetworking/AFNetworking.h>
#import <RnpKit/RnpKitView.h>
//#import <RnpLog/NSObject+>

@interface RNPViewController ()<WKUIDelegate>

@end

@implementation RNPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    
    UIButtonNew().rnp
    .addToSuperView(self.view)
    .backgroundColor(UIColor.blackColor)
    .frame(CGRectMake(100, 100, 100, 100))
    .text(@"点击请求", UIControlStateNormal)
    .addClickBlock(^(id  _Nonnull btn) {
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFHTTPRequestSerializer serializer];// 请求
        session.responseSerializer = [AFHTTPResponseSerializer serializer];// 响应
        session.requestSerializer.timeoutInterval = 50;
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
        NSString * url = @"https://dev.namibox.com/dy/dyhome?grade=4b&device_screen_width=375.000000";
        url = @"https://unsplash.com/napi/photos?page=0&per_page=2&order_by=latest";
//        url = @"https://www.taobao.com/";
        __weak typeof(self) weakSelf = self;
        [session GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求成功" message:[NSString stringWithFormat:@"响应结果 %@", string] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertController addAction:cancelAction];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
            NSLog(@"success %@",string);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"failure");
        }];
    });
    
    WKWebView * webview = WKWebViewNew().rnp
    .addToSuperView(self.view)
    .frame(CGRectMake(00, 400, 300, 300))
    .view;
    webview.UIDelegate = self;
    
    UIButtonNew().rnp
    .addToSuperView(self.view)
    .backgroundColor(UIColor.blackColor)
    .frame(CGRectMake(250, 100, 100, 100))
    .text(@"点击webview请求", UIControlStateNormal)
    .addClickBlock(^(id  _Nonnull btn) {
        NSString * url = @"http://47.99.46.244:8080/";
//        url = @"https://www.baidu.com";
        [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    });
    
    UIImageView * imageView = UIImageViewNew().rnp
    .addToSuperView(self.view)
    .frame(CGRectMake(100, 300, 100, 100))
    .view;
    [imageView sd_setImageWithURL:[NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2F1812.img.pp.sohu.com.cn%2Fimages%2Fblog%2F2009%2F11%2F18%2F18%2F8%2F125b6560a6ag214.jpg&refer=http%3A%2F%2F1812.img.pp.sohu.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1623488454&t=8b7ba5546a5e46145ec4a10909b55fc8"]];
}

#pragma mark -  Alert弹窗
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message ? : @"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
