# RnpLog

[![CI Status](https://img.shields.io/travis/905935769@qq.com/RnpLog.svg?style=flat)](https://travis-ci.org/905935769@qq.com/RnpLog)
[![Version](https://img.shields.io/cocoapods/v/RnpLog.svg?style=flat)](https://cocoapods.org/pods/RnpLog)
[![License](https://img.shields.io/cocoapods/l/RnpLog.svg?style=flat)](https://cocoapods.org/pods/RnpLog)
[![Platform](https://img.shields.io/cocoapods/p/RnpLog.svg?style=flat)](https://cocoapods.org/pods/RnpLog)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

RnpLog is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:



## Author

coderyty@163.com

## License

RnpLog is available under the MIT license. See the LICENSE file for more info.
### 使用
```
pod 'RnpLog', :git => 'https://github.com/yangtianyan/RnpLog.git', :configurations => 'Debug'
```
### 开启
可在podfile文件中引入代码强制开启抓包
```
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        if target.name == 'RnpLog'
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)','LogForceShow=1']
            end
        end
    end
end
```
或者使用开关
```
 [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"rnplog_show"];
```
### webview
目前main分支不支持webview抓包, 需要webview进行抓包请引入webview分支
请慎用webview抓包, 目前还处于测试阶段,未完善
