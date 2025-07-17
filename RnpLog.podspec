#
# Be sure to run `pod lib lint RnpLog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RnpLog'
  s.version          = '1.0'
  s.summary          = 'A short description of RnpLog.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/yangtianyan/RnpLog'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '905935769@qq.com' => 'yangtianyan@diyiedy.com' }
  s.source           = { :git => 'https://github.com/yangtianyan/RnpLog.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'RnpLog/Classes/Model/*.{h,m}', 'RnpLog/Classes/Protocol/*.{h,m}', 'RnpLog/Classes/UI/**/*.{h,m}', 'RnpLog/Classes/Util/**/*.{h,m}'

   s.resource_bundles = {
     'RnpLog' => ['RnpLog/Assets/**/*']
   }

  s.frameworks = 'UIKit'
  s.dependency 'RnpKit'
end
