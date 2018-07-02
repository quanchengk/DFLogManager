#
# Be sure to run `pod lib lint DFLogManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DFLogManager'
  s.version          = '0.1.3'
  s.summary          = '日志控件'

  s.description      = <<-DESC
  利用NSUserDefault进行本地缓存的日志控件
  更新内容：优化交互体验，增加按次数弹出的方式
                       DESC

  s.homepage         = 'https://github.com/quanchengk/DFLogManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'danfort' => 'quanchengk@163.com' }
  s.source           = { :git => 'https://github.com/quanchengk/DFLogManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'DFLogManager/Classes/**/*'
  s.resources = 'DFLogManager/Assets/*.{png,bundle,plist}'    #引用其他资源文件
  
  s.frameworks = 'UIKit', 'Foundation'
  s.libraries = 'c++'
  s.dependency 'Masonry'
  s.dependency 'UITableView+FDTemplateLayoutCell'
  s.dependency 'MJRefresh'
  s.dependency 'MJExtension'
  s.dependency 'LSiOSPopView'
end
