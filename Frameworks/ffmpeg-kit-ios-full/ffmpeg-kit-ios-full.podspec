Pod::Spec.new do |s|
  s.name             = 'ffmpeg-kit-ios-full'
  s.version          = '1.1.0' # 根据实际版本修改
  s.summary          = 'FFmpegKit for iOS'
  s.description      = <<-DESC
A complete solution to use FFmpeg in your iOS applications.
                       DESC
  s.homepage         = 'https://github.com/tanersener/ffmpeg-kit'
  s.license          = { :type => 'LGPL-3.0', :file => 'LICENSE' }
  s.author           = { 'Taner Sener' => 'tanersener@gmail.com' }
  s.source           = { :path => '.' }
  
  s.ios.deployment_target = '12.0'
  
  s.vendored_frameworks = [
    'ffmpegkit.xcframework',
    'libavcodec.xcframework',
    'libavdevice.xcframework',
    'libavfilter.xcframework',
    'libavformat.xcframework',
    'libavutil.xcframework',
    'libswresample.xcframework',
    'libswscale.xcframework'
  ]
  
  s.libraries = 'z', 'bz2', 'c++'
  s.frameworks = 'AudioToolbox', 'AVFoundation', 'CoreMedia', 'VideoToolbox'
end
