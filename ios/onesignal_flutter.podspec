#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  onesignal_xcframework_version = '5.5.2'
  onesignal_disable_location_env = ENV['ONESIGNAL_DISABLE_LOCATION'].to_s.strip.downcase
  onesignal_disable_location = ['true', '1'].include?(onesignal_disable_location_env)

  s.name             = 'onesignal_flutter'
  s.version          = '5.5.8'
  s.summary          = 'The OneSignal Flutter SDK'
  s.description      = 'Allows you to easily add OneSignal to your flutter projects, to make sending and handling push notifications easy'
  s.homepage         = 'https://www.onesignal.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Brad Hesse' => 'brad@onesignal.com', 'Josh Kasten' => 'josh@onesignal.com' }
  s.source           = { :path => '.' }
  s.source_files = 'onesignal_flutter/Sources/onesignal_flutter/**/*.{h,m}'
  s.public_header_files = 'onesignal_flutter/Sources/onesignal_flutter/include/**/*.h'
  s.dependency 'Flutter'
  if onesignal_disable_location
    s.dependency 'OneSignalXCFramework/OneSignal', onesignal_xcframework_version
    s.dependency 'OneSignalXCFramework/OneSignalInAppMessages', onesignal_xcframework_version
  else
    s.dependency 'OneSignalXCFramework', onesignal_xcframework_version
  end
  s.ios.deployment_target = '11.0'
  s.static_framework = true
end
