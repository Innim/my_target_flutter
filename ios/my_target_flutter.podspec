#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint my_target_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'my_target_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Flutter myTarget SDK for iOS.'
  s.description      = <<-DESC
Flutter myTarget SDK for iOS.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Innim' => 'developer@innim.org' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.static_framework = true
  s.dependency 'Flutter'
  s.dependency 'myTargetSDK', '~> 5.15'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
