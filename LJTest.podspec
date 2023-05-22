 
Pod::Spec.new do |s|
  s.name             = 'LJTest'
  s.version          = 'main'
  s.summary          = '欢迎使用我的LJTest'


  s.description      = <<-DESC
			这是我的一个测试的本地库文件
                       DESC

  s.homepage         = 'https://github.com/Mrluoios/LJTest'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mrluoios' => 'luojian794589880@163.com' }
  s.source           = { :git => 'https://github.com/Mrluoios/LJTest.git', :tag => s.version }
  s.ios.deployment_target = '11.0'

  s.source_files = 'LJTest/Classes/**/*.h'
  
   s.resource_bundles = {
     'LJTest' => ['LJTest/Assets/*.png']
   }
    # s.exclude_files = "Classes/Exclude"
   s.public_header_files = 'LJTest/Classes/**/*.h'
   s.frameworks = 'UIKit', 'MapKit'
   #s.dependency 'AFNetworking', '~> 2.3'
end
