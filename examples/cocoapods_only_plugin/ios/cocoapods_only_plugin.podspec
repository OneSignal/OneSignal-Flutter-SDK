Pod::Spec.new do |s|
  s.name             = 'cocoapods_only_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A minimal CocoaPods-only Flutter plugin'
  s.description      = 'Used to test hybrid SPM/CocoaPods scenarios'
  s.homepage         = 'https://example.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Test' => 'test@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.ios.deployment_target = '13.0'
  s.static_framework = true
end
