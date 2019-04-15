Pod::Spec.new do |s|
  s.name             = 'PiPhone'
  s.version          = '1.0'
  s.summary          = 'Picture in picture video playback for iPhone'

  s.description      = <<-DESC
PiPhone is a drop in solution to support picture-in-picture (user-initiated playback of video in a floating, resizable window) on iPhone devices.
                       DESC

  s.homepage         = 'https://github.com/ky1vstar/PiPhone'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ky1vstar' => 'ky1vstar@yandex.ru' }
  s.source           = { :git => 'https://github.com/ky1vstar/PiPhone.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '9.0'

  s.requires_arc = true
  s.resources = 'Source/*.xcassets'
  
  s.public_header_files = ['Source/PiPhone.h', 'Source/Core/PiPManager.h']
  s.source_files = 'Source/**/*.{h,m}'

  s.frameworks = ['UIKit', 'AVKit']
end
