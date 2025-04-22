#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
source 'https://cdn.cocoapods.org/'
source 'https://github.com/SumSubstance/Specs.git'

platform :ios, '13.0'
use_frameworks!
inhibit_all_warnings!
install! 'cocoapods', :deterministic_uuids => false

def base_pod
  pod 'SnapKit'
  pod 'SwiftyJSON'
  pod 'CoreStore'
  pod 'YYText'
  pod 'CombineCocoa'
  pod 'SwifterSwift'
  pod 'Kingfisher'
  
  pod 'WebRTC-SDK', '=125.6422.07'
  
  pod 'BMPlayer', :path => './Frameworks/BMPlayer', :inhibit_warnings => false
  pod 'ffmpeg-kit-ios-full', :path => './Frameworks/ffmpeg-kit-ios-full', :inhibit_warnings => false
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
  installer.pods_project.targets.each do |target|
    if ['iProov', 'Socket.IO-Client-Swift', 'Starscream'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
#  installer.pods_project.build_configurations.each do |config|
#    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
#  end
end

