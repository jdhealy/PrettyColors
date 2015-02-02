Pod::Spec.new do |spec|
  spec.name = 'PrettyColors'
  spec.version = '1.0.0'
  spec.summary = 'Styles and colors text in the Terminal with ANSI escape codes. Conforms to ECMA Standard 48.'
  spec.homepage = 'https://github.com/jdhealy/PrettyColors'
  spec.license = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.author = {
    'J.D. Healy' => 'jdhealy@gmail.com'
  }
  spec.social_media_url = 'http://twitter.com/jdhealy'
  spec.source = { :git => 'https://github.com/jdhealy/PrettyColors.git', :tag => "v#{spec.version}" }
  spec.source_files = 'Source/**/*.{h,swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
end
