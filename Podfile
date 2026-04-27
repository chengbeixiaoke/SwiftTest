source 'https://cdn.cocoapods.org/'

platform :ios, '13.0'
use_frameworks!
inhibit_all_warnings!
install! 'cocoapods', :deterministic_uuids => false

def base_pod
  pod 'SnapKit'
  pod 'SwiftyJSON'
  pod 'CoreStore'
  pod 'SQLCipher', '~> 4.0'
  pod 'CombineCocoa'
  pod 'SwifterSwift'
  pod 'Kingfisher'
  pod 'Charts'
  pod 'WebRTC-SDK', '=125.6422.07'
  
  pod 'GLTFSceneKit'
  pod 'GCDWebServer'
  pod 'YYKit', :git => 'https://gitlab.savo.dev/savoapp/ios/yykit.git'
    
  pod 'BMPlayer', :path => './Frameworks/BMPlayer'
  pod 'ffmpeg-kit-ios-full', :path => './Frameworks/ffmpeg-kit-ios-full'
end

target 'SwiftTest' do
  base_pod
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end

