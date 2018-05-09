#
# Be sure to run `pod lib lint DFLogManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DFLogManager'
  s.version          = '0.0.4'
  s.summary          = '日志控件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
利用sqlite3进行本地缓存的日志控件
更新内容：优化交互体验，数据库由realm调整为sqlite3
                       DESC

  s.homepage         = 'https://github.com/quanchengk/DFLogManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'danfort' => 'quanchengk@163.com' }
  s.source           = { :git => 'https://github.com/quanchengk/DFLogManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DFLogManager/Classes/**/*'
  s.resources = 'DFLogManager/Assets/*.{png,bundle,plist}'    #引用其他资源文件
  
  # s.resource_bundles = {
  #   'DFLogManager' => ['DFLogManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
#s.frameworks = 'UIKit'
#s.ios.library = 'sqlite3'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Masonry'
  s.dependency 'UITableView+FDTemplateLayoutCell'
  s.dependency 'MJRefresh'
  s.dependency 'LSiOSPopView'
end
