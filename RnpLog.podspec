#
# Be sure to run `pod lib lint RnpLog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RnpLog'
  s.version          = '0.1.0'
  s.summary          = 'A short description of RnpLog.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/905935769@qq.com/RnpLog'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '905935769@qq.com' => 'yangtianyan@diyiedy.com' }
  s.source           = { :git => 'https://github.com/905935769@qq.com/RnpLog.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'RnpLog/Classes/**/*'
  
   s.resource_bundles = {
     'RnpLog' => ['RnpLog/Assets/**/*']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'RnpKit'
#  s.dependency 'RnpKit/Layout'
#  s.dependency 'RnpKit/AttributedString'
#  s.dependency 'Masonry'
  # s.dependency 'AFNetworking', '~> 2.3'
end
